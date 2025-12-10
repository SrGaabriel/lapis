/-
  LSP 3.17 Message Types
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
-/
import Lapis.Protocol.Types
import Lapis.Protocol.Capabilities

namespace Lapis.Protocol.Messages

open Lean Json
open Lapis.Protocol.Types
open Lapis.Protocol.Capabilities

structure InitializeParams where
  processId : Option Int := none
  rootUri : Option DocumentUri := none
  capabilities : ClientCapabilities := {}
  trace : Option String := none  -- "off" | "messages" | "verbose"
  deriving Inhabited, Repr

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

structure ServerInfo where
  name : String
  version : Option String := none
  deriving Inhabited, Repr

instance : ToJson ServerInfo where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    (match s.version with | some v => [("version", toJson v)] | none => [])

instance : FromJson ServerInfo where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let version := (json.getObjValAs? String "version").toOption
    return { name, version }

structure InitializeResult where
  capabilities : ServerCapabilities
  serverInfo : Option ServerInfo := none
  deriving Inhabited, Repr

instance : ToJson InitializeResult where
  toJson r := Json.mkObj <|
    [("capabilities", toJson r.capabilities)] ++
    (match r.serverInfo with | some s => [("serverInfo", toJson s)] | none => [])

instance : FromJson InitializeResult where
  fromJson? json := do
    let capabilities ← json.getObjValAs? ServerCapabilities "capabilities"
    let serverInfo := (json.getObjValAs? ServerInfo "serverInfo").toOption
    return { capabilities, serverInfo }

structure DidOpenTextDocumentParams where
  textDocument : TextDocumentItem
  deriving Inhabited, Repr

instance : ToJson DidOpenTextDocumentParams where
  toJson p := Json.mkObj [("textDocument", toJson p.textDocument)]

instance : FromJson DidOpenTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentItem "textDocument"
    return { textDocument }

structure TextDocumentContentChangeEvent where
  range : Option Range := none
  text : String
  deriving Inhabited, Repr

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
  deriving Inhabited, Repr

instance : ToJson DidChangeTextDocumentParams where
  toJson p := Json.mkObj
    [("textDocument", toJson p.textDocument),
     ("contentChanges", toJson p.contentChanges)]

instance : FromJson DidChangeTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? VersionedTextDocumentIdentifier "textDocument"
    let contentChanges ← json.getObjValAs? (Array TextDocumentContentChangeEvent) "contentChanges"
    return { textDocument, contentChanges }

structure DidCloseTextDocumentParams where
  textDocument : TextDocumentIdentifier
  deriving Inhabited, Repr

instance : ToJson DidCloseTextDocumentParams where
  toJson p := Json.mkObj [("textDocument", toJson p.textDocument)]

instance : FromJson DidCloseTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { textDocument }

structure DidSaveTextDocumentParams where
  textDocument : TextDocumentIdentifier
  text : Option String := none
  deriving Inhabited, Repr

instance : ToJson DidSaveTextDocumentParams where
  toJson p := Json.mkObj <|
    [("textDocument", toJson p.textDocument)] ++
    (match p.text with | some t => [("text", toJson t)] | none => [])

instance : FromJson DidSaveTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let text := (json.getObjValAs? String "text").toOption
    return { textDocument, text }

structure HoverParams where
  textDocument : TextDocumentIdentifier
  position : Position
  deriving Inhabited, Repr

instance : ToJson HoverParams where
  toJson p := Json.mkObj
    [("textDocument", toJson p.textDocument), ("position", toJson p.position)]

instance : FromJson HoverParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    return { textDocument, position }

structure Hover where
  contents : MarkupContent
  range : Option Range := none
  deriving Inhabited, Repr

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
  deriving Inhabited, Repr

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

inductive CompletionTriggerKind where
  | invoked
  | triggerCharacter
  | triggerForIncompleteCompletions
  deriving Inhabited, BEq, Repr

instance : ToJson CompletionTriggerKind where
  toJson
    | .invoked => 1
    | .triggerCharacter => 2
    | .triggerForIncompleteCompletions => 3

instance : FromJson CompletionTriggerKind where
  fromJson? json := do
    let n ← json.getNat?
    match n with
    | 1 => return .invoked
    | 2 => return .triggerCharacter
    | 3 => return .triggerForIncompleteCompletions
    | _ => throw s!"Invalid CompletionTriggerKind: {n}"

structure CompletionContext where
  triggerKind : CompletionTriggerKind
  triggerCharacter : Option String := none
  deriving Inhabited, Repr

instance : ToJson CompletionContext where
  toJson c := Json.mkObj <|
    [("triggerKind", toJson c.triggerKind)] ++
    (match c.triggerCharacter with | some t => [("triggerCharacter", toJson t)] | none => [])

instance : FromJson CompletionContext where
  fromJson? json := do
    let triggerKind ← json.getObjValAs? CompletionTriggerKind "triggerKind"
    let triggerCharacter := (json.getObjValAs? String "triggerCharacter").toOption
    return { triggerKind, triggerCharacter }

structure CompletionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  context : Option CompletionContext := none
  deriving Inhabited, Repr

instance : ToJson CompletionParams where
  toJson p := Json.mkObj <|
    [("textDocument", toJson p.textDocument), ("position", toJson p.position)] ++
    (match p.context with | some c => [("context", toJson c)] | none => [])

instance : FromJson CompletionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let context := (json.getObjValAs? CompletionContext "context").toOption
    return { textDocument, position, context }

inductive CompletionItemKind where
  | text | method | function | constructor | field | variable
  | class_ | interface | module | property | unit | value
  | enum | keyword | snippet | color | file | reference
  | folder | enumMember | constant | struct | event | operator | typeParameter
  deriving Inhabited, BEq, Repr

instance : ToJson CompletionItemKind where
  toJson k := match k with
    | .text => 1 | .method => 2 | .function => 3 | .constructor => 4
    | .field => 5 | .variable => 6 | .class_ => 7 | .interface => 8
    | .module => 9 | .property => 10 | .unit => 11 | .value => 12
    | .enum => 13 | .keyword => 14 | .snippet => 15 | .color => 16
    | .file => 17 | .reference => 18 | .folder => 19 | .enumMember => 20
    | .constant => 21 | .struct => 22 | .event => 23 | .operator => 24
    | .typeParameter => 25

instance : FromJson CompletionItemKind where
  fromJson? json := do
    let n ← json.getNat?
    match n with
    | 1 => return .text | 2 => return .method | 3 => return .function
    | 4 => return .constructor | 5 => return .field | 6 => return .variable
    | 7 => return .class_ | 8 => return .interface | 9 => return .module
    | 10 => return .property | 11 => return .unit | 12 => return .value
    | 13 => return .enum | 14 => return .keyword | 15 => return .snippet
    | 16 => return .color | 17 => return .file | 18 => return .reference
    | 19 => return .folder | 20 => return .enumMember | 21 => return .constant
    | 22 => return .struct | 23 => return .event | 24 => return .operator
    | 25 => return .typeParameter
    | _ => throw s!"Invalid CompletionItemKind: {n}"

structure CompletionItem where
  label : String
  kind : Option CompletionItemKind := none
  detail : Option String := none
  documentation : Option MarkupContent := none
  insertText : Option String := none
  deriving Inhabited, Repr

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
  deriving Inhabited, Repr

instance : ToJson CompletionList where
  toJson c := Json.mkObj
    [("isIncomplete", toJson c.isIncomplete), ("items", toJson c.items)]

instance : FromJson CompletionList where
  fromJson? json := do
    let isIncomplete ← json.getObjValAs? Bool "isIncomplete"
    let items ← json.getObjValAs? (Array CompletionItem) "items"
    return { isIncomplete, items }

abbrev DefinitionParams := TextDocumentPositionParams

structure ReferenceContext where
  includeDeclaration : Bool
  deriving Inhabited, Repr

instance : ToJson ReferenceContext where
  toJson r := Json.mkObj [("includeDeclaration", toJson r.includeDeclaration)]

instance : FromJson ReferenceContext where
  fromJson? json := do
    let includeDeclaration ← json.getObjValAs? Bool "includeDeclaration"
    return { includeDeclaration }

structure ReferenceParams where
  textDocument : TextDocumentIdentifier
  position : Position
  context : ReferenceContext
  deriving Inhabited, Repr

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

/-- Workspace configuration item -/
structure ConfigurationItem where
  scopeUri : Option DocumentUri := none
  «section» : Option String := none
  deriving Inhabited, Repr

instance : ToJson ConfigurationItem where
  toJson c := Json.mkObj <|
    (match c.scopeUri with | some uri => [("scopeUri", toJson uri)] | none => []) ++
    (match c.«section» with | some s => [("section", toJson s)] | none => [])

instance : FromJson ConfigurationItem where
  fromJson? json := do
    let scopeUri := (json.getObjValAs? DocumentUri "scopeUri").toOption
    let «section» := (json.getObjValAs? String "section").toOption
    return { scopeUri, «section» }

/-- Parameters for workspace/configuration request -/
structure ConfigurationParams where
  items : Array ConfigurationItem
  deriving Inhabited, Repr

instance : ToJson ConfigurationParams where
  toJson p := Json.mkObj [("items", toJson p.items)]

instance : FromJson ConfigurationParams where
  fromJson? json := do
    let items ← json.getObjValAs? (Array ConfigurationItem) "items"
    return { items }

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
