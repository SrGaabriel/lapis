/-
  VFS Actor

  The VFS (Virtual File System) actor owns all document state exclusively.
  All document operations go through message passing to this actor.

  This eliminates race conditions on document state by ensuring
  sequential processing of all document mutations.
-/

import Lapis.Concurrent.Actor
import Lapis.VFS
import Lapis.Protocol.Types
import Lapis.Protocol.Messages

namespace Lapis.Concurrent.VfsActor

open Lapis.Concurrent.Actor
open Lapis.Concurrent.Channel
open Lapis.VFS
open Lapis.VFS.Document
open Lapis.Protocol.Types
open Lapis.Protocol.Messages

/-! ## Document Snapshot -/

/-- An immutable snapshot of a document for use by request handlers.
    This can be freely shared across threads. -/
structure DocumentSnapshot where
  uri : String
  languageId : String
  version : Int
  content : String
  lineCount : Nat
  deriving Inhabited

namespace DocumentSnapshot

/-- Get a line from the snapshot -/
def getLine (snap : DocumentSnapshot) (line : Nat) : Option String :=
  let lines := snap.content.splitOn "\n"
  if h : line < lines.length then
    some lines[line]
  else
    none

/-- Get text in a range -/
def getText (snap : DocumentSnapshot) (startLine startChar endLine endChar : Nat) : Option String := do
  let lines := snap.content.splitOn "\n"
  if startLine == endLine then
    let line ← if h : startLine < lines.length then some lines[startLine] else none
    let startPos := min startChar line.length
    let endPos := min endChar line.length
    return line.extract ⟨startPos⟩ ⟨endPos⟩
  else
    -- Multi-line range
    let mut result := ""
    for i in [startLine : endLine + 1] do
      if h : i < lines.length then
        let line := lines[i]
        if i == startLine then
          result := result ++ line.extract ⟨min startChar line.length⟩ ⟨line.length⟩ ++ "\n"
        else if i == endLine then
          result := result ++ line.extract ⟨0⟩ ⟨min endChar line.length⟩
        else
          result := result ++ line ++ "\n"
    return result

end DocumentSnapshot

/-! ## VFS Messages -/

/-- Messages that the VFS actor can receive -/
inductive VfsMsg where
  /-- Open a new document -/
  | openDocument (params : DidOpenTextDocumentParams)
  /-- Close a document -/
  | closeDocument (params : DidCloseTextDocumentParams)
  /-- Apply changes to a document -/
  | changeDocument (params : DidChangeTextDocumentParams)
  /-- Request a snapshot of a document -/
  | getSnapshot (uri : DocumentUri) (replyTo : Oneshot (Option DocumentSnapshot))
  /-- Request content of a document -/
  | getContent (uri : DocumentUri) (replyTo : Oneshot (Option String))
  /-- Request a specific line -/
  | getLine (uri : DocumentUri) (line : Nat) (replyTo : Oneshot (Option String))
  /-- Request word at position -/
  | getWordAt (uri : DocumentUri) (pos : Position) (replyTo : Oneshot (Option String))
  /-- Request position to offset conversion -/
  | positionToOffset (uri : DocumentUri) (pos : Position) (replyTo : Oneshot (Option Nat))
  /-- Request offset to position conversion -/
  | offsetToPosition (uri : DocumentUri) (offset : Nat) (replyTo : Oneshot (Option Position))
  /-- Get list of open documents -/
  | getOpenDocuments (replyTo : Oneshot (List String))
  /-- Check if document exists -/
  | hasDocument (uri : DocumentUri) (replyTo : Oneshot Bool)
  /-- Shutdown the VFS actor -/
  | shutdown

/-! ## VFS Actor State -/

/-- Internal state of the VFS actor -/
structure VfsState where
  store : DocumentStore

/-! ## VFS Actor Reference -/

/-- A handle to communicate with the VFS actor -/
structure VfsRef where
  ref : ActorRef VfsMsg

namespace VfsRef

/-- Open a document (fire and forget) -/
def openDocument (vfs : VfsRef) (params : DidOpenTextDocumentParams) : IO Unit :=
  vfs.ref.send (.openDocument params)

/-- Close a document (fire and forget) -/
def closeDocument (vfs : VfsRef) (params : DidCloseTextDocumentParams) : IO Unit :=
  vfs.ref.send (.closeDocument params)

/-- Apply changes to a document (fire and forget) -/
def changeDocument (vfs : VfsRef) (params : DidChangeTextDocumentParams) : IO Unit :=
  vfs.ref.send (.changeDocument params)

/-- Get a snapshot of a document (blocking request-response) -/
def getSnapshot (vfs : VfsRef) (uri : DocumentUri) : IO (Option DocumentSnapshot) := do
  let reply ← Oneshot.new
  vfs.ref.send (.getSnapshot uri reply)
  reply.recv

/-- Get document content -/
def getContent (vfs : VfsRef) (uri : DocumentUri) : IO (Option String) := do
  let reply ← Oneshot.new
  vfs.ref.send (.getContent uri reply)
  reply.recv

/-- Get a specific line -/
def getLine (vfs : VfsRef) (uri : DocumentUri) (line : Nat) : IO (Option String) := do
  let reply ← Oneshot.new
  vfs.ref.send (.getLine uri line reply)
  reply.recv

/-- Get word at position -/
def getWordAt (vfs : VfsRef) (uri : DocumentUri) (pos : Position) : IO (Option String) := do
  let reply ← Oneshot.new
  vfs.ref.send (.getWordAt uri pos reply)
  reply.recv

/-- Convert position to byte offset -/
def positionToOffset (vfs : VfsRef) (uri : DocumentUri) (pos : Position) : IO (Option Nat) := do
  let reply ← Oneshot.new
  vfs.ref.send (.positionToOffset uri pos reply)
  reply.recv

/-- Convert byte offset to position -/
def offsetToPosition (vfs : VfsRef) (uri : DocumentUri) (offset : Nat) : IO (Option Position) := do
  let reply ← Oneshot.new
  vfs.ref.send (.offsetToPosition uri offset reply)
  reply.recv

/-- Get list of open document URIs -/
def getOpenDocuments (vfs : VfsRef) : IO (List String) := do
  let reply ← Oneshot.new
  vfs.ref.send (.getOpenDocuments reply)
  reply.recv

/-- Check if a document is open -/
def hasDocument (vfs : VfsRef) (uri : DocumentUri) : IO Bool := do
  let reply ← Oneshot.new
  vfs.ref.send (.hasDocument uri reply)
  reply.recv

/-- Request shutdown -/
def shutdown (vfs : VfsRef) : IO Unit :=
  vfs.ref.send .shutdown

end VfsRef

/-! ## Helper Functions -/

/-- Convert VFS LspPosition to Protocol Position -/
private def fromVfsPosition (pos : Position.LspPosition) : Position :=
  ⟨pos.line, pos.character⟩

/-- Convert Protocol Position to VFS LspPosition -/
private def toVfsPosition (pos : Position) : Position.LspPosition :=
  ⟨pos.line, pos.character⟩

/-- Convert Protocol Range to VFS LspRange -/
private def toVfsRange (range : Range) : Position.LspRange :=
  ⟨toVfsPosition range.start, toVfsPosition range.end⟩

/-- Create a snapshot from a document -/
private def mkSnapshot (doc : Document) : DocumentSnapshot :=
  { uri := doc.uri
    languageId := doc.languageId
    version := doc.version
    content := doc.getContent
    lineCount := doc.lineCount
  }

/-- Get word at position from a line -/
private def extractWordAt (line : String) (char : Nat) : Option String :=
  let isWordChar := fun c => c.isAlphanum || c == '_'
  let chars := line.toList
  let start := char - (chars.take char |>.reverse.takeWhile isWordChar |>.length)
  let endPos := char + (chars.drop char |>.takeWhile isWordChar |>.length)
  if start == endPos then
    none
  else
    some (Substring.Raw.toString ⟨line, ⟨start⟩, ⟨endPos⟩⟩)

/-! ## VFS Actor Implementation -/

/-- Handle a VFS message -/
private def handleVfsMsg (state : VfsState) (msg : VfsMsg) : IO (HandleResult VfsState) := do
  match msg with
  | .openDocument params =>
    let doc := params.textDocument
    state.store.openDocument doc.uri doc.languageId doc.version doc.text
    return .continue state

  | .closeDocument params =>
    state.store.closeDocument params.textDocument.uri
    return .continue state

  | .changeDocument params =>
    let uri := params.textDocument.uri
    let version := params.textDocument.version
    for change in params.contentChanges do
      match change.range with
      | none =>
        state.store.setContent uri change.text version
      | some range =>
        let vfsRange := toVfsRange range
        state.store.applyEdit uri vfsRange change.text version
    return .continue state

  | .getSnapshot uri replyTo =>
    match ← state.store.get uri with
    | none => replyTo.send none
    | some doc => replyTo.send (some (mkSnapshot doc))
    return .continue state

  | .getContent uri replyTo =>
    let content ← state.store.getContent uri
    replyTo.send content
    return .continue state

  | .getLine uri line replyTo =>
    let lineContent ← state.store.getLine uri line
    replyTo.send lineContent
    return .continue state

  | .getWordAt uri pos replyTo =>
    match ← state.store.getLine uri pos.line with
    | none => replyTo.send none
    | some line => replyTo.send (extractWordAt line pos.character)
    return .continue state

  | .positionToOffset uri pos replyTo =>
    let offset ← state.store.positionToOffset uri (toVfsPosition pos)
    replyTo.send offset
    return .continue state

  | .offsetToPosition uri offset replyTo =>
    match ← state.store.offsetToPosition uri offset with
    | none => replyTo.send none
    | some vfsPos => replyTo.send (some (fromVfsPosition vfsPos))
    return .continue state

  | .getOpenDocuments replyTo =>
    let docs ← state.store.getOpenDocuments
    replyTo.send docs
    return .continue state

  | .hasDocument uri replyTo =>
    let docExists ← state.store.contains uri
    replyTo.send docExists
    return .continue state

  | .shutdown =>
    return .stop

/-- Spawn the VFS actor -/
def spawnVfsActor : IO (Actor VfsMsg VfsState × VfsRef) := do
  let store ← DocumentStore.empty
  let initialState : VfsState := { store }

  let actor ← spawn initialState handleVfsMsg { name := "vfs" }
  let vfsRef : VfsRef := { ref := actor.ref }

  return (actor, vfsRef)

end Lapis.Concurrent.VfsActor
