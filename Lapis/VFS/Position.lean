/-
  Position Conversion Utilities

  Handles conversion between different position representations:
  - Byte offsets (UTF-8)
  - UTF-16 code unit offsets (for LSP compatibility)
  - Line/character positions (LSP Position type)
-/

import Lapis.VFS.LineIndex
import Lapis.VFS.PieceTable

namespace Lapis.VFS.Position

open LineIndex LineIndex.LineIndex PieceTable

/-! ## UTF-16 Utilities -/

/-- Count UTF-16 code units in a string -/
def utf16Length (s : String) : Nat :=
  s.foldl (fun count c =>
    let cp := c.toNat
    if cp >= 0x10000 then count + 2  -- Supplementary plane: 2 UTF-16 units
    else count + 1                    -- BMP: 1 UTF-16 unit
  ) 0

/-- Convert a UTF-8 byte offset to a UTF-16 offset within a string -/
def utf8OffsetToUtf16 (s : String) (utf8Offset : Nat) : Nat :=
  utf8ToUtf16Aux s 0 0 0
where
  utf8ToUtf16Aux (s : String) (charIdx : Nat) (bytePos : Nat) (utf16Pos : Nat) : Nat :=
    if bytePos >= utf8Offset then
      utf16Pos
    else if h : charIdx < s.length then
      let c := String.Pos.Raw.get s ⟨charIdx⟩
      let charBytes := c.utf8Size
      let charUtf16 := if c.toNat >= 0x10000 then 2 else 1
      utf8ToUtf16Aux s (charIdx + 1) (bytePos + charBytes) (utf16Pos + charUtf16)
    else
      utf16Pos
  termination_by s.length - charIdx

/-- Convert a UTF-16 offset to a UTF-8 byte offset within a string -/
def utf16OffsetToUtf8 (s : String) (utf16Offset : Nat) : Nat :=
  utf16ToUtf8Aux s 0 0 0
where
  utf16ToUtf8Aux (s : String) (charIdx : Nat) (bytePos : Nat) (utf16Pos : Nat) : Nat :=
    if utf16Pos >= utf16Offset then
      bytePos
    else if h : charIdx < s.length then
      let c := String.Pos.Raw.get s ⟨charIdx⟩
      let charBytes := c.utf8Size
      let charUtf16 := if c.toNat >= 0x10000 then 2 else 1
      utf16ToUtf8Aux s (charIdx + 1) (bytePos + charBytes) (utf16Pos + charUtf16)
    else
      bytePos
  termination_by s.length - charIdx

/-- Get the UTF-8 byte length up to a character index -/
def utf8BytesUpToChar (s : String) (charIdx : Nat) : Nat :=
  bytesUpToCharAux s 0 0
where
  bytesUpToCharAux (s : String) (idx : Nat) (bytes : Nat) : Nat :=
    if idx >= charIdx then
      bytes
    else if idx < s.length then
      let c := String.Pos.Raw.get s ⟨idx⟩
      bytesUpToCharAux s (idx + 1) (bytes + c.utf8Size)
    else
      bytes
  termination_by s.length - idx

/-! ## LSP Position Type -/

/-- LSP Position (0-indexed line and UTF-16 character offset) -/
structure LspPosition where
  line : Nat
  character : Nat  -- UTF-16 code unit offset within line
  deriving Inhabited, Repr, BEq

/-- LSP Range -/
structure LspRange where
  start : LspPosition
  «end» : LspPosition
  deriving Inhabited, Repr, BEq

namespace LspPosition

def zero : LspPosition := ⟨0, 0⟩

end LspPosition

namespace LspRange

def empty : LspRange := ⟨LspPosition.zero, LspPosition.zero⟩

/-- Create a range from a single position (zero-width) -/
def point (pos : LspPosition) : LspRange := ⟨pos, pos⟩

end LspRange

/-! ## Position Conversion Context -/

/-- Context needed for position conversions -/
structure ConversionContext where
  pieceTable : PieceTableState
  lineIndex : LineIndex
  deriving Inhabited

namespace ConversionContext

/-- Get the line content as a string -/
def getLineContent (ctx : ConversionContext) (line : Nat) : Option String :=
  match getLineByteRange ctx.lineIndex line with
  | none => none
  | some (startByte, endByte) =>
    if startByte >= endByte then
      some ""
    else
      some (ctx.pieceTable.getTextByteRange startByte endByte)

/-- Get line content up to (but not including) the newline -/
def getLineContentTrimmed (ctx : ConversionContext) (line : Nat) : Option String :=
  match ctx.getLineContent line with
  | none => none
  | some content =>
    -- Remove trailing newline if present
    if content.endsWith "\n" then
      some (content.dropRight 1)
    else if content.endsWith "\r\n" then
      some (content.dropRight 2)
    else if content.endsWith "\r" then
      some (content.dropRight 1)
    else
      some content

end ConversionContext

/-! ## Position to Byte Offset -/

/-- Convert an LSP position to a byte offset -/
def positionToByteOffset (ctx : ConversionContext) (pos : LspPosition) : Option Nat :=
  -- Get the byte offset of the line start
  match ctx.lineIndex.getLineOffset? pos.line with
  | none => none
  | some lineStartByte =>
    -- Get the line content to convert UTF-16 offset to byte offset
    match ctx.getLineContentTrimmed pos.line with
    | none => some lineStartByte  -- Empty or invalid line, return line start
    | some lineContent =>
      let byteOffsetInLine := utf16OffsetToUtf8 lineContent pos.character
      some (lineStartByte + byteOffsetInLine)

/-- Convert a byte offset to an LSP position -/
def byteOffsetToPosition (ctx : ConversionContext) (byteOffset : Nat) : LspPosition :=
  -- Find which line this offset is on
  let line := findLineForOffset ctx.lineIndex byteOffset

  -- Get the line start byte offset
  let lineStartByte := match ctx.lineIndex.getLineOffset? line with
    | some offset => offset
    | none => 0

  -- Calculate byte offset within the line
  let byteOffsetInLine := byteOffset - lineStartByte

  -- Get line content and convert to UTF-16
  let character := match ctx.getLineContentTrimmed line with
    | none => 0
    | some lineContent =>
      -- Convert the byte offset within line to UTF-16 units
      utf8OffsetToUtf16 lineContent byteOffsetInLine

  ⟨line, character⟩

/-! ## Range Conversions -/

/-- Convert an LSP range to a byte range -/
def rangeToByteRange (ctx : ConversionContext) (range : LspRange) : Option (Nat × Nat) :=
  match positionToByteOffset ctx range.start, positionToByteOffset ctx range.end with
  | some startByte, some endByte => some (startByte, endByte)
  | _, _ => none

/-- Convert a byte range to an LSP range -/
def byteRangeToRange (ctx : ConversionContext) (startByte endByte : Nat) : LspRange :=
  let startPos := byteOffsetToPosition ctx startByte
  let endPos := byteOffsetToPosition ctx endByte
  ⟨startPos, endPos⟩

/-! ## Offset Utilities -/

/-- Clamp a byte offset to valid document bounds -/
def clampOffset (ctx : ConversionContext) (offset : Nat) : Nat :=
  min offset ctx.pieceTable.byteLength

/-- Check if a position is valid for the document -/
def isValidPosition (ctx : ConversionContext) (pos : LspPosition) : Bool :=
  pos.line < ctx.lineIndex.lineCount &&
  match positionToByteOffset ctx pos with
  | some offset => offset <= ctx.pieceTable.byteLength
  | none => false

/-- Get the position at the end of the document -/
def endPosition (ctx : ConversionContext) : LspPosition :=
  byteOffsetToPosition ctx ctx.pieceTable.byteLength

/-- Get the position at the end of a specific line -/
def endOfLine (ctx : ConversionContext) (line : Nat) : Option LspPosition :=
  match ctx.getLineContentTrimmed line with
  | none => none
  | some content =>
    some ⟨line, utf16Length content⟩

end Lapis.VFS.Position
