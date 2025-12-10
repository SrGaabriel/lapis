import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Std.Data.HashMap

namespace Lapis.Server.Documents

open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Std (HashMap)

structure Document where
  uri : DocumentUri
  languageId : String
  version : Int
  content : String
  deriving Inhabited, Repr

abbrev DocumentStore := HashMap DocumentUri Document

def DocumentStore.empty : DocumentStore := HashMap.emptyWithCapacity 16

def DocumentStore.open (store : DocumentStore) (params : DidOpenTextDocumentParams) : DocumentStore :=
  let doc := params.textDocument
  store.insert doc.uri {
    uri := doc.uri
    languageId := doc.languageId
    version := doc.version
    content := doc.text
  }

def DocumentStore.close (store : DocumentStore) (params : DidCloseTextDocumentParams) : DocumentStore :=
  store.erase params.textDocument.uri

def DocumentStore.get? (store : DocumentStore) (uri : DocumentUri) : Option Document :=
  HashMap.get? store uri

private def applyChange (content : String) (change : TextDocumentContentChangeEvent) : String :=
  match change.range with
  | none =>
    change.text
  | some range =>
    let lines := content.splitOn "\n"
    let startLine := range.start.line
    let startChar := range.start.character
    let endLine := range.end.line
    let endChar := range.end.character

    -- Get the prefix (before the change)
    let prefixLines := lines.take startLine
    let prefixLastLine := (lines[startLine]?.getD "").take startChar
    let prefixStr := String.intercalate "\n" prefixLines.toArray.toList ++
                     (if prefixLines.length > 0 then "\n" else "") ++ prefixLastLine

    -- Get the suffix (after the change)
    let suffixFirstLine := (lines[endLine]?.getD "").drop endChar
    let suffixLines := lines.drop (endLine + 1)
    let suffixStr := suffixFirstLine ++
                     (if suffixLines.length > 0 then "\n" else "") ++
                     String.intercalate "\n" suffixLines.toArray.toList

    prefixStr ++ change.text ++ suffixStr

def DocumentStore.change (store : DocumentStore) (params : DidChangeTextDocumentParams) : DocumentStore :=
  let uri := params.textDocument.uri
  match HashMap.get? store uri with
  | none => store -- Document not found, ignore
  | some doc =>
    let newContent := params.contentChanges.foldl (init := doc.content) applyChange
    store.insert uri { doc with
      version := params.textDocument.version
      content := newContent
    }

/-- Get content at a position -/
def Document.getLine (doc : Document) (line : Nat) : Option String :=
  let lines := doc.content.splitOn "\n"
  lines[line]?

/-- Get word at position (simple implementation) -/
def Document.getWordAt (doc : Document) (pos : Position) : Option String :=
  match doc.getLine pos.line with
  | none => none
  | some line =>
    let isWordChar := fun c => c.isAlphanum || c == '_'
    -- Find start of word by going backwards
    let start := pos.character - (line.toList.take pos.character |>.reverse.takeWhile isWordChar |>.length)
    -- Find end of word by going forward
    let endPos := pos.character + (line.toList.drop pos.character |>.takeWhile isWordChar |>.length)
    if start == endPos then none
    else some (Substring.toString ⟨line, ⟨start⟩, ⟨endPos⟩⟩)

end Lapis.Server.Documents
