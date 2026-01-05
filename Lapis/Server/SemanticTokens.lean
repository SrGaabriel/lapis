/-
  Semantic Tokens Support
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_semanticTokens
-/
import Lapis.Protocol.Types
import Lapis.Protocol.Generated

namespace Lapis.Server.SemanticTokens

open Lean Json
open Lapis.Protocol.Types
open Lapis.Protocol.Generated

/-! ## Token Types and Modifiers -/

/-- Standard semantic token types as defined by LSP 3.17 -/
def standardTokenTypes : Array String := #[
  "namespace",
  "type",
  "class",
  "enum",
  "interface",
  "struct",
  "typeParameter",
  "parameter",
  "variable",
  "property",
  "enumMember",
  "event",
  "function",
  "method",
  "macro",
  "keyword",
  "modifier",
  "comment",
  "string",
  "number",
  "regexp",
  "operator",
  "decorator",
  "label"
]

/-- Standard semantic token modifiers as defined by LSP 3.17 -/
def standardTokenModifiers : Array String := #[
  "declaration",
  "definition",
  "readonly",
  "static",
  "deprecated",
  "abstract",
  "async",
  "modification",
  "documentation",
  "defaultLibrary"
]

/-- Get the index of a token type in the standard list -/
def tokenTypeIndex (tokenType : SemanticTokenTypes) : Nat :=
  match tokenType with
  | .«namespace» => 0
  | .«type» => 1
  | .«class» => 2
  | .enum => 3
  | .interface => 4
  | .struct => 5
  | .typeParameter => 6
  | .parameter => 7
  | .«variable» => 8
  | .property => 9
  | .enumMember => 10
  | .event => 11
  | .function => 12
  | .method => 13
  | .macro => 14
  | .keyword => 15
  | .modifier => 16
  | .comment => 17
  | .string => 18
  | .number => 19
  | .regexp => 20
  | .operator => 21
  | .decorator => 22
  | .label => 23

/-- Get the bit position of a token modifier in the standard list -/
def tokenModifierBit (modifier : SemanticTokenModifiers) : Nat :=
  match modifier with
  | .declaration => 0
  | .definition => 1
  | .readonly => 2
  | .static => 3
  | .deprecated => 4
  | .abstract => 5
  | .async => 6
  | .modification => 7
  | .documentation => 8
  | .defaultLibrary => 9

/-- Encode multiple modifiers as a bitmask -/
def encodeModifiers (modifiers : Array SemanticTokenModifiers) : Nat :=
  modifiers.foldl (fun acc m => acc ||| (1 <<< tokenModifierBit m)) 0

/-! ## Token Representation -/

/-- A semantic token before encoding.
    Tokens are represented with absolute positions and will be
    converted to relative (delta) encoding when building the response. -/
structure Token where
  /-- Line number (0-indexed) -/
  line : Nat
  /-- Character offset within the line (0-indexed, UTF-16 code units) -/
  character : Nat
  /-- Length of the token in UTF-16 code units -/
  length : Nat
  /-- Index into the token types legend -/
  tokenType : Nat
  /-- Bitmask of token modifiers -/
  tokenModifiers : Nat := 0
  deriving Inhabited, Repr, BEq

namespace Token

/-- Create a token from a SemanticTokenTypes enum -/
def ofType (line character length : Nat) (tokenType : SemanticTokenTypes)
    (modifiers : Array SemanticTokenModifiers := #[]) : Token :=
  { line, character, length
    tokenType := tokenTypeIndex tokenType
    tokenModifiers := encodeModifiers modifiers }

/-- Create a token with a custom type index -/
def ofTypeIndex (line character length typeIndex : Nat)
    (modifierBits : Nat := 0) : Token :=
  { line, character, length
    tokenType := typeIndex
    tokenModifiers := modifierBits }

end Token

/-! ## Token Builder -/

/-- Builder for collecting tokens before encoding -/
structure TokenBuilder where
  /-- Collected tokens (unsorted) -/
  tokens : Array Token
  /-- Token types legend -/
  tokenTypes : Array String
  /-- Token modifiers legend -/
  tokenModifiers : Array String

namespace TokenBuilder

/-- Create a new token builder with standard legends -/
def new : TokenBuilder :=
  { tokens := #[]
    tokenTypes := standardTokenTypes
    tokenModifiers := standardTokenModifiers }

/-- Create a token builder with custom legends -/
def withLegends (tokenTypes tokenModifiers : Array String) : TokenBuilder :=
  { tokens := #[], tokenTypes, tokenModifiers }

/-- Add a token using the SemanticTokenTypes enum -/
def push (b : TokenBuilder) (line character length : Nat)
    (tokenType : SemanticTokenTypes)
    (modifiers : Array SemanticTokenModifiers := #[]) : TokenBuilder :=
  { b with tokens := b.tokens.push (Token.ofType line character length tokenType modifiers) }

/-- Add a token using a custom type index -/
def pushRaw (b : TokenBuilder) (line character length typeIndex : Nat)
    (modifierBits : Nat := 0) : TokenBuilder :=
  { b with tokens := b.tokens.push (Token.ofTypeIndex line character length typeIndex modifierBits) }

/-- Add a pre-constructed token -/
def pushToken (b : TokenBuilder) (token : Token) : TokenBuilder :=
  { b with tokens := b.tokens.push token }

/-- Add multiple tokens -/
def pushTokens (b : TokenBuilder) (tokens : Array Token) : TokenBuilder :=
  { b with tokens := b.tokens ++ tokens }

/-- Get the legend for capability registration -/
def getLegend (b : TokenBuilder) : SemanticTokensLegend :=
  { tokenTypes := b.tokenTypes, tokenModifiers := b.tokenModifiers }

/-- Compare two tokens for sorting (by line, then by character) -/
private def compareTokens (a b : Token) : Ordering :=
  match compare a.line b.line with
  | .eq => compare a.character b.character
  | ord => ord

/-- Sort tokens by position (required before encoding) -/
def sortTokens (tokens : Array Token) : Array Token :=
  tokens.qsort fun a b => compareTokens a b == .lt

/-- Encode tokens to the LSP delta format.
    The LSP semantic tokens format uses relative encoding:
    - Each token is represented as 5 integers
    - [deltaLine, deltaStartChar, length, tokenType, tokenModifiers]
    - deltaLine: line offset from previous token (or from line 0 for first token)
    - deltaStartChar: character offset from previous token's start on same line,
                      or from character 0 if on a different line -/
def encode (b : TokenBuilder) : Array Nat := Id.run do
  let sorted := sortTokens b.tokens
  let mut result : Array Nat := #[]
  let mut prevLine : Nat := 0
  let mut prevChar : Nat := 0

  for token in sorted do
    let deltaLine := token.line - prevLine
    let deltaChar := if deltaLine == 0 then token.character - prevChar else token.character

    result := result.push deltaLine
    result := result.push deltaChar
    result := result.push token.length
    result := result.push token.tokenType
    result := result.push token.tokenModifiers

    prevLine := token.line
    prevChar := token.character

  return result

/-- Build the SemanticTokens response -/
def build (b : TokenBuilder) (resultId : Option String := none) : SemanticTokens :=
  { resultId, data := b.encode }

/-- Check if the builder has any tokens -/
def isEmpty (b : TokenBuilder) : Bool := b.tokens.isEmpty

/-- Get the number of tokens -/
def size (b : TokenBuilder) : Nat := b.tokens.size

end TokenBuilder

/-! ## Semantic Tokens Options Builder -/

/-- Builder for creating SemanticTokensOptions -/
structure OptionsBuilder where
  tokenTypes : Array String
  tokenModifiers : Array String
  full : Bool
  fullDelta : Bool
  range : Bool

namespace OptionsBuilder

/-- Create a new options builder with standard legends -/
def new : OptionsBuilder :=
  { tokenTypes := standardTokenTypes
    tokenModifiers := standardTokenModifiers
    full := true
    fullDelta := false
    range := false }

/-- Use custom token types -/
def withTokenTypes (b : OptionsBuilder) (types : Array String) : OptionsBuilder :=
  { b with tokenTypes := types }

/-- Use custom token modifiers -/
def withTokenModifiers (b : OptionsBuilder) (modifiers : Array String) : OptionsBuilder :=
  { b with tokenModifiers := modifiers }

/-- Add custom token types to the standard list -/
def addTokenTypes (b : OptionsBuilder) (types : Array String) : OptionsBuilder :=
  { b with tokenTypes := b.tokenTypes ++ types }

/-- Add custom token modifiers to the standard list -/
def addTokenModifiers (b : OptionsBuilder) (modifiers : Array String) : OptionsBuilder :=
  { b with tokenModifiers := b.tokenModifiers ++ modifiers }

/-- Enable full document semantic tokens -/
def enableFull (b : OptionsBuilder) (delta : Bool := false) : OptionsBuilder :=
  { b with full := true, fullDelta := delta }

/-- Disable full document semantic tokens -/
def disableFull (b : OptionsBuilder) : OptionsBuilder :=
  { b with full := false, fullDelta := false }

/-- Enable range-based semantic tokens -/
def enableRange (b : OptionsBuilder) : OptionsBuilder :=
  { b with range := true }

/-- Disable range-based semantic tokens -/
def disableRange (b : OptionsBuilder) : OptionsBuilder :=
  { b with range := false }

/-- Build the SemanticTokensOptions -/
def build (b : OptionsBuilder) : SemanticTokensOptions :=
  let legend : SemanticTokensLegend :=
    { tokenTypes := b.tokenTypes, tokenModifiers := b.tokenModifiers }
  let full : Json :=
    if b.full then
      if b.fullDelta then
        toJson ({ delta := some true : SemanticTokensFullDelta })
      else
        Json.bool true
    else
      Json.bool false
  let range : Json := Json.bool b.range
  { legend, full, range }

end OptionsBuilder

/-! ## Convenience Functions -/

/-- Create default SemanticTokensOptions with full document support -/
def defaultOptions : SemanticTokensOptions :=
  OptionsBuilder.new.build

/-- Create SemanticTokensOptions with full and range support -/
def fullAndRangeOptions : SemanticTokensOptions :=
  OptionsBuilder.new.enableRange.build

/-- Create SemanticTokensOptions with delta support -/
def deltaOptions : SemanticTokensOptions :=
  OptionsBuilder.new.enableFull (delta := true).build

/-- Create an empty SemanticTokens response -/
def emptyTokens (resultId : Option String := none) : SemanticTokens :=
  { resultId, data := #[] }

/-- Method name for full semantic tokens request -/
def fullMethod : String := SemanticTokensRequestMethod

/-- Method name for delta semantic tokens request -/
def deltaMethod : String := SemanticTokensDeltaRequestMethod

/-- Method name for range semantic tokens request -/
def rangeMethod : String := SemanticTokensRangeRequestMethod

/-- Method name for semantic tokens refresh request -/
def refreshMethod : String := SemanticTokensRefreshRequestMethod

end Lapis.Server.SemanticTokens
