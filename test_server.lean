import Lapis

open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Server.Monad
open Lapis.Server.Builder
open Lapis.Server.Dispatcher
open Lapis.Server.Documents
open Lapis.Server.Progress
open Lapis.Server.WorkspaceEdit
open Lapis.Server.Diagnostics
open Lapis.Server.Registration

structure TestState where
  requestCount : Nat := 0

def findSubstring (haystack needle : String) : Option Nat := Id.run do
  let haystackLen := haystack.length
  let needleLen := needle.length
  if needleLen > haystackLen then return none
  for i in [:(haystackLen - needleLen + 1)] do
    if String.isPrefixOf needle (haystack.drop i) then
      return some i
  return none

def containsSubstring (haystack needle : String) : Bool :=
  (findSubstring haystack needle).isSome

def computeDiagnostics (content : String) : Array Diagnostic := Id.run do
  let lines := content.splitOn "\n"
  let mut diagnostics : Array Diagnostic := #[]
  for h : i in [:lines.length] do
    let line := lines[i]
    if containsSubstring line "TODO" then
      let startChar := findSubstring line "TODO" |>.getD 0
      diagnostics := diagnostics.push {
        range := {
          start := { line := i, character := startChar }
          «end» := { line := i, character := startChar + 4 }
        }
        severity := some .warning
        source := some "example-server"
        message := "TODO comment found"
      }
    if containsSubstring line "FIXME" then
      let startChar := findSubstring line "FIXME" |>.getD 0
      diagnostics := diagnostics.push {
        range := {
          start := { line := i, character := startChar }
          «end» := { line := i, character := startChar + 5 }
        }
        severity := some .error
        source := some "example-server"
        message := "FIXME comment found - this needs to be fixed!"
      }
  return diagnostics

def updateDiagnostics (uri : DocumentUri) : ServerM TestState Unit := do
  let some doc ← getDocument uri | return
  let some content ← getDocumentContent uri | return
  let diagnostics := computeDiagnostics content
  publishDiagnostics {
    uri := uri
    version := some doc.version
    diagnostics := diagnostics
  }

def handleHover (params : HoverParams) : ServerM TestState (Option Hover) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some _doc ← getDocument params.textDocument.uri
    | return none

  let some word ← getDocumentWordAt params.textDocument.uri params.position
    | return none

  let count ← getUserState
  return some {
    contents := {
      kind := .markdown
      value := s!"**Word:** `{word}`\n\nPosition: line {params.position.line}, char {params.position.character}\n\nRequests handled: {count.requestCount}"
    }
    range := none
  }

def handleCompletion (_params : CompletionParams) : ServerM TestState CompletionList := do
  return {
    isIncomplete := false
    items := #[
      { label := "hello", kind := some .text, detail := some "A greeting" },
      { label := "world", kind := some .text, detail := some "The planet" },
      { label := "TODO", kind := some .keyword, detail := some "Mark something as todo" },
      { label := "FIXME", kind := some .keyword, detail := some "Mark something as needing fix" }
    ]
  }

def handleDidOpen (params : DidOpenTextDocumentParams) : ServerM TestState Unit := do
  showInfo "Document opened!"
  updateDiagnostics params.textDocument.uri

def handleDidChange (params : DidChangeTextDocumentParams) : ServerM TestState Unit := do
  updateDiagnostics params.textDocument.uri

/-- Handler that triggers progress reporting for testing -/
def handleProgress (_params : Lean.Json) : ServerM TestState Lean.Json := do
  -- Send progress begin
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "test-progress-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "begin"),
      ("title", Lean.Json.str "Test Operation"),
      ("percentage", Lean.Json.num 0)
    ])
  ])

  -- Send progress report
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "test-progress-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "report"),
      ("message", Lean.Json.str "Processing..."),
      ("percentage", Lean.Json.num 50)
    ])
  ])

  -- Send progress end
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "test-progress-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "end"),
      ("message", Lean.Json.str "Complete")
    ])
  ])

  return Lean.Json.mkObj [("success", Lean.Json.bool true)]

/-- Handler that triggers workspace/applyEdit for testing -/
def handleApplyEdit (params : Lean.Json) : ServerM TestState Lean.Json := do
  let uri := params.getObjValAs? String "uri" |>.toOption |>.getD "file:///test.txt"
  let newText := params.getObjValAs? String "newText" |>.toOption |>.getD "inserted text"

  -- Build a workspace edit
  let edit := WorkspaceEditBuilder.new
    |>.insert uri { line := 0, character := 0 } newText
    |>.build

  -- Send workspace/applyEdit request to client
  let promise ← sendRequest "workspace/applyEdit" (Lean.Json.mkObj [
    ("label", Lean.Json.str "Test Edit"),
    ("edit", Lean.toJson edit)
  ])

  -- Wait for response (with timeout handling in real code)
  let some result := promise.result?.get
    | return Lean.Json.mkObj [("success", Lean.Json.bool false), ("error", Lean.Json.str "No response")]

  return Lean.Json.mkObj [("success", Lean.Json.bool true), ("result", result)]

/-- Handler that triggers client/registerCapability for testing -/
def handleRegisterCapability (_params : Lean.Json) : ServerM TestState Lean.Json := do
  -- Register a file watcher capability
  let registration := Lean.Json.mkObj [
    ("id", Lean.Json.str "test-file-watcher-1"),
    ("method", Lean.Json.str "workspace/didChangeWatchedFiles"),
    ("registerOptions", Lean.Json.mkObj [
      ("watchers", Lean.Json.arr #[
        Lean.Json.mkObj [
          ("globPattern", Lean.Json.str "**/*.test"),
          ("kind", Lean.Json.num 7)  -- Create | Change | Delete
        ]
      ])
    ])
  ]

  let promise ← sendRequest "client/registerCapability" (Lean.Json.mkObj [
    ("registrations", Lean.Json.arr #[registration])
  ])

  let some result := promise.result?.get
    | return Lean.Json.mkObj [("success", Lean.Json.bool false), ("error", Lean.Json.str "No response")]

  -- null response means success
  return Lean.Json.mkObj [("success", Lean.Json.bool true), ("result", result)]

def handleTestEdit (params : HoverParams) : ServerM TestState (Option Hover) := do
  let _edit := WorkspaceEditBuilder.new
    |>.replace params.textDocument.uri
        { start := { line := 0, character := 0 }, «end» := { line := 0, character := 5 } }
        "REPLACED"
    |>.insert params.textDocument.uri { line := 1, character := 0 } "INSERTED\n"
    |>.build

  return some {
    contents := {
      kind := .markdown
      value := "WorkspaceEditBuilder test - edit created successfully"
    }
  }

def testDiagnosticBuilder : Array Diagnostic :=
  DiagnosticBuilder.new (source := some "test-server")
    |>.error
        { start := { line := 0, character := 0 }, «end» := { line := 0, character := 5 } }
        "Test error"
    |>.warning
        { start := { line := 1, character := 0 }, «end» := { line := 1, character := 5 } }
        "Test warning"
    |>.hint
        { start := { line := 2, character := 0 }, «end» := { line := 2, character := 5 } }
        "Test hint"
    |>.deprecated
        { start := { line := 3, character := 0 }, «end» := { line := 3, character := 5 } }
        "This is deprecated"
    |>.build

def main : IO Unit := do
  let config := ServerConfig.new "example-server" ({} : TestState)
    |>.withVersion "0.1.0"
    |>.withCapabilities {
      textDocumentSync := some {
        openClose := some true
        change := some .full
        save := some { includeText := some false }
      }
      hoverProvider := some true
      completionProvider := some {
        triggerCharacters := some #["."]
        resolveProvider := some false
      }
    }
    |>.onRequestOpt "textDocument/hover" handleHover
    |>.onRequest "textDocument/completion" handleCompletion
    |>.onNotification "textDocument/didOpen" handleDidOpen
    |>.onNotification "textDocument/didChange" handleDidChange
    -- Test handlers for server-initiated features
    |>.onRequest "test/progress" handleProgress
    |>.onRequest "test/applyEdit" handleApplyEdit
    |>.onRequest "test/registerCapability" handleRegisterCapability

  runStdio config
