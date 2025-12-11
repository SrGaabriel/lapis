/-
  Lapis Example Server

  A comprehensive example showcasing all LSP features available in Lapis.
  This server demonstrates:
  - Text document synchronization
  - Hover, completion, go-to-definition, find references
  - Diagnostics with debouncing
  - Progress reporting
  - Workspace edits
  - Dynamic capability registration
  - Code actions
  - Document symbols
  - Configuration handling
-/
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

/-! ## User State -/

/-- Custom state for our language server -/
structure MyState where
  /-- Count of requests handled -/
  requestCount : Nat := 0
  /-- Symbol table: name → (uri, position) -/
  symbols : List (String × String × Position) := []
  /-- Configuration: max diagnostics per file -/
  maxDiagnostics : Nat := 100
  deriving Inhabited

/-! ## Helper Functions -/

/-- Find all occurrences of a pattern in text, returning (line, startChar, endChar) -/
def findAllOccurrences (text : String) (pattern : String) : List (Nat × Nat × Nat) := Id.run do
  let lines := text.splitOn "\n"
  let mut results : List (Nat × Nat × Nat) := []
  for h : lineNum in [:lines.length] do
    let line := lines[lineNum]
    let mut pos := 0
    while pos + pattern.length <= line.length do
      if (line.drop pos).startsWith pattern then
        results := (lineNum, pos, pos + pattern.length) :: results
        pos := pos + pattern.length
      else
        pos := pos + 1
  return results.reverse

/-- Extract word at a given position in text -/
def wordAtPosition (text : String) (pos : Position) : Option String := do
  let lines := text.splitOn "\n"
  if h : pos.line < lines.length then
    let line := lines[pos.line]
    let char := pos.character
    if char >= line.length then none
    else
      -- Find word boundaries
      let isWordChar c := c.isAlphanum || c == '_'
      let mut start := char
      let mut «end» := char
      -- Scan backwards
      while start > 0 && isWordChar (line.get ⟨start - 1⟩) do
        start := start - 1
      -- Scan forwards
      while «end» < line.length && isWordChar (line.get ⟨«end»⟩) do
        «end» := «end» + 1
      if start == «end» then none
      else some ((line.drop start).take («end» - start))
  else none

/-! ## Diagnostics -/

/-- Compute diagnostics for a document -/
def computeDiagnostics (uri : String) (content : String) (maxDiag : Nat) : Array Diagnostic := Id.run do
  let mut diagnostics := DiagnosticBuilder.new (source := some "lapis-example")

  -- Check for TODO comments
  for (line, start, stop) in findAllOccurrences content "TODO" do
    diagnostics := diagnostics.warning
      { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }
      "TODO comment found"

  -- Check for FIXME comments
  for (line, start, stop) in findAllOccurrences content "FIXME" do
    diagnostics := diagnostics.error
      { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }
      "FIXME: This needs to be fixed!"

  -- Check for HACK comments
  for (line, start, stop) in findAllOccurrences content "HACK" do
    diagnostics := diagnostics.hint
      { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }
      "HACK: Consider refactoring this"

  -- Check for DEPRECATED markers
  for (line, start, stop) in findAllOccurrences content "DEPRECATED" do
    diagnostics := diagnostics.deprecated
      { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }
      "This code is deprecated"

  -- Limit diagnostics
  let result := diagnostics.build
  if result.size > maxDiag then result.toSubarray.toArray.shrink maxDiag else result

/-- Update and publish diagnostics for a document -/
def updateDiagnostics (uri : String) : ServerM MyState Unit := do
  let some content ← getDocumentContent uri | return
  let state ← getUserState
  let diagnostics := computeDiagnostics uri content state.maxDiagnostics
  let some doc ← getDocument uri | return
  publishDiagnostics { uri, version := some doc.version, diagnostics }

/-! ## Symbol Extraction -/

/-- Extract symbols (definitions) from content -/
def extractSymbols (uri : String) (content : String) : List (String × String × Position) := Id.run do
  let mut symbols : List (String × String × Position) := []
  let lines := content.splitOn "\n"

  for h : lineNum in [:lines.length] do
    let line := lines[lineNum]
    -- Look for "def name" or "let name" patterns
    for keyword in ["def ", "let ", "fn ", "func ", "function "] do
      if let some idx := (findAllOccurrences line keyword).head? then
        let afterKeyword := line.drop (idx.2.1 + keyword.length)
        let name := afterKeyword.takeWhile (fun c => c.isAlphanum || c == '_')
        if !name.isEmpty then
          symbols := (name, uri, ⟨lineNum, idx.2.1 + keyword.length⟩) :: symbols

  return symbols

/-! ## Request Handlers -/

/-- Handle textDocument/hover -/
def handleHover (params : HoverParams) : ServerM MyState (Option Hover) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some content ← getDocumentContent params.textDocument.uri | return none
  let some word ← pure (wordAtPosition content params.position) | return none

  -- Check if it's a known symbol
  let state ← getUserState
  let symbolInfo := state.symbols.find? fun (name, _, _) => name == word

  let hoverText := match symbolInfo with
    | some (name, defUri, defPos) =>
      s!"**{name}**\n\nDefined at {defUri}:{defPos.line + 1}:{defPos.character + 1}"
    | none =>
      s!"**{word}**\n\nNo definition found"

  return some {
    contents := { kind := .markdown, value := hoverText }
    range := some {
      start := params.position
      «end» := ⟨params.position.line, params.position.character + word.length⟩
    }
  }

/-- Handle textDocument/completion -/
def handleCompletion (params : CompletionParams) : ServerM MyState CompletionList := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let state ← getUserState

  -- Provide completions from known symbols
  let symbolItems := state.symbols.map fun (name, uri, pos) =>
    { label := name
      kind := some .function
      detail := some s!"Defined at {uri}:{pos.line + 1}"
      documentation := none
      insertText := some name : CompletionItem }

  -- Add some keyword completions
  let keywordItems := #[
    { label := "def", kind := some .keyword, detail := some "Define a function" },
    { label := "let", kind := some .keyword, detail := some "Define a local binding" },
    { label := "if", kind := some .keyword, detail := some "Conditional expression" },
    { label := "then", kind := some .keyword, detail := some "Then branch" },
    { label := "else", kind := some .keyword, detail := some "Else branch" },
    { label := "match", kind := some .keyword, detail := some "Pattern matching" },
    { label := "return", kind := some .keyword, detail := some "Return from function" }
  ]

  return {
    isIncomplete := false
    items := symbolItems.toArray ++ keywordItems
  }

/-- Handle textDocument/definition -/
def handleDefinition (params : TextDocumentPositionParams) : ServerM MyState (Option Location) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some content ← getDocumentContent params.textDocument.uri | return none
  let some word ← pure (wordAtPosition content params.position) | return none

  let state ← getUserState
  match state.symbols.find? fun (name, _, _) => name == word with
  | some (_, uri, pos) =>
    return some {
      uri := uri
      range := { start := pos, «end» := ⟨pos.line, pos.character + word.length⟩ }
    }
  | none => return none

/-- Handle textDocument/references -/
def handleReferences (params : ReferenceParams) : ServerM MyState (Array Location) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some content ← getDocumentContent params.textDocument.uri | return #[]
  let some word ← pure (wordAtPosition content params.position) | return #[]

  -- Find all occurrences of the word in the current document
  let occurrences := findAllOccurrences content word

  return occurrences.toArray.map fun (line, start, stop) => {
    uri := params.textDocument.uri
    range := { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }
  }

/-- Handle textDocument/documentSymbol -/
def handleDocumentSymbol (params : Lean.Json) : ServerM MyState Lean.Json := do
  let uri := (do
    let td ← params.getObjVal? "textDocument"
    td.getObjValAs? String "uri"
  ) |>.toOption |>.getD ""

  let some content ← getDocumentContent uri | return Lean.Json.arr #[]
  let symbols := extractSymbols uri content

  let symbolInfos := symbols.map fun (name, _, pos) =>
    Lean.Json.mkObj [
      ("name", Lean.Json.str name),
      ("kind", Lean.Json.num 12), -- Function
      ("location", Lean.Json.mkObj [
        ("uri", Lean.Json.str uri),
        ("range", Lean.Json.mkObj [
          ("start", Lean.Json.mkObj [("line", Lean.Json.num pos.line), ("character", Lean.Json.num pos.character)]),
          ("end", Lean.Json.mkObj [("line", Lean.Json.num pos.line), ("character", Lean.Json.num (pos.character + name.length))])
        ])
      ])
    ]

  return Lean.Json.arr symbolInfos.toArray

/-- Handle textDocument/codeAction -/
def handleCodeAction (params : Lean.Json) : ServerM MyState Lean.Json := do
  let uri := (do
    let td ← params.getObjVal? "textDocument"
    td.getObjValAs? String "uri"
  ) |>.toOption |>.getD ""

  let some content ← getDocumentContent uri | return Lean.Json.arr #[]

  -- Offer to convert TODO to DONE
  let mut actions : Array Lean.Json := #[]

  for (line, start, stop) in findAllOccurrences content "TODO" do
    actions := actions.push <| Lean.Json.mkObj [
      ("title", Lean.Json.str "Mark as DONE"),
      ("kind", Lean.Json.str "quickfix"),
      ("edit", Lean.Json.mkObj [
        ("changes", Lean.Json.mkObj [
          (uri, Lean.Json.arr #[
            Lean.Json.mkObj [
              ("range", Lean.Json.mkObj [
                ("start", Lean.Json.mkObj [("line", Lean.Json.num line), ("character", Lean.Json.num start)]),
                ("end", Lean.Json.mkObj [("line", Lean.Json.num line), ("character", Lean.Json.num stop)])
              ]),
              ("newText", Lean.Json.str "DONE")
            ]
          ])
        ])
      ])
    ]

  return Lean.Json.arr actions

/-! ## Notification Handlers -/

/-- Handle textDocument/didOpen -/
def handleDidOpen (params : DidOpenTextDocumentParams) : ServerM MyState Unit := do
  let uri := params.textDocument.uri
  let content := params.textDocument.text

  -- Extract and store symbols
  let newSymbols := extractSymbols uri content
  modifyUserState fun s => { s with symbols := newSymbols ++ s.symbols }

  -- Publish diagnostics
  updateDiagnostics uri

  logInfo s!"Opened: {uri}"

/-- Handle textDocument/didChange -/
def handleDidChange (params : DidChangeTextDocumentParams) : ServerM MyState Unit := do
  let uri := params.textDocument.uri

  -- Re-extract symbols
  let some content ← getDocumentContent uri | return
  let newSymbols := extractSymbols uri content

  -- Update symbol table (remove old symbols from this file, add new ones)
  modifyUserState fun s =>
    { s with symbols := newSymbols ++ s.symbols.filter (fun (_, u, _) => u != uri) }

  -- Update diagnostics
  updateDiagnostics uri

/-- Handle textDocument/didClose -/
def handleDidClose (params : DidCloseTextDocumentParams) : ServerM MyState Unit := do
  let uri := params.textDocument.uri

  -- Remove symbols from this file
  modifyUserState fun s =>
    { s with symbols := s.symbols.filter (fun (_, u, _) => u != uri) }

  -- Clear diagnostics
  clearDiagnostics uri

  logInfo s!"Closed: {uri}"

/-- Handle textDocument/didSave -/
def handleDidSave (params : DidSaveTextDocumentParams) : ServerM MyState Unit := do
  logInfo s!"Saved: {params.textDocument.uri}"

/-! ## Custom Commands -/

/-- Handle custom command to show server stats -/
def handleStats (_params : Lean.Json) : ServerM MyState Lean.Json := do
  let state ← getUserState
  return Lean.Json.mkObj [
    ("requestCount", Lean.Json.num state.requestCount),
    ("symbolCount", Lean.Json.num state.symbols.length),
    ("maxDiagnostics", Lean.Json.num state.maxDiagnostics)
  ]

/-- Handle custom command to trigger a refactoring with progress -/
def handleRefactor (params : Lean.Json) : ServerM MyState Lean.Json := do
  let uri := params.getObjValAs? String "uri" |>.toOption |>.getD "file:///unknown"
  let oldName := params.getObjValAs? String "oldName" |>.toOption |>.getD "old"
  let newName := params.getObjValAs? String "newName" |>.toOption |>.getD "new"

  -- Send progress notifications
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "refactor-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "begin"),
      ("title", Lean.Json.str s!"Renaming '{oldName}' to '{newName}'"),
      ("percentage", Lean.Json.num 0)
    ])
  ])

  -- Simulate some work
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "refactor-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "report"),
      ("message", Lean.Json.str "Finding occurrences..."),
      ("percentage", Lean.Json.num 50)
    ])
  ])

  -- Build workspace edit
  let some content ← getDocumentContent uri | do
    sendNotification "$/progress" (Lean.Json.mkObj [
      ("token", Lean.Json.str "refactor-1"),
      ("value", Lean.Json.mkObj [("kind", Lean.Json.str "end"), ("message", Lean.Json.str "Failed: document not found")])
    ])
    return Lean.Json.mkObj [("success", Lean.Json.bool false)]

  let occurrences := findAllOccurrences content oldName
  let edits := occurrences.map fun (line, start, stop) =>
    { range := { start := ⟨line, start⟩, «end» := ⟨line, stop⟩ }, newText := newName : TextEdit }

  let edit := WorkspaceEditBuilder.new
  let edit := edits.foldl (fun b e => b.replace uri e.range e.newText) edit

  -- Request the client to apply the edit
  let promise ← sendRequest "workspace/applyEdit" (Lean.Json.mkObj [
    ("label", Lean.Json.str s!"Rename {oldName} → {newName}"),
    ("edit", Lean.toJson edit.build)
  ])

  -- End progress
  sendNotification "$/progress" (Lean.Json.mkObj [
    ("token", Lean.Json.str "refactor-1"),
    ("value", Lean.Json.mkObj [
      ("kind", Lean.Json.str "end"),
      ("message", Lean.Json.str s!"Renamed {occurrences.length} occurrences")
    ])
  ])

  let some result := promise.result?.get
    | return Lean.Json.mkObj [("success", Lean.Json.bool false), ("error", Lean.Json.str "No response")]

  return Lean.Json.mkObj [
    ("success", Lean.Json.bool true),
    ("occurrences", Lean.Json.num occurrences.length),
    ("result", result)
  ]

/-! ## Main Entry Point -/

def main : IO Unit := do
  let config := ServerConfig.new "lapis-example" ({} : MyState)
    |>.withVersion "1.0.0"
    |>.withCapabilities {
      -- Text document sync
      textDocumentSync := some {
        openClose := some true
        change := some .full
        save := some { includeText := some true }
      }
      -- Hover support
      hoverProvider := some true
      -- Completion support
      completionProvider := some {
        triggerCharacters := some #[".", ":"]
        resolveProvider := some false
      }
      -- Definition support
      definitionProvider := some true
      -- References support
      referencesProvider := some true
      -- Document symbol support
      documentSymbolProvider := some true
      -- Code action support
      codeActionProvider := some true
    }
    -- Standard LSP handlers
    |>.onRequestOpt "textDocument/hover" handleHover
    |>.onRequest "textDocument/completion" handleCompletion
    |>.onRequestOpt "textDocument/definition" handleDefinition
    |>.onRequest "textDocument/references" handleReferences
    |>.onRequest "textDocument/documentSymbol" handleDocumentSymbol
    |>.onRequest "textDocument/codeAction" handleCodeAction
    -- Document sync notifications
    |>.onNotification "textDocument/didOpen" handleDidOpen
    |>.onNotification "textDocument/didChange" handleDidChange
    |>.onNotification "textDocument/didClose" handleDidClose
    |>.onNotification "textDocument/didSave" handleDidSave
    -- Custom commands
    |>.onRequest "lapis/stats" handleStats
    |>.onRequest "lapis/refactor" handleRefactor

  runStdio config
