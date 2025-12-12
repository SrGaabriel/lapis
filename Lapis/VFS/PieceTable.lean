/-
  A piece table is a data structure for representing text that supports efficient
  editing operations. It maintains:
  - An immutable "original" buffer containing the initial document text
  - An append-only "add" buffer containing all inserted text
  - A finger tree of "pieces" that describe how to reconstruct the document

  Each piece points to a contiguous range in either buffer. Edits work by
  splitting pieces and inserting new ones, never modifying the underlying buffers.

  Operations are O(log n) due to the finger tree structure.
-/

import Lapis.VFS.FingerTree

namespace Lapis.VFS.PieceTable

open FingerTree

/-! ## Buffer Identifier -/

/-- Identifies which buffer a piece points to -/
inductive Buffer where
  | original  -- The initial document content (immutable)
  | add       -- Append-only buffer for insertions
  deriving Inhabited, BEq, Repr, DecidableEq

/-! ## Piece Descriptor -/

/-- A piece describes a contiguous range of text in one of the buffers -/
structure Piece where
  buffer : Buffer
  start : Nat         -- Byte offset into buffer
  length : Nat        -- Byte length
  lineBreaks : Nat    -- Cached newline count
  utf16Length : Nat   -- Cached UTF-16 code unit count
  deriving Inhabited, Repr

namespace Piece

/-- Count UTF-16 code units in a string -/
private def computeUtf16Length (s : String) : Nat :=
  s.foldl (fun count c =>
    let cp := c.toNat
    if cp >= 0x10000 then count + 2  -- Supplementary plane: 2 UTF-16 units
    else count + 1                    -- BMP: 1 UTF-16 unit
  ) 0

/-- Create a piece from text content, computing metrics -/
def fromText (buffer : Buffer) (start : Nat) (text : String) : Piece :=
  let lineBreaks := text.foldl (fun count c => if c == '\n' then count + 1 else count) 0
  let utf16Length := computeUtf16Length text
  { buffer := buffer
    start := start
    length := text.utf8ByteSize
    lineBreaks := lineBreaks
    utf16Length := utf16Length
  }

/-- Create an empty piece -/
def empty : Piece :=
  { buffer := .original
    start := 0
    length := 0
    lineBreaks := 0
    utf16Length := 0
  }

/-- Check if piece is empty -/
def isEmpty (p : Piece) : Bool := p.length == 0

end Piece

/-- Pieces are measurable for the finger tree -/
instance : Measurable Piece where
  measure p := {
    bytes := p.length
    utf16Units := p.utf16Length
    lines := p.lineBreaks
  }

/-! ## Text Buffers -/

/-- The two text buffers backing the piece table -/
structure TextBuffers where
  original : String      -- Immutable after creation
  add : String           -- Append-only
  deriving Inhabited

namespace TextBuffers

/-- Create buffers from initial document content -/
def fromContent (content : String) : TextBuffers :=
  { original := content, add := "" }

/-- Get text for a piece from the appropriate buffer -/
def getPieceText (buffers : TextBuffers) (p : Piece) : String :=
  let buf := match p.buffer with
    | .original => buffers.original
    | .add => buffers.add
  -- Extract substring using byte positions
  let startPos := ⟨p.start⟩
  let endPos := ⟨p.start + p.length⟩
  String.Pos.Raw.extract buf startPos endPos

/-- Append text to the add buffer, returning new buffers and the start position -/
def appendText (buffers : TextBuffers) (text : String) : TextBuffers × Nat :=
  let startPos := buffers.add.utf8ByteSize
  let newBuffers := { buffers with add := buffers.add ++ text }
  (newBuffers, startPos)

end TextBuffers

/-! ## Piece Table State -/

/-- The complete piece table state using a finger tree of pieces -/
structure PieceTableState where
  buffers : TextBuffers
  pieces : FingerTree Piece
  deriving Inhabited

namespace PieceTableState

/-- Create a piece table from initial content -/
def fromContent (content : String) : PieceTableState :=
  if content.isEmpty then
    { buffers := TextBuffers.fromContent content
      pieces := .empty
    }
  else
    let buffers := TextBuffers.fromContent content
    let piece := Piece.fromText .original 0 content
    { buffers := buffers
      pieces := .single piece
    }

/-- Get the total byte length -/
def byteLength (state : PieceTableState) : Nat := state.pieces.measure.bytes

/-- Get the total line count -/
def lineCount (state : PieceTableState) : Nat := state.pieces.measure.lines

/-- Get the total UTF-16 length -/
def utf16Length (state : PieceTableState) : Nat := state.pieces.measure.utf16Units

/-- Get all text content -/
def getContent (state : PieceTableState) : String :=
  state.pieces.foldl (fun acc p => acc ++ state.buffers.getPieceText p) ""

/-- Get text in a byte range -/
def getTextByteRange (state : PieceTableState) (startByte endByte : Nat) : String :=
  if startByte >= endByte then ""
  else
    let pieces := state.pieces.toArray
    getTextByteRangeAux pieces state.buffers startByte endByte 0 0 ""
where
  getTextByteRangeAux (pieces : Array Piece) (buffers : TextBuffers)
      (startByte endByte : Nat) (idx : Nat) (currentByte : Nat) (result : String) : String :=
    if h : idx < pieces.size then
      let p := pieces[idx]
      let pieceEnd := currentByte + p.length
      if currentByte >= endByte then
        result
      else if pieceEnd > startByte then
        -- This piece overlaps with the range
        let pieceStartInRange := if currentByte >= startByte then 0 else startByte - currentByte
        let pieceEndInRange := if pieceEnd <= endByte then p.length else endByte - currentByte
        let text := buffers.getPieceText p
        let startPos : String.Pos.Raw := ⟨pieceStartInRange⟩
        let endPos : String.Pos.Raw := ⟨pieceEndInRange⟩
        let newResult := result ++ String.Pos.Raw.extract text startPos endPos
        getTextByteRangeAux pieces buffers startByte endByte (idx + 1) pieceEnd newResult
      else
        getTextByteRangeAux pieces buffers startByte endByte (idx + 1) pieceEnd result
    else
      result
  termination_by pieces.size - idx

/-- Split a piece at a byte offset within it -/
private def splitPieceAt (buffers : TextBuffers) (p : Piece) (offset : Nat) : Piece × Piece :=
  if offset == 0 then
    (Piece.empty, p)
  else if offset >= p.length then
    (p, Piece.empty)
  else
    -- Need to scan the text to count line breaks and UTF-16 units in each half
    let text := buffers.getPieceText p
    let leftText := String.Pos.Raw.extract text ⟨0⟩ ⟨offset⟩
    let rightText := String.Pos.Raw.extract text ⟨offset⟩ ⟨text.utf8ByteSize⟩
    let leftPiece := Piece.fromText p.buffer p.start leftText
    let rightPiece := Piece.fromText p.buffer (p.start + offset) rightText
    (leftPiece, rightPiece)

/-- Insert text at a byte position - O(log n) -/
def insertAt (state : PieceTableState) (bytePos : Nat) (text : String) : PieceTableState :=
  if text.isEmpty then
    state
  else
    -- Append text to add buffer
    let (newBuffers, addStart) := state.buffers.appendText text
    let newPiece := Piece.fromText .add addStart text

    if state.pieces.isEmpty then
      { buffers := newBuffers, pieces := .single newPiece }
    else if bytePos == 0 then
      -- Insert at beginning
      { buffers := newBuffers, pieces := FingerTree.cons newPiece state.pieces }
    else if bytePos >= state.byteLength then
      -- Insert at end
      { buffers := newBuffers, pieces := FingerTree.snoc state.pieces newPiece }
    else
      -- Split at position and insert
      match state.pieces.splitAtBytes bytePos with
      | none =>
        -- Couldn't split, append at end
        { buffers := newBuffers, pieces := FingerTree.snoc state.pieces newPiece }
      | some ⟨left, pivot, right⟩ =>
        -- Check if we need to split the pivot piece
        let leftMeasure := left.measure.bytes
        let offsetInPivot := bytePos - leftMeasure
        if offsetInPivot == 0 then
          -- Insert between left and pivot
          let newPieces := left ++ FingerTree.cons newPiece (FingerTree.cons pivot right)
          { buffers := newBuffers, pieces := newPieces }
        else
          -- Split the pivot piece
          let (leftPart, rightPart) := splitPieceAt newBuffers pivot offsetInPivot
          let newPieces :=
            if leftPart.isEmpty then
              left ++ FingerTree.cons newPiece (if rightPart.isEmpty then right else FingerTree.cons rightPart right)
            else if rightPart.isEmpty then
              FingerTree.snoc left leftPart ++ FingerTree.cons newPiece right
            else
              FingerTree.snoc left leftPart ++ FingerTree.cons newPiece (FingerTree.cons rightPart right)
          { buffers := newBuffers, pieces := newPieces }

/-- Delete text in a byte range - O(log n) -/
def deleteRange (state : PieceTableState) (startByte endByte : Nat) : PieceTableState :=
  if startByte >= endByte || state.pieces.isEmpty then
    state
  else if startByte == 0 && endByte >= state.byteLength then
    -- Delete everything
    { state with pieces := .empty }
  else if startByte == 0 then
    -- Delete from beginning
    match state.pieces.splitAtBytes endByte with
    | none => state
    | some ⟨_, pivot, right⟩ =>
      let endMeasure := state.pieces.measure.bytes - right.measure.bytes - pivot.length
      let offsetInPivot := endByte - endMeasure
      if offsetInPivot >= pivot.length then
        { state with pieces := right }
      else
        let (_, rightPart) := splitPieceAt state.buffers pivot offsetInPivot
        if rightPart.isEmpty then
          { state with pieces := right }
        else
          { state with pieces := FingerTree.cons rightPart right }
  else if endByte >= state.byteLength then
    -- Delete to end
    match state.pieces.splitAtBytes startByte with
    | none => state
    | some ⟨left, pivot, _⟩ =>
      let leftMeasure := left.measure.bytes
      let offsetInPivot := startByte - leftMeasure
      if offsetInPivot == 0 then
        { state with pieces := left }
      else
        let (leftPart, _) := splitPieceAt state.buffers pivot offsetInPivot
        if leftPart.isEmpty then
          { state with pieces := left }
        else
          { state with pieces := FingerTree.snoc left leftPart }
  else
    -- Delete in middle - split at start, then at end
    match state.pieces.splitAtBytes startByte with
    | none => state
    | some ⟨left, pivotStart, afterStart⟩ =>
      let leftMeasure := left.measure.bytes
      let offsetInPivotStart := startByte - leftMeasure

      -- Get left part of start pivot
      let (leftOfStart, rightOfStart) := splitPieceAt state.buffers pivotStart offsetInPivotStart
      let leftTree := if leftOfStart.isEmpty then left else FingerTree.snoc left leftOfStart

      -- Now find the end in the remaining pieces
      let remainingStart := if rightOfStart.isEmpty then afterStart else FingerTree.cons rightOfStart afterStart
      let bytesToEnd := endByte - startByte

      match remainingStart.splitAtBytes bytesToEnd with
      | none =>
        -- End is past remaining, just keep left
        { state with pieces := leftTree }
      | some ⟨_, pivotEnd, right⟩ =>
        let deletedMeasure := remainingStart.measure.bytes - right.measure.bytes - pivotEnd.length
        let offsetInPivotEnd := bytesToEnd - deletedMeasure
        let (_, rightOfEnd) := splitPieceAt state.buffers pivotEnd offsetInPivotEnd
        let rightTree := if rightOfEnd.isEmpty then right else FingerTree.cons rightOfEnd right
        { state with pieces := leftTree ++ rightTree }

/-- Replace text in a byte range - O(log n) -/
def replaceRange (state : PieceTableState) (startByte endByte : Nat) (text : String) : PieceTableState :=
  let afterDelete := state.deleteRange startByte endByte
  afterDelete.insertAt startByte text

end PieceTableState

/-! ## Piece Coalescing -/

namespace PieceTableState

/-- Coalesce two adjacent pieces -/
private def coalescePieces (p1 p2 : Piece) : Piece :=
  { p1 with
    length := p1.length + p2.length
    lineBreaks := p1.lineBreaks + p2.lineBreaks
    utf16Length := p1.utf16Length + p2.utf16Length
  }

/-- Compact the piece table by merging adjacent same-buffer pieces -/
def compact (state : PieceTableState) : PieceTableState :=
  let pieceList := state.pieces.toList
  match pieceList with
  | [] => state
  | p :: ps =>
    let compacted := compactAux ps p []
    { state with pieces := FingerTree.fromList compacted }
where
  compactAux (pieces : List Piece) (current : Piece) (result : List Piece) : List Piece :=
    match pieces with
    | [] => result ++ [current]
    | next :: rest =>
      if current.buffer == next.buffer && current.start + current.length == next.start then
        compactAux rest (coalescePieces current next) result
      else
        compactAux rest next (result ++ [current])

end PieceTableState

end Lapis.VFS.PieceTable
