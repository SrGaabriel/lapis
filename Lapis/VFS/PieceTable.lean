/-
  A piece table is a data structure for representing text that supports efficient
  editing operations. It maintains:
  - An immutable "original" buffer containing the initial document text
  - An append-only "add" buffer containing all inserted text
  - A finger tree of "pieces" that describe how to reconstruct the document

  Each piece points to a contiguous range in either buffer. Edits work by
  splitting pieces and inserting new ones, never modifying the underlying buffers.
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

/-- Convert a piece to the FingerTree element type -/
def toElem (p : Piece) : Elem :=
  { measure := {
      bytes := p.length
      utf16Units := p.utf16Length
      lines := p.lineBreaks
    }
  }

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
  buf.extract startPos endPos

/-- Append text to the add buffer, returning new buffers and the start position -/
def appendText (buffers : TextBuffers) (text : String) : TextBuffers × Nat :=
  let startPos := buffers.add.utf8ByteSize
  let newBuffers := { buffers with add := buffers.add ++ text }
  (newBuffers, startPos)

end TextBuffers

/-! ## Piece Tree -/

/-- A piece tree is a finger tree of pieces (represented as Elems) -/
abbrev PieceTree := FingerTree

/-! ## Piece Table State -/

/-- The complete piece table state -/
structure PieceTableState where
  buffers : TextBuffers
  /-- We store pieces as a list for now, will be upgraded to use proper finger tree -/
  pieces : Array Piece
  /-- Cached total measure -/
  totalMeasure : Measure
  deriving Inhabited

namespace PieceTableState

/-- Create a piece table from initial content -/
def fromContent (content : String) : PieceTableState :=
  if content.isEmpty then
    { buffers := TextBuffers.fromContent content
      pieces := #[]
      totalMeasure := Measure.empty
    }
  else
    let buffers := TextBuffers.fromContent content
    let piece := Piece.fromText .original 0 content
    { buffers := buffers
      pieces := #[piece]
      totalMeasure := {
        bytes := piece.length
        utf16Units := piece.utf16Length
        lines := piece.lineBreaks
      }
    }

/-- Get the total byte length -/
def byteLength (state : PieceTableState) : Nat := state.totalMeasure.bytes

/-- Get the total line count -/
def lineCount (state : PieceTableState) : Nat := state.totalMeasure.lines

/-- Get the total UTF-16 length -/
def utf16Length (state : PieceTableState) : Nat := state.totalMeasure.utf16Units

/-- Recompute total measure from pieces -/
private def recomputeMeasure (pieces : Array Piece) : Measure :=
  pieces.foldl (fun m p => m + {
    bytes := p.length
    utf16Units := p.utf16Length
    lines := p.lineBreaks
  }) Measure.empty

/-- Get all text content -/
def getContent (state : PieceTableState) : String :=
  state.pieces.foldl (fun acc p => acc ++ state.buffers.getPieceText p) ""

/-- Helper to get text in byte range, accumulating over pieces -/
private def getTextByteRangeAux (state : PieceTableState) (startByte endByte : Nat)
    (idx : Nat) (currentByte : Nat) (result : String) : String :=
  if h : idx < state.pieces.size then
    let p := state.pieces[idx]
    let pieceEnd := currentByte + p.length
    if currentByte >= endByte then
      result
    else if pieceEnd > startByte then
      -- This piece overlaps with the range
      let pieceStartInRange := if currentByte >= startByte then 0 else startByte - currentByte
      let pieceEndInRange := if pieceEnd <= endByte then p.length else endByte - currentByte
      let text := state.buffers.getPieceText p
      let startPos : String.Pos := ⟨pieceStartInRange⟩
      let endPos : String.Pos := ⟨pieceEndInRange⟩
      let newResult := result ++ text.extract startPos endPos
      getTextByteRangeAux state startByte endByte (idx + 1) pieceEnd newResult
    else
      getTextByteRangeAux state startByte endByte (idx + 1) pieceEnd result
  else
    result
termination_by state.pieces.size - idx

/-- Get text in a byte range -/
def getTextByteRange (state : PieceTableState) (startByte endByte : Nat) : String :=
  getTextByteRangeAux state startByte endByte 0 0 ""

/-- Find piece index and offset for a byte position -/
private def findPieceAtByteAux (state : PieceTableState) (bytePos : Nat)
    (idx : Nat) (currentByte : Nat) : Option (Nat × Nat) :=
  if h : idx < state.pieces.size then
    let p := state.pieces[idx]
    let pieceEnd := currentByte + p.length
    if bytePos < pieceEnd then
      some (idx, bytePos - currentByte)
    else
      findPieceAtByteAux state bytePos (idx + 1) pieceEnd
  else
    -- Position is at the end
    if bytePos == currentByte then
      some (state.pieces.size, 0)
    else
      none
termination_by state.pieces.size - idx

private def findPieceAtByte (state : PieceTableState) (bytePos : Nat) : Option (Nat × Nat) :=
  findPieceAtByteAux state bytePos 0 0

/-- Split a piece at a byte offset within it -/
private def splitPieceAt (state : PieceTableState) (p : Piece) (offset : Nat) : Piece × Piece :=
  if offset == 0 then
    (Piece.empty, p)
  else if offset >= p.length then
    (p, Piece.empty)
  else
    -- Need to scan the text to count line breaks and UTF-16 units in each half
    let text := state.buffers.getPieceText p
    let leftText := text.extract ⟨0⟩ ⟨offset⟩
    let rightText := text.extract ⟨offset⟩ ⟨text.utf8ByteSize⟩
    let leftPiece := Piece.fromText p.buffer p.start leftText
    let rightPiece := Piece.fromText p.buffer (p.start + offset) rightText
    (leftPiece, rightPiece)

/-- Insert text at a byte position -/
def insertAt (state : PieceTableState) (bytePos : Nat) (text : String) : PieceTableState :=
  if text.isEmpty then
    state
  else
    -- Append text to add buffer
    let (newBuffers, addStart) := state.buffers.appendText text
    let newPiece := Piece.fromText .add addStart text

    match findPieceAtByte state bytePos with
    | none => state  -- Invalid position
    | some (pieceIdx, offsetInPiece) =>
      if pieceIdx >= state.pieces.size then
        -- Insert at end
        let newPieces := state.pieces.push newPiece
        { buffers := newBuffers
          pieces := newPieces
          totalMeasure := recomputeMeasure newPieces
        }
      else if offsetInPiece == 0 then
        -- Insert at piece boundary
        let newPieces := state.pieces.insertIdx! pieceIdx newPiece
        { buffers := newBuffers
          pieces := newPieces
          totalMeasure := recomputeMeasure newPieces
        }
      else
        -- Split the piece
        let p := state.pieces[pieceIdx]!
        let (leftPiece, rightPiece) := splitPieceAt state p offsetInPiece
        let piecesAfterErase := state.pieces.eraseIdx! pieceIdx
        -- Build new pieces array
        let newPieces := buildInsertPieces piecesAfterErase pieceIdx leftPiece newPiece rightPiece
        { buffers := newBuffers
          pieces := newPieces
          totalMeasure := recomputeMeasure newPieces
        }
where
  buildInsertPieces (arr : Array Piece) (idx : Nat) (left mid right : Piece) : Array Piece :=
    let arr1 := if left.isEmpty then arr else arr.insertIdx! idx left
    let idx1 := if left.isEmpty then idx else idx + 1
    let arr2 := arr1.insertIdx! idx1 mid
    let idx2 := idx1 + 1
    if right.isEmpty then arr2 else arr2.insertIdx! idx2 right

/-- Delete text in a byte range -/
def deleteRange (state : PieceTableState) (startByte endByte : Nat) : PieceTableState :=
  if startByte >= endByte then
    state
  else
    match findPieceAtByte state startByte, findPieceAtByte state endByte with
    | some (startIdx, startOffset), some (endIdx, endOffset) =>
      if startIdx >= state.pieces.size then
        state  -- Nothing to delete
      else
        let newPieces := buildDeletePieces state startIdx startOffset endIdx endOffset
        { state with
          pieces := newPieces
          totalMeasure := recomputeMeasure newPieces
        }
    | _, _ => state
where
  buildDeletePieces (state : PieceTableState) (startIdx startOffset endIdx endOffset : Nat) : Array Piece :=
    -- Keep pieces before start
    let beforeStart := state.pieces.extract 0 startIdx

    -- Handle start piece (keep left part)
    let leftPart :=
      if startOffset > 0 && startIdx < state.pieces.size then
        let p := state.pieces[startIdx]!
        let (leftPiece, _) := splitPieceAt state p startOffset
        if leftPiece.isEmpty then #[] else #[leftPiece]
      else
        #[]

    -- Handle end piece (keep right part)
    let (rightPart, afterEnd) :=
      let actualEndIdx := min endIdx (state.pieces.size - 1)
      if endOffset > 0 && actualEndIdx < state.pieces.size then
        let p := state.pieces[actualEndIdx]!
        let (_, rightPiece) := splitPieceAt state p endOffset
        let right := if rightPiece.isEmpty then #[] else #[rightPiece]
        let after := state.pieces.extract (actualEndIdx + 1) state.pieces.size
        (right, after)
      else if endIdx < state.pieces.size && endOffset == 0 then
        -- End is at the start of a piece, keep that piece and all after
        let after := state.pieces.extract endIdx state.pieces.size
        (#[], after)
      else
        (#[], #[])

    beforeStart ++ leftPart ++ rightPart ++ afterEnd

/-- Replace text in a byte range -/
def replaceRange (state : PieceTableState) (startByte endByte : Nat) (text : String) : PieceTableState :=
  let afterDelete := state.deleteRange startByte endByte
  afterDelete.insertAt startByte text

end PieceTableState

/-! ## Piece Coalescing -/

namespace PieceTableState

/-- Check if two pieces can be coalesced (adjacent in the add buffer) -/
def canCoalesce (p1 p2 : Piece) (addBufferLen : Nat) : Bool :=
  p1.buffer == .add &&
  p2.buffer == .add &&
  p1.start + p1.length == p2.start &&
  p2.start + p2.length == addBufferLen

/-- Coalesce two adjacent pieces -/
def coalescePieces (p1 p2 : Piece) : Piece :=
  { p1 with
    length := p1.length + p2.length
    lineBreaks := p1.lineBreaks + p2.lineBreaks
    utf16Length := p1.utf16Length + p2.utf16Length
  }

/-- Compact helper that processes pieces recursively -/
private def compactAux (pieces : Array Piece) (idx : Nat) (current : Piece) (result : Array Piece) : Array Piece :=
  if h : idx < pieces.size then
    let next := pieces[idx]
    -- Check if we can merge: same buffer and adjacent
    if current.buffer == next.buffer && current.start + current.length == next.start then
      compactAux pieces (idx + 1) (coalescePieces current next) result
    else
      compactAux pieces (idx + 1) next (result.push current)
  else
    result.push current
termination_by pieces.size - idx

/-- Compact the piece array by merging adjacent same-buffer pieces -/
def compact (state : PieceTableState) : PieceTableState :=
  if state.pieces.size <= 1 then
    state
  else
    let newPieces := compactAux state.pieces 1 state.pieces[0]! #[]
    { state with pieces := newPieces }

end PieceTableState

end Lapis.VFS.PieceTable
