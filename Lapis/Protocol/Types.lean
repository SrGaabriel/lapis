/-
  LSP 3.17 Base Types
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
-/
import Lean.Data.Json

namespace Lapis.Protocol.Types

open Lean Json

abbrev DocumentUri := String

structure Position where
  line : Nat
  character : Nat
  deriving Inhabited, BEq, Repr

instance : ToJson Position where
  toJson p := Json.mkObj [("line", toJson p.line), ("character", toJson p.character)]

instance : FromJson Position where
  fromJson? json := do
    let line ← json.getObjValAs? Nat "line"
    let character ← json.getObjValAs? Nat "character"
    return { line, character }

instance : Ord Position where
  compare a b :=
    match compare a.line b.line with
    | .eq => compare a.character b.character
    | ord => ord

structure Range where
  start : Position
  «end» : Position
  deriving Inhabited, BEq, Repr

instance : ToJson Range where
  toJson r := Json.mkObj [("start", toJson r.start), ("end", toJson r.end)]

instance : FromJson Range where
  fromJson? json := do
    let start ← json.getObjValAs? Position "start"
    let «end» ← json.getObjValAs? Position "end"
    return { start, «end» }

structure Location where
  uri : DocumentUri
  range : Range
  deriving Inhabited, BEq, Repr

instance : ToJson Location where
  toJson l := Json.mkObj [("uri", toJson l.uri), ("range", toJson l.range)]

instance : FromJson Location where
  fromJson? json := do
    let uri ← json.getObjValAs? DocumentUri "uri"
    let range ← json.getObjValAs? Range "range"
    return { uri, range }

structure LocationLink where
  originSelectionRange : Option Range := none
  targetUri : DocumentUri
  targetRange : Range
  targetSelectionRange : Range
  deriving Inhabited, BEq, Repr

instance : ToJson LocationLink where
  toJson l := Json.mkObj <|
    (match l.originSelectionRange with
      | some r => [("originSelectionRange", toJson r)]
      | none => []) ++
    [("targetUri", toJson l.targetUri),
     ("targetRange", toJson l.targetRange),
     ("targetSelectionRange", toJson l.targetSelectionRange)]

instance : FromJson LocationLink where
  fromJson? json := do
    let originSelectionRange := (json.getObjValAs? Range "originSelectionRange").toOption
    let targetUri ← json.getObjValAs? DocumentUri "targetUri"
    let targetRange ← json.getObjValAs? Range "targetRange"
    let targetSelectionRange ← json.getObjValAs? Range "targetSelectionRange"
    return { originSelectionRange, targetUri, targetRange, targetSelectionRange }

structure TextDocumentIdentifier where
  uri : DocumentUri
  deriving Inhabited, BEq, Repr

instance : ToJson TextDocumentIdentifier where
  toJson t := Json.mkObj [("uri", toJson t.uri)]

instance : FromJson TextDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? DocumentUri "uri"
    return { uri }

structure VersionedTextDocumentIdentifier where
  uri : DocumentUri
  version : Int
  deriving Inhabited, BEq, Repr

instance : ToJson VersionedTextDocumentIdentifier where
  toJson t := Json.mkObj [("uri", toJson t.uri), ("version", toJson t.version)]

instance : FromJson VersionedTextDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? DocumentUri "uri"
    let version ← json.getObjValAs? Int "version"
    return { uri, version }

structure TextDocumentItem where
  uri : DocumentUri
  languageId : String
  version : Int
  text : String
  deriving Inhabited, Repr

instance : ToJson TextDocumentItem where
  toJson t := Json.mkObj
    [("uri", toJson t.uri),
     ("languageId", toJson t.languageId),
     ("version", toJson t.version),
     ("text", toJson t.text)]

instance : FromJson TextDocumentItem where
  fromJson? json := do
    let uri ← json.getObjValAs? DocumentUri "uri"
    let languageId ← json.getObjValAs? String "languageId"
    let version ← json.getObjValAs? Int "version"
    let text ← json.getObjValAs? String "text"
    return { uri, languageId, version, text }

structure TextDocumentPositionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  deriving Inhabited, Repr

instance : ToJson TextDocumentPositionParams where
  toJson t := Json.mkObj
    [("textDocument", toJson t.textDocument), ("position", toJson t.position)]

instance : FromJson TextDocumentPositionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    return { textDocument, position }

structure TextEdit where
  range : Range
  newText : String
  deriving Inhabited, Repr

instance : ToJson TextEdit where
  toJson e := Json.mkObj [("range", toJson e.range), ("newText", toJson e.newText)]

instance : FromJson TextEdit where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let newText ← json.getObjValAs? String "newText"
    return { range, newText }

inductive DiagnosticSeverity where
  | error
  | warning
  | information
  | hint
  deriving Inhabited, BEq, Repr

instance : ToJson DiagnosticSeverity where
  toJson
    | .error => 1
    | .warning => 2
    | .information => 3
    | .hint => 4

instance : FromJson DiagnosticSeverity where
  fromJson? json := do
    let n ← json.getNat?
    match n with
    | 1 => return .error
    | 2 => return .warning
    | 3 => return .information
    | 4 => return .hint
    | _ => throw s!"Invalid DiagnosticSeverity: {n}"

inductive DiagnosticTag where
  | unnecessary  -- 1
  | deprecated   -- 2
  deriving Inhabited, BEq, Repr

instance : ToJson DiagnosticTag where
  toJson
    | .unnecessary => 1
    | .deprecated => 2

instance : FromJson DiagnosticTag where
  fromJson? json := do
    let n ← json.getNat?
    match n with
    | 1 => return .unnecessary
    | 2 => return .deprecated
    | _ => throw s!"Invalid DiagnosticTag: {n}"

/-- Diagnostic related information -/
structure DiagnosticRelatedInformation where
  location : Location
  message : String
  deriving Inhabited, Repr

instance : ToJson DiagnosticRelatedInformation where
  toJson d := Json.mkObj [("location", toJson d.location), ("message", toJson d.message)]

instance : FromJson DiagnosticRelatedInformation where
  fromJson? json := do
    let location ← json.getObjValAs? Location "location"
    let message ← json.getObjValAs? String "message"
    return { location, message }

structure Diagnostic where
  range : Range
  severity : Option DiagnosticSeverity := none
  code : Option String := none  -- Can be number or string, we use string
  source : Option String := none
  message : String
  tags : Option (Array DiagnosticTag) := none
  relatedInformation : Option (Array DiagnosticRelatedInformation) := none
  deriving Inhabited, Repr

instance : ToJson Diagnostic where
  toJson d := Json.mkObj <|
    [("range", toJson d.range), ("message", toJson d.message)] ++
    (match d.severity with | some s => [("severity", toJson s)] | none => []) ++
    (match d.code with | some c => [("code", toJson c)] | none => []) ++
    (match d.source with | some s => [("source", toJson s)] | none => []) ++
    (match d.tags with | some t => [("tags", toJson t)] | none => []) ++
    (match d.relatedInformation with | some r => [("relatedInformation", toJson r)] | none => [])

instance : FromJson Diagnostic where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let message ← json.getObjValAs? String "message"
    let severity := (json.getObjValAs? DiagnosticSeverity "severity").toOption
    let code := (json.getObjValAs? String "code").toOption
    let source := (json.getObjValAs? String "source").toOption
    let tags := (json.getObjValAs? (Array DiagnosticTag) "tags").toOption
    let relatedInformation := (json.getObjValAs? (Array DiagnosticRelatedInformation) "relatedInformation").toOption
    return { range, message, severity, code, source, tags, relatedInformation }

inductive MarkupKind where
  | plaintext
  | markdown
  deriving Inhabited, BEq, Repr

instance : ToJson MarkupKind where
  toJson
    | .plaintext => "plaintext"
    | .markdown => "markdown"

instance : FromJson MarkupKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "plaintext" => return .plaintext
    | "markdown" => return .markdown
    | _ => throw s!"Invalid MarkupKind: {s}"

structure MarkupContent where
  kind : MarkupKind
  value : String
  deriving Inhabited, Repr

instance : ToJson MarkupContent where
  toJson m := Json.mkObj [("kind", toJson m.kind), ("value", toJson m.value)]

instance : FromJson MarkupContent where
  fromJson? json := do
    let kind ← json.getObjValAs? MarkupKind "kind"
    let value ← json.getObjValAs? String "value"
    return { kind, value }

structure WorkDoneProgressParams where
  workDoneToken : Option String := none -- Can be number or string
  deriving Inhabited, Repr

instance : ToJson WorkDoneProgressParams where
  toJson w := Json.mkObj <|
    match w.workDoneToken with
    | some t => [("workDoneToken", toJson t)]
    | none => []

instance : FromJson WorkDoneProgressParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? String "workDoneToken").toOption
    return { workDoneToken }

end Lapis.Protocol.Types
