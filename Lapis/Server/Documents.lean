/-
  Server Document Handling using VFS

  This module bridges the LSP protocol types with the VFS document store.
-/

import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.VFS

namespace Lapis.Server.Documents

open Lapis.Protocol.Types
open Lapis.Protocol.Messages

-- Use VFS types with explicit namespace
abbrev DocumentStore := Lapis.VFS.DocumentStore
abbrev Document := Lapis.VFS.Document.Document
abbrev LspPosition := Lapis.VFS.Position.LspPosition
abbrev LspRange := Lapis.VFS.Position.LspRange
abbrev SnapshotId := Lapis.VFS.Document.SnapshotId
abbrev SnapshotReason := Lapis.VFS.Document.SnapshotReason

/-! ## Protocol to VFS Conversion -/

/-- Convert LSP Protocol Position to VFS LspPosition -/
def toVfsPosition (pos : Position) : LspPosition :=
  ⟨pos.line, pos.character⟩

/-- Convert VFS LspPosition to LSP Protocol Position -/
def fromVfsPosition (pos : LspPosition) : Position :=
  ⟨pos.line, pos.character⟩

/-- Convert LSP Protocol Range to VFS LspRange -/
def toVfsRange (range : Range) : LspRange :=
  ⟨toVfsPosition range.start, toVfsPosition range.end⟩

/-- Convert VFS LspRange to LSP Protocol Range -/
def fromVfsRange (range : LspRange) : Range :=
  ⟨fromVfsPosition range.start, fromVfsPosition range.end⟩

/-! ## DocumentStore Operations -/

/-- Create empty document store -/
def createDocumentStore : IO DocumentStore := Lapis.VFS.DocumentStore.empty

/-- Open a document from LSP parameters -/
def openDoc (store : DocumentStore) (params : DidOpenTextDocumentParams) : IO Unit := do
  let doc := params.textDocument
  store.openDocument doc.uri doc.languageId doc.version doc.text

/-- Close a document from LSP parameters -/
def closeDoc (store : DocumentStore) (params : DidCloseTextDocumentParams) : IO Unit := do
  store.closeDocument params.textDocument.uri

/-- Get a document by URI -/
def getDoc (store : DocumentStore) (uri : DocumentUri) : IO (Option Document) :=
  store.get uri

/-- Apply document changes from LSP parameters -/
def changeDoc (store : DocumentStore) (params : DidChangeTextDocumentParams) : IO Unit := do
  let uri := params.textDocument.uri
  let version := params.textDocument.version

  for change in params.contentChanges do
    match change.range with
    | none =>
      -- Full document replacement
      store.setContent uri change.text version
    | some range =>
      -- Incremental change
      let vfsRange := toVfsRange range
      store.applyEdit uri vfsRange change.text version

/-! ## Document Accessors -/

/-- Get content at a line -/
def getLine (store : DocumentStore) (uri : DocumentUri) (line : Nat) : IO (Option String) :=
  store.getLine uri line

/-- Get full document content -/
def getContent (store : DocumentStore) (uri : DocumentUri) : IO (Option String) :=
  store.getContent uri

/-- Get document version -/
def getVersion (store : DocumentStore) (uri : DocumentUri) : IO (Option Int) :=
  store.getVersion uri

/-- Get word at position (simple implementation) -/
def getWordAt (store : DocumentStore) (uri : DocumentUri) (pos : Position) : IO (Option String) := do
  match ← store.getLine uri pos.line with
  | none => return none
  | some line =>
    let isWordChar := fun c => c.isAlphanum || c == '_'
    -- Find start of word by going backwards
    let start := pos.character - (line.toList.take pos.character |>.reverse.takeWhile isWordChar |>.length)
    -- Find end of word by going forward
    let endPos := pos.character + (line.toList.drop pos.character |>.takeWhile isWordChar |>.length)
    if start == endPos then return none
    else return some (Substring.Raw.toString ⟨line, ⟨start⟩, ⟨endPos⟩⟩)

/-! ## Position Conversion -/

/-- Convert LSP position to byte offset -/
def positionToOffset (store : DocumentStore) (uri : DocumentUri) (pos : Position) : IO (Option Nat) :=
  store.positionToOffset uri (toVfsPosition pos)

/-- Convert byte offset to LSP position -/
def offsetToPosition (store : DocumentStore) (uri : DocumentUri) (offset : Nat) : IO (Option Position) := do
  match ← store.offsetToPosition uri offset with
  | none => return none
  | some vfsPos => return some (fromVfsPosition vfsPos)

end Lapis.Server.Documents
