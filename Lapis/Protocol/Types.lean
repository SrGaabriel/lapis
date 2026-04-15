/-
  LSP 3.17 Base Types
  Re-exported from Generated with custom wrappers.
-/
import Lean.Data.Json
import Lapis.Protocol.Generated

namespace Lapis.Protocol.Types

open Lean Json

abbrev DocumentUri := String
abbrev Position := Lapis.Protocol.Generated.Position
abbrev Range := Lapis.Protocol.Generated.Range
abbrev Location := Lapis.Protocol.Generated.Location
abbrev LocationLink := Lapis.Protocol.Generated.LocationLink
abbrev TextDocumentIdentifier := Lapis.Protocol.Generated.TextDocumentIdentifier
abbrev VersionedTextDocumentIdentifier := Lapis.Protocol.Generated.VersionedTextDocumentIdentifier
structure TextDocumentItem where
  uri : DocumentUri
  languageId : String
  version : Int
  text : String
  deriving Inhabited

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
abbrev TextDocumentPositionParams := Lapis.Protocol.Generated.TextDocumentPositionParams
abbrev TextEdit := Lapis.Protocol.Generated.TextEdit
abbrev DiagnosticSeverity := Lapis.Protocol.Generated.DiagnosticSeverity
abbrev DiagnosticTag := Lapis.Protocol.Generated.DiagnosticTag
abbrev DiagnosticRelatedInformation := Lapis.Protocol.Generated.DiagnosticRelatedInformation
abbrev MarkupKind := Lapis.Protocol.Generated.MarkupKind
abbrev MarkupContent := Lapis.Protocol.Generated.MarkupContent

instance : Ord Position where
  compare a b :=
    match compare a.line b.line with
    | .eq => compare a.character b.character
    | ord => ord

structure Diagnostic where
  range : Range
  severity : Option DiagnosticSeverity := none
  code : Option String := none
  source : Option String := none
  message : String
  tags : Option (Array DiagnosticTag) := none
  relatedInformation : Option (Array DiagnosticRelatedInformation) := none
  deriving Inhabited

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

structure WorkDoneProgressParams where
  workDoneToken : Option String := none
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
