/-
  Virtual File System for Lapis LSP Server

  Public API for document management providing:
  - Document lifecycle (open, change, close)
  - Text access and editing
  - Position conversion (UTF-8 <-> UTF-16)
  - Snapshot management for concurrent access
-/

import Lapis.VFS.Document
import Lapis.VFS.Position
import Lapis.VFS.LineIndex
import Lapis.VFS.PieceTable
import Std.Data.HashMap

namespace Lapis.VFS

open Document Position LineIndex PieceTable

/-! ## Re-exports -/

-- Re-export commonly used types
export Position (LspPosition LspRange)
export Document (Document SnapshotId SnapshotReason)

/-! ## Document Store -/

/-- A store of open documents, keyed by URI -/
structure DocumentStore where
  documents : IO.Ref (Std.HashMap String Document)

namespace DocumentStore

/-- Create an empty document store -/
def empty : IO DocumentStore := do
  let docs ← IO.mkRef (∅ : Std.HashMap String Document)
  return { documents := docs }

/-- Get a document by URI -/
def get (store : DocumentStore) (uri : String) : IO (Option Document) := do
  let docs ← store.documents.get
  return docs.get? uri

/-- Check if a document exists -/
def contains (store : DocumentStore) (uri : String) : IO Bool := do
  let docs ← store.documents.get
  return docs.contains uri

/-! ### Document Lifecycle -/

/-- Open a new document -/
def openDocument (store : DocumentStore) (uri : String) (languageId : String)
    (version : Int) (content : String) : IO Unit := do
  let doc := Document.create uri languageId version content
  store.documents.modify fun docs => docs.insert uri doc

/-- Close a document -/
def closeDocument (store : DocumentStore) (uri : String) : IO Unit := do
  store.documents.modify fun docs => docs.erase uri

/-- Update document version (without content change) -/
def updateVersion (store : DocumentStore) (uri : String) (version : Int) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc => docs.insert uri { doc with version := version }

/-! ### Editing -/

/-- Apply a text edit to a document -/
def applyEdit (store : DocumentStore) (uri : String) (range : LspRange)
    (newText : String) (newVersion : Int) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      let newDoc := doc.applyEdit range newText newVersion
      docs.insert uri newDoc

/-- Apply multiple edits to a document (edits should be in reverse document order) -/
def applyEdits (store : DocumentStore) (uri : String)
    (edits : List (LspRange × String)) (newVersion : Int) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      let newDoc := doc.applyEdits edits newVersion
      docs.insert uri newDoc

/-- Replace entire document content -/
def setContent (store : DocumentStore) (uri : String) (content : String)
    (newVersion : Int) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      -- Create fresh document with new content but preserve metadata
      let newDoc := Document.create doc.uri doc.languageId newVersion content
      docs.insert uri newDoc

/-! ### Reading -/

/-- Get text in a range -/
def getText (store : DocumentStore) (uri : String) (range : LspRange) : IO (Option String) := do
  match ← store.get uri with
  | none => return none
  | some doc => return doc.getText range

/-- Get a specific line -/
def getLine (store : DocumentStore) (uri : String) (line : Nat) : IO (Option String) := do
  match ← store.get uri with
  | none => return none
  | some doc => return doc.getLine line

/-- Get full document content -/
def getContent (store : DocumentStore) (uri : String) : IO (Option String) := do
  match ← store.get uri with
  | none => return none
  | some doc => return some doc.getContent

/-- Get document version -/
def getVersion (store : DocumentStore) (uri : String) : IO (Option Int) := do
  match ← store.get uri with
  | none => return none
  | some doc => return some doc.version

/-- Get document line count -/
def getLineCount (store : DocumentStore) (uri : String) : IO (Option Nat) := do
  match ← store.get uri with
  | none => return none
  | some doc => return some doc.lineCount

/-- Get document byte length -/
def getByteLength (store : DocumentStore) (uri : String) : IO (Option Nat) := do
  match ← store.get uri with
  | none => return none
  | some doc => return some doc.byteLength

/-! ### Position Conversion -/

/-- Convert LSP position to byte offset -/
def positionToOffset (store : DocumentStore) (uri : String) (pos : LspPosition) : IO (Option Nat) := do
  match ← store.get uri with
  | none => return none
  | some doc => return doc.positionToOffset pos

/-- Convert byte offset to LSP position -/
def offsetToPosition (store : DocumentStore) (uri : String) (offset : Nat) : IO (Option LspPosition) := do
  match ← store.get uri with
  | none => return none
  | some doc => return some (doc.offsetToPosition offset)

/-- Convert a byte range to an LSP range -/
def byteRangeToLspRange (store : DocumentStore) (uri : String)
    (startByte endByte : Nat) : IO (Option LspRange) := do
  match ← store.get uri with
  | none => return none
  | some doc =>
    let ctx := doc.conversionContext
    return some (byteRangeToRange ctx startByte endByte)

/-- Convert an LSP range to a byte range -/
def lspRangeToByteRange (store : DocumentStore) (uri : String)
    (range : LspRange) : IO (Option (Nat × Nat)) := do
  match ← store.get uri with
  | none => return none
  | some doc =>
    let ctx := doc.conversionContext
    return rangeToByteRange ctx range

/-! ### Snapshots -/

/-- Create a snapshot of the current document state -/
def createSnapshot (store : DocumentStore) (uri : String)
    (reason : SnapshotReason) : IO (Option SnapshotId) := do
  let docs ← store.documents.get
  match docs.get? uri with
  | none => return none
  | some doc =>
    let (newDoc, snapId) := doc.createSnapshot reason
    store.documents.set (docs.insert uri newDoc)
    return some snapId

/-- Acquire a snapshot (increment reference count) -/
def acquireSnapshot (store : DocumentStore) (uri : String)
    (id : SnapshotId) : IO (Option PieceTableState) := do
  let docs ← store.documents.get
  match docs.get? uri with
  | none => return none
  | some doc =>
    match doc.acquireSnapshot id with
    | none => return none
    | some (newDoc, snap) =>
      store.documents.set (docs.insert uri newDoc)
      return some snap.pieceTable

/-- Release a snapshot (decrement reference count) -/
def releaseSnapshot (store : DocumentStore) (uri : String) (id : SnapshotId) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      let newDoc := doc.releaseSnapshot id
      docs.insert uri newDoc

/-- Prune unreferenced snapshots -/
def pruneSnapshots (store : DocumentStore) (uri : String) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      let newDoc := doc.pruneSnapshots
      docs.insert uri newDoc

/-- Rebuild document line index -/
def rebuildLineIndex (store : DocumentStore) (uri : String) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc =>
      let newDoc := doc.rebuildLineIndex
      docs.insert uri newDoc

/-- Get list of all open document URIs -/
def getOpenDocuments (store : DocumentStore) : IO (List String) := do
  let docs ← store.documents.get
  return docs.keys

/-- Modify a document with a function -/
def modify (store : DocumentStore) (uri : String)
    (f : Document → Document) : IO Unit := do
  store.documents.modify fun docs =>
    match docs.get? uri with
    | none => docs
    | some doc => docs.insert uri (f doc)

end DocumentStore

/-! ## Convenience Functions -/

/-- Create a zero position -/
def zeroPosition : LspPosition := LspPosition.zero

/-- Create an empty range -/
def emptyRange : LspRange := LspRange.empty

/-- Create a range at a single point -/
def pointRange (pos : LspPosition) : LspRange := LspRange.point pos

/-- Create a position from line and character -/
def mkPosition (line character : Nat) : LspPosition := ⟨line, character⟩

/-- Create a range from start and end positions -/
def mkRange (start «end» : LspPosition) : LspRange := ⟨start, «end»⟩

/-- Create a range from line/character coordinates -/
def mkRangeFromCoords (startLine startChar endLine endChar : Nat) : LspRange :=
  ⟨⟨startLine, startChar⟩, ⟨endLine, endChar⟩⟩

end Lapis.VFS
