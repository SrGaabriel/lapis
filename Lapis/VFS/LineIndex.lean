/-
  Maintains a mapping from line numbers to byte offsets for efficient
  position conversions. Uses a finger tree with delta-based line entries
  for O(log n) updates and lookups.

  Each entry stores the byte length of a line (including the newline).
  The measure tracks cumulative bytes and line count, enabling O(log n)
  position lookups via tree splitting.
-/

import Lapis.VFS.FingerTree

namespace Lapis.VFS.LineIndex

open FingerTree

/-- A line entry stores the byte length of a single line (including newline if present) -/
structure LineEntry where
  byteLength : Nat  -- Length of this line in bytes (including \n if present)
  deriving Inhabited, Repr

instance : Measurable LineEntry where
  measure entry := {
    bytes := entry.byteLength
    utf16Units := 0  -- Not used for line index
    lines := 1       -- Each entry represents one line
  }

/-- Line index using a finger tree of line entries -/
structure LineIndex where
  /-- Finger tree of line entries, one per line -/
  lines : FingerTree LineEntry
  /-- Total byte length of the document -/
  docLength : Nat
  deriving Inhabited

namespace LineIndex

/-- Create an empty line index (single empty line) -/
def empty : LineIndex :=
  { lines := .single ⟨0⟩
    docLength := 0
  }

/-- Get the number of lines -/
def lineCount (idx : LineIndex) : Nat := idx.lines.measure.lines

/-- Check if a line number is valid -/
def isValidLine (idx : LineIndex) (line : Nat) : Bool :=
  line < idx.lineCount

/-- Build a complete line index from document content -/
def build (content : String) : LineIndex :=
  let entries := buildEntries content 0 0 #[]
  let tree := FingerTree.fromArray entries
  { lines := tree
    docLength := content.utf8ByteSize
  }
where
  buildEntries (s : String) (pos : Nat) (lineStart : Nat) (acc : Array LineEntry) : Array LineEntry :=
    if h : pos < s.length then
      let c := String.Pos.Raw.get s ⟨pos⟩
      let charSize := c.utf8Size
      if c == '\n' then
        let lineLen := pos - lineStart + charSize
        buildEntries s (pos + 1) (pos + charSize) (acc.push ⟨lineLen⟩)
      else
        buildEntries s (pos + 1) lineStart acc
    else
      -- Last line (may not end with newline)
      let lineLen := s.utf8ByteSize - lineStart
      acc.push ⟨lineLen⟩
  termination_by s.length - pos

/-- Get byte offset for the start of a line - O(log n) -/
def getLineOffset? (idx : LineIndex) (line : Nat) : Option Nat :=
  if line == 0 then
    some 0
  else if line >= idx.lineCount then
    none
  else
    -- Split at line number to get cumulative bytes before this line
    match idx.lines.splitAtLine line with
    | none => none
    | some ⟨left, _, _⟩ => some left.measure.bytes

/-- Get the byte range for a line - O(log n) -/
def getLineByteRange (idx : LineIndex) (line : Nat) : Option (Nat × Nat) :=
  if line >= idx.lineCount then
    none
  else if line == 0 then
    match FingerTree.viewL idx.lines with
    | .nil => none
    | .cons entry _ => some (0, entry.byteLength)
  else
    match idx.lines.splitAtLine line with
    | none => none
    | some ⟨left, entry, _⟩ =>
      let startOffset := left.measure.bytes
      some (startOffset, startOffset + entry.byteLength)

/-- Find which line a byte offset falls on - O(log n) -/
def findLineForOffset (idx : LineIndex) (byteOffset : Nat) : Nat :=
  if byteOffset == 0 then
    0
  else if byteOffset >= idx.docLength then
    idx.lineCount - 1
  else
    match idx.lines.splitAtBytes byteOffset with
    | none => 0
    | some ⟨left, _, _⟩ =>
      -- The number of complete lines before this point
      let linesBefore := left.measure.lines
      -- Check if we're exactly at a line boundary
      if left.measure.bytes == byteOffset then
        linesBefore
      else
        linesBefore

/-- Find byte offsets of newlines in a string, returning line lengths -/
private def findLineLengths (s : String) : Array Nat :=
  findLineLengthsAux s 0 0 #[]
where
  findLineLengthsAux (s : String) (pos : Nat) (lineStart : Nat) (acc : Array Nat) : Array Nat :=
    if h : pos < s.length then
      let c := String.Pos.Raw.get s ⟨pos⟩
      let charSize := c.utf8Size
      if c == '\n' then
        let lineLen := pos - lineStart + charSize
        findLineLengthsAux s (pos + 1) (pos + charSize) (acc.push lineLen)
      else
        findLineLengthsAux s (pos + 1) lineStart acc
    else
      let remaining := s.utf8ByteSize - lineStart
      if remaining > 0 then
        acc.push remaining
      else
        acc
  termination_by s.length - pos

/--
Apply an incremental edit to the line index - O(log n)

Parameters:
- `startByte`: byte offset where the edit starts
- `oldLength`: number of bytes removed (0 for pure insert)
- `newText`: the text being inserted
- `newDocLength`: total document length after the edit
-/
def applyEdit (idx : LineIndex) (startByte : Nat) (oldLength : Nat) (newText : String) (newDocLength : Nat) : LineIndex :=
  let endByte := startByte + oldLength
  let newTextLen := newText.utf8ByteSize

  -- Find the line containing startByte
  let startLine := idx.findLineForOffset startByte
  let endLine := idx.findLineForOffset (if endByte > 0 then endByte - 1 else 0)

  -- Get the byte offset of the start line
  let startLineOffset := match idx.getLineOffset? startLine with
    | some o => o
    | none => 0

  -- Get the byte offset of the line after endLine
  let endLineEnd := match idx.getLineByteRange endLine with
    | some (_, e) => e
    | none => idx.docLength

  -- Calculate what text remains from affected lines
  let prefixLen := startByte - startLineOffset  -- bytes before edit on start line
  let suffixLen := endLineEnd - endByte         -- bytes after edit on end line

  -- Build new line entries for the edited region
  let newLineLengths := findLineLengths newText

  -- Combine: prefix + new text + suffix becomes new lines
  let newEntries : Array LineEntry :=
    if newLineLengths.isEmpty then
      -- No newlines in new text, combine prefix + newText + suffix into one line
      #[⟨prefixLen + newTextLen + suffixLen⟩]
    else
      -- First new line includes prefix
      let firstLen := prefixLen + newLineLengths[0]!
      let middleEntries := newLineLengths.extract 1 (newLineLengths.size - 1)
      let lastIdx := newLineLengths.size - 1
      let lastLen := newLineLengths[lastIdx]! + suffixLen

      if newLineLengths.size == 1 then
        #[⟨firstLen + suffixLen⟩]
      else
        let first := #[⟨firstLen⟩]
        let middle := middleEntries.map (⟨·⟩)
        let last := #[⟨lastLen⟩]
        first ++ middle ++ last

  -- Split tree at startLine, remove lines startLine..endLine, insert new entries
  let newLines := rebuildTree idx.lines startLine endLine newEntries

  { lines := newLines
    docLength := newDocLength
  }
where
  rebuildTree (tree : FingerTree LineEntry) (startLine endLine : Nat) (newEntries : Array LineEntry) : FingerTree LineEntry :=
    -- Get lines before startLine
    let beforeStart :=
      if startLine == 0 then
        FingerTree.empty
      else
        match tree.splitAtLine startLine with
        | none => FingerTree.empty
        | some ⟨left, _, _⟩ => left

    -- Get lines after endLine
    let afterEnd :=
      if endLine + 1 >= tree.measure.lines then
        FingerTree.empty
      else
        match tree.splitAtLine (endLine + 1) with
        | none => FingerTree.empty
        | some ⟨_, pivot, right⟩ => FingerTree.cons pivot right

    -- Build new tree
    let newMiddle := FingerTree.fromArray newEntries
    beforeStart ++ newMiddle ++ afterEnd

end LineIndex

end Lapis.VFS.LineIndex
