import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Transport.Base
import Lapis.Server.Documents
import Lapis.Server.Receiver

namespace Lapis.Server.Monad

open Lean (Json toJson FromJson)
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Transport
open Lapis.Server.Documents
open Lapis.Server.Receiver

/-- Server state -/
structure ServerState (UserState : Type) where
  /-- Whether the server has been initialized -/
  initialized : Bool := false
  /-- Whether shutdown has been requested -/
  shutdownRequested : Bool := false
  /-- Document store -/
  documents : DocumentStore := DocumentStore.empty
  /-- User-defined state -/
  userState : UserState
  deriving Inhabited

/-- Server context (shared across all request handlers) -/
structure ServerContext (UserState : Type) where
  /-- Server capabilities -/
  capabilities : ServerCapabilities
  /-- Server info -/
  serverInfo : ServerInfo
  /-- Output channel for sending messages to client (thread-safe) -/
  outputChannel : OutputChannel
  /-- Shared state reference -/
  stateRef : IO.Ref (ServerState UserState)
  /-- Mutex for state modifications that need to be atomic -/
  stateMutex : AsyncMutex
  /-- Pending responses for client-initiated requests -/
  pendingResponses : PendingResponses

/-- The server monad - provides access to shared context and IO. -/
abbrev ServerM (UserState : Type) := ReaderT (ServerContext UserState) IO

/-- Get the server context -/
def getContext : ServerM UserState (ServerContext UserState) := read

/-- Access state with the mutex held (for compound operations) -/
def withStateLock (f : ServerState UserState → IO (α × ServerState UserState)) : ServerM UserState α := do
  let ctx ← read
  ctx.stateMutex.withLock do
    let state ← ctx.stateRef.get
    let (result, newState) ← f state
    ctx.stateRef.set newState
    return result

/-- Get a snapshot of the full server state -/
def getServerState : ServerM UserState (ServerState UserState) := do
  (← read).stateRef.get

/-- Modify the server state atomically -/
def modifyServerState (f : ServerState UserState → ServerState UserState) : ServerM UserState Unit := do
  (← read).stateRef.modify f

/-- Get user state -/
def getUserState : ServerM UserState UserState := do
  return (← getServerState).userState

/-- Set user state -/
def setUserState (s : UserState) : ServerM UserState Unit :=
  modifyServerState fun st => { st with userState := s }

/-- Modify user state -/
def modifyUserState (f : UserState → UserState) : ServerM UserState Unit :=
  modifyServerState fun st => { st with userState := f st.userState }

/-- Check if initialized -/
def isInitialized : ServerM UserState Bool := do
  return (← getServerState).initialized

/-- Mark as initialized -/
def setInitialized : ServerM UserState Unit :=
  modifyServerState fun st => { st with initialized := true }

/-- Check if shutdown was requested -/
def isShutdownRequested : ServerM UserState Bool := do
  return (← getServerState).shutdownRequested

/-- Request shutdown -/
def requestShutdown : ServerM UserState Unit :=
  modifyServerState fun st => { st with shutdownRequested := true }

/-- Get a document by URI -/
def getDocument (uri : DocumentUri) : ServerM UserState (Option Document) := do
  return (← getServerState).documents.get? uri

/-- Get all documents -/
def getDocuments : ServerM UserState DocumentStore := do
  return (← getServerState).documents

/-- Open a document -/
def openDocument (params : DidOpenTextDocumentParams) : ServerM UserState Unit :=
  modifyServerState fun st => { st with documents := st.documents.open params }

/-- Close a document -/
def closeDocument (params : DidCloseTextDocumentParams) : ServerM UserState Unit :=
  modifyServerState fun st => { st with documents := st.documents.close params }

/-- Apply document changes -/
def changeDocument (params : DidChangeTextDocumentParams) : ServerM UserState Unit :=
  modifyServerState fun st => { st with documents := st.documents.change params }

/-- Get the output channel for sending messages to the client -/
def getOutputChannel : ServerM UserState OutputChannel := do
  return (← read).outputChannel

/-- Send a notification to the client -/
def sendNotification (method : String) (params : Lean.Json) : ServerM UserState Unit := do
  let ch ← getOutputChannel
  let _ ← ch.sendNotification method params
  pure ()

/-- Send a request to the client and register a handler for the response -/
def sendRequest (method : String) (params : Lean.Json) : ServerM UserState (IO.Promise Lean.Json) := do
  let ch ← getOutputChannel
  let pendingResponses := (← read).pendingResponses

  let promise ← IO.Promise.new

  let requestId ← pendingResponses.register promise
  let _ ← ch.sendRequest requestId method params
  pure promise

/-- Request configuration from the client -/
def requestConfiguration (items : Array ConfigurationItem) : ServerM UserState (Except String (Array Json)) := do
  let params : ConfigurationParams := { items }
  let promise ← sendRequest "workspace/configuration" (toJson params)
  let some result := promise.result?.get
    | return Except.error "Promise was not resolved"

  -- Check if it's an error response
  if let some errorMsg := result.getObjValAs? String "error" |>.toOption then
    return Except.error errorMsg

  -- Try to parse as array
  match FromJson.fromJson? (α := Array Json) result with
  | Except.ok arr => return Except.ok arr
  | Except.error e => return Except.error s!"Failed to parse configuration response: {e}"

/-- Publish diagnostics to the client -/
def publishDiagnostics (params : PublishDiagnosticsParams) : ServerM UserState Unit := do
  sendNotification "textDocument/publishDiagnostics" (Lean.toJson params)

/-- Clear diagnostics for a document -/
def clearDiagnostics (uri : DocumentUri) : ServerM UserState Unit := do
  publishDiagnostics { uri, diagnostics := #[] }

/-- Send a log message to the client -/
def logMessage (type : Nat) (message : String) : ServerM UserState Unit := do
  sendNotification "window/logMessage" (Lean.Json.mkObj [("type", type), ("message", message)])

/-- Send an info log message -/
def logInfo (message : String) : ServerM UserState Unit := logMessage 3 message

/-- Send a warning log message -/
def logWarning (message : String) : ServerM UserState Unit := logMessage 2 message

/-- Send an error log message -/
def logError (message : String) : ServerM UserState Unit := logMessage 1 message

/-- Show a message to the user in the editor -/
def showMessage (type : Nat) (message : String) : ServerM UserState Unit := do
  sendNotification "window/showMessage" (Lean.Json.mkObj [("type", type), ("message", message)])

/-- Show an info message to the user -/
def showInfo (message : String) : ServerM UserState Unit := showMessage 3 message

/-- Show a warning message to the user -/
def showWarning (message : String) : ServerM UserState Unit := showMessage 2 message

/-- Show an error message to the user -/
def showError (message : String) : ServerM UserState Unit := showMessage 1 message

end Lapis.Server.Monad
