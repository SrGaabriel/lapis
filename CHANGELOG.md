# Changelog

## [0.2.0]

### New Features

#### Request Cancellation Support

Handlers can now check if a request has been cancelled by the client:

```lean
def handleHover (params : HoverParams) : ServerM MyState (Option Hover) := do
  -- Check early
  if ← isCancelled then return none
  
  -- ... do some work ...
  
  checkCancelled  -- throws if cancelled
```

- `isCancelled : ServerM UserState Bool` - returns true if the client sent `$/cancelRequest`
- `checkCancelled : ServerM UserState Unit` - throws `IO.userError` if cancelled

#### Request Coalescing

Rapid hover/definition requests for the same position are now automatically coalesced. When a new request arrives while an old one is pending for the same (method, uri, position), the old request is cancelled automatically.

Applies to: `textDocument/hover`, `textDocument/definition`, `textDocument/typeDefinition`, `textDocument/implementation`, `textDocument/references`

### Breaking Changes

#### `getDocument` renamed to `getDocumentSnapshot`

The function now returns a `DocumentSnapshot` instead of `Document`:

```lean
-- Before (0.1)
let some doc ← getDocument uri | return none
let version := doc.version

-- After (0.2)
let some snapshot ← getDocumentSnapshot uri | return none
let version := snapshot.version
let content := snapshot.content  -- content is directly available
```

`DocumentSnapshot` fields:
- `uri : String`
- `languageId : String`  
- `version : Int`
- `content : String`
- `lineCount : Nat`

#### Removed `openDocument`, `closeDocument`, `changeDocument` from `ServerM`

Document lifecycle is now handled internally by the VFS actor. User handlers no longer need to call these - just register notification handlers if you need to react to document events:

```lean
-- Before (0.1) - had to manually sync documents
def handleDidOpen (params : DidOpenTextDocumentParams) : ServerM MyState Unit := do
  openDocument params  -- no longer needed/available
  -- your logic here

-- After (0.2) - documents sync automatically
def handleDidOpen (params : DidOpenTextDocumentParams) : ServerM MyState Unit := do
  -- just your logic, document is already opened
  let content := params.textDocument.text
  updateSymbols params.textDocument.uri content
```

#### Removed `getDocumentStore`

Use the specific accessor functions instead:
- `getDocumentSnapshot` - get full document snapshot
- `getDocumentContent` - get document text
- `getDocumentLine` - get a specific line
- `getDocumentWordAt` - get word at position
- `getDocumentUris` - list open documents
- `hasDocument` - check if document is open

### Internal Changes

- Dispatcher now uses actor-based VFS internally for thread-safe document access
- All request handlers run with proper cancellation token support
- Improved concurrency model with message passing

## [0.1.0] - Initial Release

Initial release of Lapis LSP framework.
