import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Transport.Base
import Lapis.Server.Receiver
import Std.Data.HashMap

namespace Lapis.Server.WorkspaceEdit

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Transport
open Lapis.Server.Receiver
open Std (HashMap)

/-- An optional identifier to a text edit -/
structure AnnotatedTextEdit where
  range : Range
  newText : String
  annotationId : Option String := none
  deriving Inhabited

instance : ToJson AnnotatedTextEdit where
  toJson e := Json.mkObj <|
    [("range", toJson e.range), ("newText", Json.str e.newText)] ++
    (match e.annotationId with | some id => [("annotationId", Json.str id)] | none => [])

instance : FromJson AnnotatedTextEdit where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let newText ← json.getObjValAs? String "newText"
    let annotationId := (json.getObjValAs? String "annotationId").toOption
    return { range, newText, annotationId }

/-- Options for creating a file -/
structure CreateFileOptions where
  overwrite : Option Bool := none
  ignoreIfExists : Option Bool := none
  deriving Inhabited

instance : ToJson CreateFileOptions where
  toJson o := Json.mkObj <|
    (match o.overwrite with | some b => [("overwrite", toJson b)] | none => []) ++
    (match o.ignoreIfExists with | some b => [("ignoreIfExists", toJson b)] | none => [])

instance : FromJson CreateFileOptions where
  fromJson? json := do
    let overwrite := (json.getObjValAs? Bool "overwrite").toOption
    let ignoreIfExists := (json.getObjValAs? Bool "ignoreIfExists").toOption
    return { overwrite, ignoreIfExists }

/-- Options for renaming a file -/
structure RenameFileOptions where
  overwrite : Option Bool := none
  ignoreIfExists : Option Bool := none
  deriving Inhabited

instance : ToJson RenameFileOptions where
  toJson o := Json.mkObj <|
    (match o.overwrite with | some b => [("overwrite", toJson b)] | none => []) ++
    (match o.ignoreIfExists with | some b => [("ignoreIfExists", toJson b)] | none => [])

instance : FromJson RenameFileOptions where
  fromJson? json := do
    let overwrite := (json.getObjValAs? Bool "overwrite").toOption
    let ignoreIfExists := (json.getObjValAs? Bool "ignoreIfExists").toOption
    return { overwrite, ignoreIfExists }

/-- Options for deleting a file -/
structure DeleteFileOptions where
  recursive : Option Bool := none
  ignoreIfNotExists : Option Bool := none
  deriving Inhabited

instance : ToJson DeleteFileOptions where
  toJson o := Json.mkObj <|
    (match o.recursive with | some b => [("recursive", toJson b)] | none => []) ++
    (match o.ignoreIfNotExists with | some b => [("ignoreIfNotExists", toJson b)] | none => [])

instance : FromJson DeleteFileOptions where
  fromJson? json := do
    let recursive := (json.getObjValAs? Bool "recursive").toOption
    let ignoreIfNotExists := (json.getObjValAs? Bool "ignoreIfNotExists").toOption
    return { recursive, ignoreIfNotExists }

/-- Create file operation -/
structure CreateFile where
  uri : DocumentUri
  options : Option CreateFileOptions := none
  annotationId : Option String := none
  deriving Inhabited

instance : ToJson CreateFile where
  toJson c := Json.mkObj <|
    [("kind", Json.str "create"), ("uri", Json.str c.uri)] ++
    (match c.options with | some o => [("options", toJson o)] | none => []) ++
    (match c.annotationId with | some id => [("annotationId", Json.str id)] | none => [])

/-- Rename file operation -/
structure RenameFile where
  oldUri : DocumentUri
  newUri : DocumentUri
  options : Option RenameFileOptions := none
  annotationId : Option String := none
  deriving Inhabited

instance : ToJson RenameFile where
  toJson r := Json.mkObj <|
    [("kind", Json.str "rename"), ("oldUri", Json.str r.oldUri), ("newUri", Json.str r.newUri)] ++
    (match r.options with | some o => [("options", toJson o)] | none => []) ++
    (match r.annotationId with | some id => [("annotationId", Json.str id)] | none => [])

/-- Delete file operation -/
structure DeleteFile where
  uri : DocumentUri
  options : Option DeleteFileOptions := none
  annotationId : Option String := none
  deriving Inhabited

instance : ToJson DeleteFile where
  toJson d := Json.mkObj <|
    [("kind", Json.str "delete"), ("uri", Json.str d.uri)] ++
    (match d.options with | some o => [("options", toJson o)] | none => []) ++
    (match d.annotationId with | some id => [("annotationId", Json.str id)] | none => [])

/-- Text document edit -/
structure TextDocumentEdit where
  textDocument : VersionedTextDocumentIdentifier
  edits : Array TextEdit
  deriving Inhabited

instance : ToJson TextDocumentEdit where
  toJson t := Json.mkObj
    [("textDocument", toJson t.textDocument), ("edits", toJson t.edits)]

instance : FromJson TextDocumentEdit where
  fromJson? json := do
    let textDocument ← json.getObjValAs? VersionedTextDocumentIdentifier "textDocument"
    let edits ← json.getObjValAs? (Array TextEdit) "edits"
    return { textDocument, edits }

/-- A document change can be a text edit, create, rename, or delete -/
inductive DocumentChange where
  | textEdit (edit : TextDocumentEdit)
  | createFile (create : CreateFile)
  | renameFile (rename : RenameFile)
  | deleteFile (delete : DeleteFile)
  deriving Inhabited

instance : ToJson DocumentChange where
  toJson
    | .textEdit e => toJson e
    | .createFile c => toJson c
    | .renameFile r => toJson r
    | .deleteFile d => toJson d

/-- Change annotation for describing edit metadata -/
structure ChangeAnnotation where
  label : String
  needsConfirmation : Option Bool := none
  description : Option String := none
  deriving Inhabited

instance : ToJson ChangeAnnotation where
  toJson a := Json.mkObj <|
    [("label", Json.str a.label)] ++
    (match a.needsConfirmation with | some b => [("needsConfirmation", toJson b)] | none => []) ++
    (match a.description with | some d => [("description", Json.str d)] | none => [])

instance : FromJson ChangeAnnotation where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let needsConfirmation := (json.getObjValAs? Bool "needsConfirmation").toOption
    let description := (json.getObjValAs? String "description").toOption
    return { label, needsConfirmation, description }

/-- A workspace edit represents changes to many resources -/
structure WorkspaceEdit where
  /-- Map of document URI to text edits (simple format) -/
  changes : Option (HashMap String (Array TextEdit)) := none
  /-- Document changes (rich format with file operations) -/
  documentChanges : Option (Array DocumentChange) := none
  /-- Change annotations -/
  changeAnnotations : Option (HashMap String ChangeAnnotation) := none
  deriving Inhabited

private def hashMapToJsonObj [ToJson α] (m : HashMap String α) : Json :=
  let pairs := m.toList.map fun (k, v) => (k, toJson v)
  Json.mkObj pairs

instance : ToJson WorkspaceEdit where
  toJson w := Json.mkObj <|
    (match w.changes with
      | some c => [("changes", hashMapToJsonObj c)]
      | none => []) ++
    (match w.documentChanges with
      | some dc => [("documentChanges", toJson dc)]
      | none => []) ++
    (match w.changeAnnotations with
      | some ca => [("changeAnnotations", hashMapToJsonObj ca)]
      | none => [])

/-- Parameters for workspace/applyEdit request -/
structure ApplyWorkspaceEditParams where
  label : Option String := none
  edit : WorkspaceEdit
  deriving Inhabited

instance : ToJson ApplyWorkspaceEditParams where
  toJson p := Json.mkObj <|
    (match p.label with | some l => [("label", Json.str l)] | none => []) ++
    [("edit", toJson p.edit)]

/-- Response from workspace/applyEdit -/
structure ApplyWorkspaceEditResult where
  applied : Bool
  failureReason : Option String := none
  failedChange : Option Nat := none
  deriving Inhabited

instance : FromJson ApplyWorkspaceEditResult where
  fromJson? json := do
    let applied ← json.getObjValAs? Bool "applied"
    let failureReason := (json.getObjValAs? String "failureReason").toOption
    let failedChange := (json.getObjValAs? Nat "failedChange").toOption
    return { applied, failureReason, failedChange }

/-- Builder for constructing workspace edits -/
structure WorkspaceEditBuilder where
  changes : HashMap String (Array TextEdit)
  documentChanges : Array DocumentChange
  annotations : HashMap String ChangeAnnotation
  useDocumentChanges : Bool

namespace WorkspaceEditBuilder

/-- Create a new builder -/
def new (useDocumentChanges : Bool := false) : WorkspaceEditBuilder :=
  { changes := {}, documentChanges := #[], annotations := {}, useDocumentChanges }

/-- Add a text edit to a document -/
def addEdit (b : WorkspaceEditBuilder) (uri : DocumentUri) (edit : TextEdit) : WorkspaceEditBuilder :=
  if b.useDocumentChanges then
    b  -- Should use addDocumentEdit for document changes mode
  else
    let existing := b.changes.getD uri #[]
    { b with changes := b.changes.insert uri (existing.push edit) }

/-- Add multiple text edits to a document -/
def addEdits (b : WorkspaceEditBuilder) (uri : DocumentUri) (edits : Array TextEdit) : WorkspaceEditBuilder :=
  edits.foldl (fun b' e => b'.addEdit uri e) b

/-- Add a document edit (for documentChanges mode) -/
def addDocumentEdit (b : WorkspaceEditBuilder) (docEdit : TextDocumentEdit) : WorkspaceEditBuilder :=
  { b with documentChanges := b.documentChanges.push (.textEdit docEdit) }

/-- Add a create file operation -/
def createFile (b : WorkspaceEditBuilder) (uri : DocumentUri)
    (options : Option CreateFileOptions := none) : WorkspaceEditBuilder :=
  { b with documentChanges := b.documentChanges.push (.createFile { uri, options }) }

/-- Add a rename file operation -/
def renameFile (b : WorkspaceEditBuilder) (oldUri newUri : DocumentUri)
    (options : Option RenameFileOptions := none) : WorkspaceEditBuilder :=
  { b with documentChanges := b.documentChanges.push (.renameFile { oldUri, newUri, options }) }

/-- Add a delete file operation -/
def deleteFile (b : WorkspaceEditBuilder) (uri : DocumentUri)
    (options : Option DeleteFileOptions := none) : WorkspaceEditBuilder :=
  { b with documentChanges := b.documentChanges.push (.deleteFile { uri, options }) }

/-- Add a change annotation -/
def addAnnotation (b : WorkspaceEditBuilder) (id : String) (annotation : ChangeAnnotation) : WorkspaceEditBuilder :=
  { b with annotations := b.annotations.insert id annotation }

/-- Build the final WorkspaceEdit -/
def build (b : WorkspaceEditBuilder) : WorkspaceEdit :=
  if b.useDocumentChanges then
    { documentChanges := some b.documentChanges
      changeAnnotations := if b.annotations.isEmpty then none else some b.annotations }
  else
    { changes := if b.changes.isEmpty then none else some b.changes }

/-- Replace text in a range -/
def replace (b : WorkspaceEditBuilder) (uri : DocumentUri) (range : Range) (newText : String) : WorkspaceEditBuilder :=
  b.addEdit uri { range, newText }

/-- Insert text at a position -/
def insert (b : WorkspaceEditBuilder) (uri : DocumentUri) (pos : Position) (text : String) : WorkspaceEditBuilder :=
  b.addEdit uri { range := { start := pos, «end» := pos }, newText := text }

/-- Delete a range -/
def delete (b : WorkspaceEditBuilder) (uri : DocumentUri) (range : Range) : WorkspaceEditBuilder :=
  b.addEdit uri { range, newText := "" }

end WorkspaceEditBuilder

/-- Apply a workspace edit via the client -/
def applyEdit (outputChannel : OutputChannel) (pendingResponses : PendingResponses)
    (edit : WorkspaceEdit) (label : Option String := none) : IO ApplyWorkspaceEditResult := do
  let params : ApplyWorkspaceEditParams := { label, edit }

  let promise ← IO.Promise.new
  let requestId ← pendingResponses.register promise
  let _ ← outputChannel.sendRequest requestId "workspace/applyEdit" (toJson params)

  -- Wait for response
  let some result := promise.result?.get
    | return { applied := false, failureReason := some "No response from client" }

  match FromJson.fromJson? result with
  | .ok r => return r
  | .error e => return { applied := false, failureReason := some s!"Failed to parse response: {e}" }

/-- Apply a workspace edit and throw on failure -/
def applyEditOrThrow (outputChannel : OutputChannel) (pendingResponses : PendingResponses)
    (edit : WorkspaceEdit) (label : Option String := none) : IO Unit := do
  let result ← applyEdit outputChannel pendingResponses edit label
  if !result.applied then
    let reason := result.failureReason.getD "Unknown error"
    throw (IO.userError s!"Failed to apply workspace edit: {reason}")

end Lapis.Server.WorkspaceEdit
