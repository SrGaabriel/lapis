# ✏️ lapis

A minimal, lightweight Language Server Protocol (LSP) framework in Lean 4.

## 🎨 Usage

This is a small example of a language server using lapis:

```lean
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
    |>.onNotification "textDocument/didOpen" handleDidOpen
    |>.onNotification "textDocument/didChange" handleDidChange

  runStdio config
  
def handleDidOpen (params : DidOpenTextDocumentParams) : ServerM TestState Unit := do
  showInfo "Document opened!"
  updateDiagnostics params.textDocument.uri
```

## 📝 Features

### Core Protocol
- [x] Complete JSON-RPC 2.0 implementation
- [x] LSP 3.17 base types (Position, Range, Location, Diagnostic, etc)
- [x] Bidirectional messaging
- [x] Request cancellation support
- [x] Async request handling

### Transport
- [x] stdio transport (standard LSP communication)
- [x] Thread-safe message output channel
- [x] Proper Content-Length framing

### Server Infrastructure
- [x] Type-safe handler registration
- [x] Clean `ServerM` monad for server operations
- [x] Built-in document synchronization (open/change/close)
- [x] User-defined state management
- [x] Server and client capability negotiation

### Implemented LSP Features
- [x] `initialize` / `shutdown` / `exit` lifecycle
- [x] Text document synchronization (full and incremental)
- [x] Hover (`textDocument/hover`)
- [x] Completion (`textDocument/completion`)
- [x] Go to definition (types defined, handler registration supported)
- [x] Find references (types defined, handler registration supported)
- [x] Publish diagnostics (`textDocument/publishDiagnostics`)
- [x] Workspace configuration (`workspace/configuration`)
- [x] Configuration change notifications (`workspace/didChangeConfiguration`)

### Developer Experience
- [x] Automatic JSON serialization/deserialization
- [x] Type-safe message handlers with compile-time checks
- [x] Helper methods for common operations (logging, messages, diagnostics)
- [x] Generic configuration support for type-safe settings
- [x] Builder pattern for server configuration
