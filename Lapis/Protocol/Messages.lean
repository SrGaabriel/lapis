/-
  LSP 3.17 Message Types
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
-/
import Lean.Data.Json
import Lapis.Protocol.Types
import Lapis.Protocol.Capabilities
import Lapis.Protocol.Generated

namespace Lapis.Protocol.Messages

open Lean Json
open Lapis.Protocol.Types
open Lapis.Protocol.Capabilities

abbrev ServerInfo := Lapis.Protocol.Generated.ServerInfo

structure DidOpenTextDocumentParams where
  textDocument : TextDocumentItem
  deriving Inhabited

instance : ToJson DidOpenTextDocumentParams where
  toJson p := Json.mkObj [("textDocument", toJson p.textDocument)]

instance : FromJson DidOpenTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentItem "textDocument"
    return { textDocument }
abbrev DidCloseTextDocumentParams := Lapis.Protocol.Generated.DidCloseTextDocumentParams
abbrev DidSaveTextDocumentParams := Lapis.Protocol.Generated.DidSaveTextDocumentParams
abbrev HoverParams := Lapis.Protocol.Generated.HoverParams
abbrev CompletionTriggerKind := Lapis.Protocol.Generated.CompletionTriggerKind
abbrev CompletionContext := Lapis.Protocol.Generated.CompletionContext
abbrev CompletionParams := Lapis.Protocol.Generated.CompletionParams
abbrev CompletionItemKind := Lapis.Protocol.Generated.CompletionItemKind
abbrev ConfigurationItem := Lapis.Protocol.Generated.ConfigurationItem
abbrev ConfigurationParams := Lapis.Protocol.Generated.ConfigurationParams
abbrev ReferenceContext := Lapis.Protocol.Generated.ReferenceContext

structure InitializeParams where
  processId : Option Int := none
  rootUri : Option DocumentUri := none
  capabilities : ClientCapabilities := {}
  trace : Option String := none  -- "off" | "messages" | "verbose"
  deriving Inhabited

instance : ToJson InitializeParams where
  toJson p := Json.mkObj <|
    (match p.processId with | some pid => [("processId", toJson pid)] | none => [("processId", Json.null)]) ++
    (match p.rootUri with | some uri => [("rootUri", toJson uri)] | none => [("rootUri", Json.null)]) ++
    [("capabilities", toJson p.capabilities)] ++
    (match p.trace with | some t => [("trace", toJson t)] | none => [])

instance : FromJson InitializeParams where
  fromJson? json := do
    let processId := (json.getObjValAs? Int "processId").toOption
    let rootUri := (json.getObjValAs? DocumentUri "rootUri").toOption
    let capabilities ← json.getObjValAs? ClientCapabilities "capabilities" <|> pure {}
    let trace := (json.getObjValAs? String "trace").toOption
    return { processId, rootUri, capabilities, trace }

structure InitializeResult where
  capabilities : ServerCapabilities
  serverInfo : Option ServerInfo := none
  deriving Inhabited

instance : ToJson InitializeResult where
  toJson r := Json.mkObj <|
    [("capabilities", toJson r.capabilities)] ++
    (match r.serverInfo with | some s => [("serverInfo", toJson s)] | none => [])

instance : FromJson InitializeResult where
  fromJson? json := do
    let capabilities ← json.getObjValAs? ServerCapabilities "capabilities"
    let serverInfo := (json.getObjValAs? ServerInfo "serverInfo").toOption
    return { capabilities, serverInfo }

structure TextDocumentContentChangeEvent where
  range : Option Range := none
  text : String
  deriving Inhabited

instance : ToJson TextDocumentContentChangeEvent where
  toJson e := Json.mkObj <|
    (match e.range with | some r => [("range", toJson r)] | none => []) ++
    [("text", toJson e.text)]

instance : FromJson TextDocumentContentChangeEvent where
  fromJson? json := do
    let range := (json.getObjValAs? Range "range").toOption
    let text ← json.getObjValAs? String "text"
    return { range, text }

structure DidChangeTextDocumentParams where
  textDocument : VersionedTextDocumentIdentifier
  contentChanges : Array TextDocumentContentChangeEvent
  deriving Inhabited

instance : ToJson DidChangeTextDocumentParams where
  toJson p := Json.mkObj
    [("textDocument", toJson p.textDocument),
     ("contentChanges", toJson p.contentChanges)]

instance : FromJson DidChangeTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? VersionedTextDocumentIdentifier "textDocument"
    let contentChanges ← json.getObjValAs? (Array TextDocumentContentChangeEvent) "contentChanges"
    return { textDocument, contentChanges }

structure Hover where
  contents : MarkupContent
  range : Option Range := none
  deriving Inhabited

instance : ToJson Hover where
  toJson h := Json.mkObj <|
    [("contents", toJson h.contents)] ++
    (match h.range with | some r => [("range", toJson r)] | none => [])

instance : FromJson Hover where
  fromJson? json := do
    let contents ← json.getObjValAs? MarkupContent "contents"
    let range := (json.getObjValAs? Range "range").toOption
    return { contents, range }

structure PublishDiagnosticsParams where
  uri : DocumentUri
  version : Option Int := none
  diagnostics : Array Diagnostic
  deriving Inhabited

instance : ToJson PublishDiagnosticsParams where
  toJson p := Json.mkObj <|
    [("uri", toJson p.uri)] ++
    (match p.version with | some v => [("version", toJson v)] | none => []) ++
    [("diagnostics", toJson p.diagnostics)]

instance : FromJson PublishDiagnosticsParams where
  fromJson? json := do
    let uri ← json.getObjValAs? DocumentUri "uri"
    let version := (json.getObjValAs? Int "version").toOption
    let diagnostics ← json.getObjValAs? (Array Diagnostic) "diagnostics"
    return { uri, version, diagnostics }

structure CompletionItem where
  label : String
  kind : Option CompletionItemKind := none
  detail : Option String := none
  documentation : Option MarkupContent := none
  insertText : Option String := none
  deriving Inhabited

instance : ToJson CompletionItem where
  toJson c := Json.mkObj <|
    [("label", toJson c.label)] ++
    (match c.kind with | some k => [("kind", toJson k)] | none => []) ++
    (match c.detail with | some d => [("detail", toJson d)] | none => []) ++
    (match c.documentation with | some d => [("documentation", toJson d)] | none => []) ++
    (match c.insertText with | some t => [("insertText", toJson t)] | none => [])

instance : FromJson CompletionItem where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let kind := (json.getObjValAs? CompletionItemKind "kind").toOption
    let detail := (json.getObjValAs? String "detail").toOption
    let documentation := (json.getObjValAs? MarkupContent "documentation").toOption
    let insertText := (json.getObjValAs? String "insertText").toOption
    return { label, kind, detail, documentation, insertText }

structure CompletionList where
  isIncomplete : Bool
  items : Array CompletionItem
  deriving Inhabited

instance : ToJson CompletionList where
  toJson c := Json.mkObj
    [("isIncomplete", toJson c.isIncomplete), ("items", toJson c.items)]

instance : FromJson CompletionList where
  fromJson? json := do
    let isIncomplete ← json.getObjValAs? Bool "isIncomplete"
    let items ← json.getObjValAs? (Array CompletionItem) "items"
    return { isIncomplete, items }

abbrev DefinitionParams := TextDocumentPositionParams

structure ReferenceParams where
  textDocument : TextDocumentIdentifier
  position : Position
  context : ReferenceContext
  deriving Inhabited

instance : ToJson ReferenceParams where
  toJson r := Json.mkObj
    [("textDocument", toJson r.textDocument),
     ("position", toJson r.position),
     ("context", toJson r.context)]

instance : FromJson ReferenceParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let context ← json.getObjValAs? ReferenceContext "context"
    return { textDocument, position, context }

/-- Parameters for workspace/didChangeConfiguration notification -/
structure DidChangeConfigurationParams (ConfigType : Type) where
  settings : ConfigType

instance [ToJson ConfigType] : ToJson (DidChangeConfigurationParams ConfigType) where
  toJson p := Json.mkObj [("settings", toJson p.settings)]

instance [FromJson ConfigType] : FromJson (DidChangeConfigurationParams ConfigType) where
  fromJson? json := do
    let settings ← json.getObjValAs? ConfigType "settings"
    return { settings }

end Lapis.Protocol.Messages
