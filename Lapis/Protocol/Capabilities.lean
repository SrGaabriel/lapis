/-
  LSP 3.17 Capabilities
  https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
-/
import Lapis.Protocol.Types
import Lapis.Protocol.Generated

namespace Lapis.Protocol.Capabilities

open Lean Json
open Lapis.Protocol.Types
open Lapis.Protocol.Generated

/-- How documents are synced to the server -/
inductive TextDocumentSyncKind where
  | none       -- 0
  | full       -- 1: Full content sent on each change
  | incremental -- 2: Incremental changes sent
  deriving Inhabited, BEq, Repr

instance : ToJson TextDocumentSyncKind where
  toJson
    | .none => 0
    | .full => 1
    | .incremental => 2

instance : FromJson TextDocumentSyncKind where
  fromJson? json := do
    let n ← json.getNat?
    match n with
    | 0 => return .none
    | 1 => return .full
    | 2 => return .incremental
    | _ => throw s!"Invalid TextDocumentSyncKind: {n}"

structure SaveOptions where
  includeText : Option Bool := none
  deriving Inhabited, Repr

instance : ToJson SaveOptions where
  toJson s := Json.mkObj <|
    match s.includeText with
    | some b => [("includeText", toJson b)]
    | none => []

instance : FromJson SaveOptions where
  fromJson? json := do
    let includeText := (json.getObjValAs? Bool "includeText").toOption
    return { includeText }

structure TextDocumentSyncOptions where
  openClose : Option Bool := none
  change : Option TextDocumentSyncKind := none
  save : Option SaveOptions := none
  deriving Inhabited, Repr

instance : ToJson TextDocumentSyncOptions where
  toJson s := Json.mkObj <|
    (match s.openClose with | some b => [("openClose", toJson b)] | none => []) ++
    (match s.change with | some c => [("change", toJson c)] | none => []) ++
    (match s.save with | some sv => [("save", toJson sv)] | none => [])

instance : FromJson TextDocumentSyncOptions where
  fromJson? json := do
    let openClose := (json.getObjValAs? Bool "openClose").toOption
    let change := (json.getObjValAs? TextDocumentSyncKind "change").toOption
    let save := (json.getObjValAs? SaveOptions "save").toOption
    return { openClose, change, save }

structure CompletionOptions where
  triggerCharacters : Option (Array String) := none
  resolveProvider : Option Bool := none
  deriving Inhabited, Repr

instance : ToJson CompletionOptions where
  toJson c := Json.mkObj <|
    (match c.triggerCharacters with | some t => [("triggerCharacters", toJson t)] | none => []) ++
    (match c.resolveProvider with | some r => [("resolveProvider", toJson r)] | none => [])

instance : FromJson CompletionOptions where
  fromJson? json := do
    let triggerCharacters := (json.getObjValAs? (Array String) "triggerCharacters").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { triggerCharacters, resolveProvider }

structure HoverOptions where
  workDoneProgress : Option Bool := none
  deriving Inhabited, Repr

instance : ToJson HoverOptions where
  toJson h := Json.mkObj <|
    match h.workDoneProgress with
    | some b => [("workDoneProgress", toJson b)]
    | none => []

instance : FromJson HoverOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure TypeDefinitionOptions where
  workDoneProgress : Option Bool := none
  deriving Inhabited, Repr

instance : ToJson TypeDefinitionOptions where
  toJson t := Json.mkObj <|
    match t.workDoneProgress with
    | some b => [("workDoneProgress", toJson b)]
    | none => []

instance : FromJson TypeDefinitionOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure InlayHintOptions where
  workDoneProgress : Option Bool := none
  resolveProvider : Option Bool := none
  deriving Inhabited, Repr

instance : ToJson InlayHintOptions where
  toJson i := Json.mkObj <|
    (match i.workDoneProgress with | some b => [("workDoneProgress", toJson b)] | none => []) ++
    (match i.resolveProvider with | some r => [("resolveProvider", toJson r)] | none => [])

instance : FromJson InlayHintOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, resolveProvider }

structure ServerCapabilities where
  textDocumentSync : Option TextDocumentSyncOptions := none
  completionProvider : Option CompletionOptions := none
  hoverProvider : Option Bool := none
  definitionProvider : Option Bool := none
  typeDefinitionProvider : Option TypeDefinitionOptions := none
  referencesProvider : Option Bool := none
  documentSymbolProvider : Option Bool := none
  workspaceSymbolProvider : Option Bool := none
  codeActionProvider : Option Bool := none
  documentFormattingProvider : Option Bool := none
  renameProvider : Option Bool := none
  inlayHintProvider : Option InlayHintOptions := none
  semanticTokensProvider : Option SemanticTokensOptions := none
  deriving Inhabited

instance : ToJson ServerCapabilities where
  toJson s := Json.mkObj <|
    (match s.textDocumentSync with | some t => [("textDocumentSync", toJson t)] | none => []) ++
    (match s.completionProvider with | some c => [("completionProvider", toJson c)] | none => []) ++
    (match s.hoverProvider with | some h => [("hoverProvider", toJson h)] | none => []) ++
    (match s.definitionProvider with | some d => [("definitionProvider", toJson d)] | none => []) ++
    (match s.typeDefinitionProvider with | some t => [("typeDefinitionProvider", toJson t)] | none => []) ++
    (match s.referencesProvider with | some r => [("referencesProvider", toJson r)] | none => []) ++
    (match s.documentSymbolProvider with | some d => [("documentSymbolProvider", toJson d)] | none => []) ++
    (match s.workspaceSymbolProvider with | some w => [("workspaceSymbolProvider", toJson w)] | none => []) ++
    (match s.codeActionProvider with | some c => [("codeActionProvider", toJson c)] | none => []) ++
    (match s.documentFormattingProvider with | some d => [("documentFormattingProvider", toJson d)] | none => []) ++
    (match s.renameProvider with | some r => [("renameProvider", toJson r)] | none => []) ++
    (match s.inlayHintProvider with | some i => [("inlayHintProvider", toJson i)] | none => []) ++
    (match s.semanticTokensProvider with | some st => [("semanticTokensProvider", toJson st)] | none => [])

instance : FromJson ServerCapabilities where
  fromJson? json := do
    let textDocumentSync := (json.getObjValAs? TextDocumentSyncOptions "textDocumentSync").toOption
    let completionProvider := (json.getObjValAs? CompletionOptions "completionProvider").toOption
    let hoverProvider := (json.getObjValAs? Bool "hoverProvider").toOption
    let definitionProvider := (json.getObjValAs? Bool "definitionProvider").toOption
    let typeDefinitionProvider := (json.getObjValAs? TypeDefinitionOptions "typeDefinitionProvider").toOption
    let referencesProvider := (json.getObjValAs? Bool "referencesProvider").toOption
    let documentSymbolProvider := (json.getObjValAs? Bool "documentSymbolProvider").toOption
    let workspaceSymbolProvider := (json.getObjValAs? Bool "workspaceSymbolProvider").toOption
    let codeActionProvider := (json.getObjValAs? Bool "codeActionProvider").toOption
    let documentFormattingProvider := (json.getObjValAs? Bool "documentFormattingProvider").toOption
    let renameProvider := (json.getObjValAs? Bool "renameProvider").toOption
    let inlayHintProvider := (json.getObjValAs? InlayHintOptions "inlayHintProvider").toOption
    let semanticTokensProvider := (json.getObjValAs? SemanticTokensOptions "semanticTokensProvider").toOption
    return { textDocumentSync, completionProvider, hoverProvider, definitionProvider,
             typeDefinitionProvider, referencesProvider, documentSymbolProvider,
             workspaceSymbolProvider, codeActionProvider, documentFormattingProvider,
             renameProvider, inlayHintProvider, semanticTokensProvider }


/-- TODO: Client capabilities -/
structure ClientCapabilities where
  deriving Inhabited, Repr

instance : ToJson ClientCapabilities where
  toJson _ := Json.mkObj []

instance : FromJson ClientCapabilities where
  fromJson? _ := return {}

end Lapis.Protocol.Capabilities
