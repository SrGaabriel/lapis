import Lapis

open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Server.Monad
open Lapis.Server.Builder
open Lapis.Server.Dispatcher
open Lapis.Server.Documents

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

def computeDiagnostics (doc : Document) : Array Diagnostic := Id.run do
  let lines := doc.content.splitOn "\n"
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
  let diagnostics := computeDiagnostics doc
  publishDiagnostics {
    uri := uri
    version := some doc.version
    diagnostics := diagnostics
  }

def handleHover (params : HoverParams) : ServerM TestState (Option Hover) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some doc ← getDocument params.textDocument.uri
    | return none

  let some word := doc.getWordAt params.position
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

  runStdio config
