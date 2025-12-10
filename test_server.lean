import Lapis

open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Server.Monad
open Lapis.Server.Builder
open Lapis.Server.Dispatcher

structure TestState where
  requestCount : Nat := 0

def handleHover (params : HoverParams) : ServerM TestState (Option Hover) := do
  modifyUserState fun s => { s with requestCount := s.requestCount + 1 }

  let some doc ← getDocument params.textDocument.uri
    | return none

  let some word := doc.getWordAt params.position
    | return none

  return some {
    contents := {
      kind := .markdown
      value := s!"**Word:** `{word}`\n\nPosition: line {params.position.line}, char {params.position.character}"
    }
    range := none
  }

def handleCompletion (_params : CompletionParams) : ServerM TestState CompletionList := do
  return {
    isIncomplete := false
    items := #[
      { label := "hello", kind := some .text, detail := some "A greeting" },
      { label := "world", kind := some .text, detail := some "The planet" }
    ]
  }

def main : IO Unit := do
  let config := ServerConfig.new "example-server" ({} : TestState)
    |>.withVersion "0.1.0"
    |>.withCapabilities {
      textDocumentSync := some {
        openClose := some true
        change := some .full
        save := some { includeText := some false }
      }
      hoverProvider := some true
      completionProvider := some {
        triggerCharacters := some #["."]
        resolveProvider := some false
      }
    }
    |>.onRequestOpt "textDocument/hover" handleHover
    |>.onRequest "textDocument/completion" handleCompletion

  runStdio config
