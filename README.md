# ✏️ lapis

A minimal, lightweight Language Server Protocol (LSP) framework in Lean 4.

This is just a scaffold for building language servers in Lean 4. It provides the core LSP protocol handling, a virtual file system (VFS) for managing text documents, and utilities for common LSP tasks.

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

### Virtual File System (VFS)
- [x] Efficient finger tree-based text representation
- [x] Piece table for fast incremental edits
- [x] Line index with dirty range tracking
- [x] UTF-8/UTF-16 position conversion for LSP compatibility
- [x] Document snapshots with reference counting
- [x] Thread-safe document store with IO-based operations
- [x] O(log n) split/concatenation, O(1) amortized cons/snoc

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

### Concurrency
- [x] Actor-based concurrency model with message passing
- [x] Separate VFS and LSP actors for parallelism
- [x] Per-request cancellation tokens
- [x] Async request processing with bounded concurrency
- [x] Thread-safe channels (unbounded, bounded, oneshot)
- [x] Document snapshots with reference counting for concurrent access
- [x] Actor supervision and lifecycle management

### Server Utilities
- [x] Progress reporting API with token lifecycle management
- [x] Workspace edit support (`workspace/applyEdit`) with builder pattern
- [x] Debounced diagnostics with per-document scheduling
- [x] Dynamic capability registration (`client/registerCapability`)
- [x] File watcher registration helpers