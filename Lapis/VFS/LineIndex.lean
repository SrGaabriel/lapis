/-
  Maintains a mapping from line numbers to byte offsets for efficient
  position conversions. Uses a dirty range tracking mechanism to avoid
  full rebuilds after every edit.
-/

import Lapis.VFS.PieceTable

namespace Lapis.VFS.LineIndex

open PieceTable

/-! ## Constants -/

/-- Threshold percentage of dirty lines that triggers a full rebuild -/
def DIRTY_LINE_THRESHOLD_PERCENT : Nat := 20

/-- Minimum number of dirty lines before considering a rebuild -/
def MIN_DIRTY_LINES_FOR_REBUILD : Nat := 50

/-! ## Dirty Range Tracking -/

/-- A range of lines that may have stale offset data -/
structure DirtyRange where
  startLine : Nat
  endLine : Nat
  deriving Inhabited, Repr, BEq

namespace DirtyRange

/-- Number of lines in this dirty range -/
def lineCount (r : DirtyRange) : Nat := r.endLine - r.startLine + 1

/-- Check if a line is in this dirty range -/
def contains (r : DirtyRange) (line : Nat) : Bool :=
  line >= r.startLine && line <= r.endLine

/-- Merge two overlapping or adjacent ranges -/
def merge (r1 r2 : DirtyRange) : DirtyRange :=
  { startLine := min r1.startLine r2.startLine
    endLine := max r1.endLine r2.endLine
  }

/-- Check if two ranges overlap or are adjacent -/
def overlapsOrAdjacent (r1 r2 : DirtyRange) : Bool :=
  r1.startLine <= r2.endLine + 1 && r2.startLine <= r1.endLine + 1

end DirtyRange

/-! ## Line Index -/

/-- Line index: maps line numbers to byte offsets -/
structure LineIndex where
  /-- offsets[i] = byte offset of start of line i. Line 0 always starts at 0. -/
  offsets : Array Nat
  /-- Ranges of lines with potentially stale data -/
  dirtyRanges : List DirtyRange
  /-- Total line count (including line 0) -/
  totalLines : Nat
  deriving Inhabited, Repr

namespace LineIndex

/-- Create an empty line index (single line starting at offset 0) -/
def empty : LineIndex :=
  { offsets := #[0]
    dirtyRanges := []
    totalLines := 1
  }

/-- Build a complete line index from document content -/
def build (content : String) : LineIndex :=
  let offsets := buildOffsetsAux content 0 0 #[0]
  { offsets := offsets
    dirtyRanges := []
    totalLines := offsets.size
  }
where
  buildOffsetsAux (s : String) (pos : Nat) (bytePos : Nat) (acc : Array Nat) : Array Nat :=
    if h : pos < s.length then
      let c := s.get ⟨pos⟩
      let charSize := c.utf8Size
      let newBytePos := bytePos + charSize
      if c == '\n' then
        buildOffsetsAux s (pos + 1) newBytePos (acc.push newBytePos)
      else
        buildOffsetsAux s (pos + 1) newBytePos acc
    else
      acc
  termination_by s.length - pos

/-- Build line index from piece table state -/
def fromPieceTable (state : PieceTableState) : LineIndex :=
  build state.getContent

/-- Get the number of lines -/
def lineCount (idx : LineIndex) : Nat := idx.totalLines

/-- Check if a line number is valid -/
def isValidLine (idx : LineIndex) (line : Nat) : Bool :=
  line < idx.totalLines

/-- Get the byte offset for the start of a line (if clean) -/
def getLineOffsetClean (idx : LineIndex) (line : Nat) : Option Nat :=
  if line < idx.offsets.size then
    -- Check if this line is in a dirty range
    if idx.dirtyRanges.any (·.contains line) then
      none
    else
      some idx.offsets[line]!
  else
    none

/-- Get byte offset for a line, returning none if dirty -/
def getLineOffset? (idx : LineIndex) (line : Nat) : Option Nat :=
  getLineOffsetClean idx line

/-- Calculate the total number of dirty lines -/
def dirtyLineCount (idx : LineIndex) : Nat :=
  idx.dirtyRanges.foldl (fun acc r => acc + r.lineCount) 0

/-- Check if we should do a full rebuild -/
def shouldRebuild (idx : LineIndex) : Bool :=
  let dirtyCount := idx.dirtyLineCount
  dirtyCount > MIN_DIRTY_LINES_FOR_REBUILD &&
  dirtyCount * 100 > idx.totalLines * DIRTY_LINE_THRESHOLD_PERCENT

/-- Add a dirty range, merging with existing ranges if possible -/
def addDirtyRange (idx : LineIndex) (range : DirtyRange) : LineIndex :=
  let merged := mergeRanges idx.dirtyRanges range
  { idx with dirtyRanges := merged }
where
  mergeRanges (ranges : List DirtyRange) (newRange : DirtyRange) : List DirtyRange :=
    match ranges with
    | [] => [newRange]
    | r :: rs =>
      if r.overlapsOrAdjacent newRange then
        -- Merge and continue checking for more overlaps
        mergeRanges rs (r.merge newRange)
      else
        r :: mergeRanges rs newRange

/-- Mark a range of lines as dirty after an edit -/
def markDirty (idx : LineIndex) (startLine endLine : Nat) (lineDelta : Int) : LineIndex :=
  -- Add the dirty range
  let range := { startLine := startLine, endLine := endLine : DirtyRange }
  let idx' := idx.addDirtyRange range

  -- Adjust total line count
  let newTotal := if lineDelta >= 0 then
    idx'.totalLines + lineDelta.toNat
  else
    idx'.totalLines - (-lineDelta).toNat

  { idx' with totalLines := newTotal }

/-- Clear all dirty ranges (after a rebuild) -/
def clearDirty (idx : LineIndex) : LineIndex :=
  { idx with dirtyRanges := [] }

/-- Update the line index after rebuilding from content -/
def rebuild (idx : LineIndex) (content : String) : LineIndex :=
  build content

/-! ## Incremental Updates -/

/-- Adjust offsets after an edit at a given byte position -/
def adjustOffsets (idx : LineIndex) (afterByte : Nat) (delta : Int) : LineIndex :=
  let newOffsets := idx.offsets.map fun offset =>
    if offset > afterByte then
      if delta >= 0 then
        offset + delta.toNat
      else
        offset - min offset ((-delta).toNat)
    else
      offset
  { idx with offsets := newOffsets }

/-- Insert new line offsets at a position -/
def insertLines (idx : LineIndex) (afterLine : Nat) (newOffsets : Array Nat) : LineIndex :=
  if newOffsets.isEmpty then
    idx
  else
    let before := idx.offsets.extract 0 (afterLine + 1)
    let after := idx.offsets.extract (afterLine + 1) idx.offsets.size
    let combined := before ++ newOffsets ++ after
    { idx with
      offsets := combined
      totalLines := combined.size
    }

/-- Remove line offsets in a range -/
def removeLines (idx : LineIndex) (startLine endLine : Nat) : LineIndex :=
  if startLine > endLine || startLine >= idx.offsets.size then
    idx
  else
    let before := idx.offsets.extract 0 startLine
    let afterIdx := min (endLine + 1) idx.offsets.size
    let after := idx.offsets.extract afterIdx idx.offsets.size
    let combined := before ++ after
    { idx with
      offsets := combined
      totalLines := combined.size
    }

end LineIndex

/-! ## Line Position Utilities -/

/-- Find which line a byte offset falls on using binary search -/
def findLineForOffset (idx : LineIndex) (byteOffset : Nat) : Nat :=
  binarySearchLine idx.offsets byteOffset 0 idx.offsets.size
where
  binarySearchLine (offsets : Array Nat) (target : Nat) (lo hi : Nat) : Nat :=
    if lo >= hi then
      if lo > 0 then lo - 1 else 0
    else
      let mid := (lo + hi) / 2
      if h : mid < offsets.size then
        let offset := offsets[mid]
        if target < offset then
          binarySearchLine offsets target lo mid
        else if mid + 1 < offsets.size && target >= offsets[mid + 1]! then
          binarySearchLine offsets target (mid + 1) hi
        else
          mid
      else
        if lo > 0 then lo - 1 else 0
  termination_by hi - lo

/-- Get the byte range for a line -/
def getLineByteRange (idx : LineIndex) (line : Nat) : Option (Nat × Nat) :=
  if line >= idx.offsets.size then
    none
  else
    let startOffset := idx.offsets[line]!
    let endOffset := if line + 1 < idx.offsets.size then
      idx.offsets[line + 1]!
    else
      -- Last line extends to end of document
      -- This is a sentinel value; caller should clamp to document length
      startOffset + 1000000000  -- Large number as sentinel
    some (startOffset, endOffset)

end Lapis.VFS.LineIndex
