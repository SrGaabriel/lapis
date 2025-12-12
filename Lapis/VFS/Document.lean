/-
  Manages individual document state including:
  - Text content via piece table
  - Line index for position conversion
  - Snapshots for concurrent access
-/

import Lapis.VFS.Position
import Lapis.VFS.LineIndex
import Lapis.VFS.PieceTable

namespace Lapis.VFS.Document

open PieceTable LineIndex Position

/-! ## Snapshot Types -/

/-- Reason for creating a snapshot -/
inductive SnapshotReason where
  | documentOpen      -- Initial document open
  | preBatch          -- Before a batch of edits
  | analysisCheckpoint -- For background analysis
  | clientRequest     -- Explicit client request
  deriving Inhabited, BEq, Repr

/-- Unique identifier for a snapshot -/
structure SnapshotId where
  id : Nat
  deriving Inhabited, BEq, Repr, Hashable, DecidableEq

namespace SnapshotId

def zero : SnapshotId := ⟨0⟩

def next (id : SnapshotId) : SnapshotId := ⟨id.id + 1⟩

end SnapshotId

/-- A snapshot of document state at a point in time -/
structure Snapshot where
  id : SnapshotId
  reason : SnapshotReason
  pieceTable : PieceTableState
  lineIndex : LineIndex
  version : Int
  refCount : Nat  -- Number of active references
  deriving Inhabited

namespace Snapshot

/-- Create a new snapshot from current document state -/
def create (id : SnapshotId) (reason : SnapshotReason) (pt : PieceTableState)
    (li : LineIndex) (version : Int) : Snapshot :=
  { id := id
    reason := reason
    pieceTable := pt
    lineIndex := li
    version := version
    refCount := 0
  }

/-- Increment reference count -/
def acquire (s : Snapshot) : Snapshot :=
  { s with refCount := s.refCount + 1 }

/-- Decrement reference count -/
def release (s : Snapshot) : Snapshot :=
  { s with refCount := if s.refCount > 0 then s.refCount - 1 else 0 }

/-- Check if snapshot can be pruned -/
def canPrune (s : Snapshot) : Bool :=
  s.refCount == 0

end Snapshot

/-! ## Document State -/

/-- Complete state of a single document -/
structure Document where
  uri : String
  languageId : String
  version : Int
  pieceTable : PieceTableState
  lineIndex : LineIndex
  nextSnapshotId : Nat
  snapshots : Array Snapshot
  deriving Inhabited

namespace Document

/-- Create a new document from initial content -/
def create (uri : String) (languageId : String) (version : Int) (content : String) : Document :=
  let pt := PieceTableState.fromContent content
  let li := LineIndex.build content
  { uri := uri
    languageId := languageId
    version := version
    pieceTable := pt
    lineIndex := li
    nextSnapshotId := 0
    snapshots := #[]
  }

/-- Get total byte length of document -/
def byteLength (doc : Document) : Nat := doc.pieceTable.byteLength

/-- Get total line count -/
def lineCount (doc : Document) : Nat := doc.lineIndex.lineCount

/-- Get full document content as string -/
def getContent (doc : Document) : String := doc.pieceTable.getContent

/-- Create a conversion context for position operations -/
def conversionContext (doc : Document) : ConversionContext :=
  { pieceTable := doc.pieceTable
    lineIndex := doc.lineIndex
  }

/-! ### Text Operations -/

/-- Get text in a byte range -/
def getTextByteRange (doc : Document) (startByte endByte : Nat) : String :=
  doc.pieceTable.getTextByteRange startByte endByte

/-- Get text for a specific line -/
def getLine (doc : Document) (line : Nat) : Option String :=
  let ctx := doc.conversionContext
  ctx.getLineContentTrimmed line

/-- Get text in an LSP range -/
def getText (doc : Document) (range : LspRange) : Option String :=
  let ctx := doc.conversionContext
  match rangeToByteRange ctx range with
  | none => none
  | some (startByte, endByte) =>
    some (doc.pieceTable.getTextByteRange startByte endByte)

/-! ### Edit Operations -/

/-- Apply a single edit at a byte range -/
def applyByteEdit (doc : Document) (startByte endByte : Nat) (newText : String) (newVersion : Int) : Document :=
  -- Apply the edit to the piece table
  let newPt := doc.pieceTable.replaceRange startByte endByte newText

  -- Update line index incrementally
  let oldLength := endByte - startByte
  let newDocLength := newPt.byteLength
  let newLi := doc.lineIndex.applyEdit startByte oldLength newText newDocLength

  { doc with
    version := newVersion
    pieceTable := newPt
    lineIndex := newLi
  }

/-- Apply an edit using LSP positions -/
def applyEdit (doc : Document) (range : LspRange) (newText : String) (newVersion : Int) : Document :=
  let ctx := doc.conversionContext
  match rangeToByteRange ctx range with
  | none => doc  -- Invalid range, no change
  | some (startByte, endByte) =>
    doc.applyByteEdit startByte endByte newText newVersion

/-- Apply multiple edits (must be in reverse document order) -/
def applyEdits (doc : Document) (edits : List (LspRange × String)) (newVersion : Int) : Document :=
  edits.foldl (fun d (range, text) => d.applyEdit range text newVersion) doc

/-- Insert text at a position -/
def insertAt (doc : Document) (pos : LspPosition) (text : String) (newVersion : Int) : Document :=
  doc.applyEdit ⟨pos, pos⟩ text newVersion

/-- Delete text in a range -/
def deleteRange (doc : Document) (range : LspRange) (newVersion : Int) : Document :=
  doc.applyEdit range "" newVersion

/-! ### Position Conversion -/

/-- Convert LSP position to byte offset -/
def positionToOffset (doc : Document) (pos : LspPosition) : Option Nat :=
  positionToByteOffset doc.conversionContext pos

/-- Convert byte offset to LSP position -/
def offsetToPosition (doc : Document) (offset : Nat) : LspPosition :=
  byteOffsetToPosition doc.conversionContext offset

/-! ### Snapshot Operations -/

/-- Create a new snapshot of current state -/
def createSnapshot (doc : Document) (reason : SnapshotReason) : Document × SnapshotId :=
  let snapId := ⟨doc.nextSnapshotId⟩
  let snapshot := Snapshot.create snapId reason doc.pieceTable doc.lineIndex doc.version
  let newDoc := { doc with
    nextSnapshotId := doc.nextSnapshotId + 1
    snapshots := doc.snapshots.push snapshot
  }
  (newDoc, snapId)

/-- Find a snapshot by ID -/
def findSnapshot (doc : Document) (id : SnapshotId) : Option (Nat × Snapshot) :=
  doc.snapshots.findIdx? (·.id == id) |>.map fun idx =>
    (idx, doc.snapshots[idx]!)

/-- Acquire a snapshot (increment ref count) -/
def acquireSnapshot (doc : Document) (id : SnapshotId) : Option (Document × Snapshot) :=
  match doc.findSnapshot id with
  | none => none
  | some (idx, snap) =>
    let newSnap := snap.acquire
    let newSnapshots := doc.snapshots.set! idx newSnap
    some ({ doc with snapshots := newSnapshots }, newSnap)

/-- Release a snapshot (decrement ref count) -/
def releaseSnapshot (doc : Document) (id : SnapshotId) : Document :=
  match doc.findSnapshot id with
  | none => doc
  | some (idx, snap) =>
    let newSnap := snap.release
    let newSnapshots := doc.snapshots.set! idx newSnap
    { doc with snapshots := newSnapshots }

/-- Prune snapshots that are no longer needed -/
def pruneSnapshots (doc : Document) (keep : Snapshot → Bool := fun _ => false) : Document :=
  let newSnapshots := doc.snapshots.filter fun snap =>
    !snap.canPrune || keep snap
  { doc with snapshots := newSnapshots }

/-- Get the piece table from a snapshot -/
def getSnapshotPieceTable (doc : Document) (id : SnapshotId) : Option PieceTableState :=
  match doc.findSnapshot id with
  | none => none
  | some (_, snap) => some snap.pieceTable

/-- Get the line index from a snapshot -/
def getSnapshotLineIndex (doc : Document) (id : SnapshotId) : Option LineIndex :=
  match doc.findSnapshot id with
  | none => none
  | some (_, snap) => some snap.lineIndex

/-! ### Line Index Management -/

/-- Force a full rebuild of the line index -/
def rebuildLineIndex (doc : Document) : Document :=
  let newLi := LineIndex.build doc.pieceTable.getContent
  { doc with lineIndex := newLi }

/-- Compact the piece table (merge adjacent pieces) -/
def compact (doc : Document) : Document :=
  let newPt := doc.pieceTable.compact
  { doc with pieceTable := newPt }

end Document

end Lapis.VFS.Document
