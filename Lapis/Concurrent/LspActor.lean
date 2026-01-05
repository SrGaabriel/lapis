/-
  LSP Actor

  Handles LSP request dispatch with:
  - Concurrent request handling (bounded parallelism)
  - Request cancellation support
  - Response routing back to clients
-/

import Lapis.Concurrent.Actor
import Lapis.Concurrent.VfsActor
import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Transport.Base
import Lapis.Server.Receiver
import Lapis.Server.Progress
import Std.Data.HashMap

namespace Lapis.Concurrent.LspActor

open Lean Json
open Lapis.Concurrent.Actor
open Lapis.Concurrent.Channel
open Lapis.Concurrent.VfsActor
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Transport
open Lapis.Server.Receiver
open Lapis.Server.Progress
open Std (HashMap)

/-! ## Request Context -/

/-- Context passed to request handlers -/
structure RequestContext (UserState : Type) where
  /-- VFS reference for document access -/
  vfs : VfsRef
  /-- Output channel for sending messages -/
  outputChannel : OutputChannel
  /-- Pending responses for server-initiated requests -/
  pendingResponses : PendingResponses
  /-- Mutable user state reference -/
  userStateRef : IO.Ref UserState
  /-- Server capabilities -/
  capabilities : ServerCapabilities
  /-- Server info -/
  serverInfo : ServerInfo
  /-- Progress manager for work done progress -/
  progressManager : ProgressManager
  /-- Cancellation token for this request -/
  cancelToken : IO.CancelToken

namespace RequestContext

/-- Check if request was cancelled -/
def isCancelled (ctx : RequestContext UserState) : IO Bool :=
  ctx.cancelToken.isSet

/-- Get user state -/
def getUserState (ctx : RequestContext UserState) : IO UserState :=
  ctx.userStateRef.get

/-- Set user state -/
def setUserState (ctx : RequestContext UserState) (state : UserState) : IO Unit :=
  ctx.userStateRef.set state

/-- Modify user state -/
def modifyUserState (ctx : RequestContext UserState) (f : UserState → UserState) : IO Unit :=
  ctx.userStateRef.modify f

/-- Get a document snapshot -/
def getDocument (ctx : RequestContext UserState) (uri : DocumentUri) : IO (Option DocumentSnapshot) :=
  ctx.vfs.getSnapshot uri

/-- Get document content -/
def getDocumentContent (ctx : RequestContext UserState) (uri : DocumentUri) : IO (Option String) :=
  ctx.vfs.getContent uri

/-- Get a line from a document -/
def getDocumentLine (ctx : RequestContext UserState) (uri : DocumentUri) (line : Nat) : IO (Option String) :=
  ctx.vfs.getLine uri line

/-- Get word at position -/
def getWordAt (ctx : RequestContext UserState) (uri : DocumentUri) (pos : Position) : IO (Option String) :=
  ctx.vfs.getWordAt uri pos

/-- Send a notification to the client -/
def sendNotification (ctx : RequestContext UserState) (method : String) (params : Json) : IO Unit := do
  let notif : NotificationMessage := { method, params := some params }
  ctx.outputChannel.send (.notification notif)

/-- Send a request to the client -/
def sendRequest (ctx : RequestContext UserState) (method : String) (params : Json) : IO (IO.Promise Json) := do
  let promise ← IO.Promise.new
  let requestId ← ctx.pendingResponses.register promise
  ctx.outputChannel.sendRequest requestId method params
  return promise

/-- Publish diagnostics -/
def publishDiagnostics (ctx : RequestContext UserState) (params : PublishDiagnosticsParams) : IO Unit :=
  ctx.sendNotification "textDocument/publishDiagnostics" (toJson params)

/-- Log a message -/
def logMessage (ctx : RequestContext UserState) (type : Nat) (message : String) : IO Unit :=
  ctx.sendNotification "window/logMessage" (Json.mkObj [("type", type), ("message", message)])

/-- Log info -/
def logInfo (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.logMessage 3 message

/-- Log warning -/
def logWarning (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.logMessage 2 message

/-- Log error -/
def logError (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.logMessage 1 message

/-- Show a message to the user -/
def showMessage (ctx : RequestContext UserState) (type : Nat) (message : String) : IO Unit :=
  ctx.sendNotification "window/showMessage" (Json.mkObj [("type", type), ("message", message)])

/-- Show info message -/
def showInfo (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.showMessage 3 message

/-- Show warning message -/
def showWarning (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.showMessage 2 message

/-- Show error message -/
def showError (ctx : RequestContext UserState) (message : String) : IO Unit :=
  ctx.showMessage 1 message

/-- Run an action with progress reporting -/
def withProgress (ctx : RequestContext UserState) (title : String)
    (cancellable : Bool := false)
    (action : ProgressHandle → IO α) : IO α := do
  let token ← ctx.progressManager.generateToken
  let _ ← ctx.progressManager.createToken token
  ctx.progressManager.begin token title cancellable
  try
    let handle : ProgressHandle := { manager := ctx.progressManager, token }
    let result ← action handle
    ctx.progressManager.end token (message := some "Done")
    return result
  catch e =>
    ctx.progressManager.end token (message := some s!"Failed: {e}")
    throw e

end RequestContext

/-! ## Handler Types -/

/-- Result of handling a request -/
inductive HandlerResult where
  | ok (result : Json)
  | error (code : Int) (message : String)
  deriving Inhabited

/-- A request handler in the actor model -/
def RequestHandler (UserState : Type) := RequestContext UserState → Json → IO HandlerResult

/-- A notification handler in the actor model -/
def NotificationHandler (UserState : Type) := RequestContext UserState → Json → IO Unit

/-! ## LSP Messages -/

/-- Messages for the LSP actor -/
inductive LspMsg (UserState : Type) where
  /-- Handle an incoming request -/
  | request (msg : RequestMessage)
  /-- Handle an incoming notification (non-document) -/
  | notification (msg : NotificationMessage)
  /-- Cancel a pending request -/
  | cancelRequest (id : RequestId)
  /-- Handle a response from the client -/
  | response (id : RequestId) (result : Json)
  /-- Handle an error response from the client -/
  | errorResponse (id : RequestId) (error : String)
  /-- Shutdown the actor -/
  | shutdown

/-! ## LSP Actor State -/

/-- Pending request tracking -/
structure PendingRequest where
  id : RequestId
  cancelToken : IO.CancelToken
  task : Task (Except IO.Error Unit)

/-- LSP Actor configuration -/
structure LspConfig (UserState : Type) where
  /-- Server name -/
  name : String
  /-- Server version -/
  version : Option String := none
  /-- Server capabilities -/
  capabilities : ServerCapabilities := {}
  /-- Request handlers by method -/
  requestHandlers : HashMap String (RequestHandler UserState) := {}
  /-- Notification handlers by method -/
  notificationHandlers : HashMap String (NotificationHandler UserState) := {}
  /-- Maximum concurrent requests -/
  maxConcurrentRequests : Nat := 8
  /-- Hook called on initialize -/
  initializeHook : Option (RequestContext UserState → InitializeParams → IO Unit) := none

/-- LSP Actor state -/
structure LspState (UserState : Type) where
  /-- Server initialized -/
  initialized : Bool := false
  /-- Shutdown requested -/
  shutdownRequested : Bool := false
  /-- Count of active requests (for backpressure) -/
  activeRequests : Nat := 0

/-! ## LSP Actor Reference -/

/-- Handle to the LSP actor -/
structure LspRef (UserState : Type) where
  ref : ActorRef (LspMsg UserState)

namespace LspRef

/-- Send a request to be handled -/
def handleRequest (lsp : LspRef UserState) (msg : RequestMessage) : IO Unit :=
  lsp.ref.send (.request msg)

/-- Send a notification to be handled -/
def handleNotification (lsp : LspRef UserState) (msg : NotificationMessage) : IO Unit :=
  lsp.ref.send (.notification msg)

/-- Cancel a request -/
def cancelRequest (lsp : LspRef UserState) (id : RequestId) : IO Unit :=
  lsp.ref.send (.cancelRequest id)

/-- Handle a response from client -/
def handleResponse (lsp : LspRef UserState) (id : RequestId) (result : Json) : IO Unit :=
  lsp.ref.send (.response id result)

/-- Handle an error response from client -/
def handleErrorResponse (lsp : LspRef UserState) (id : RequestId) (error : String) : IO Unit :=
  lsp.ref.send (.errorResponse id error)

/-- Shutdown the actor -/
def shutdown (lsp : LspRef UserState) : IO Unit :=
  lsp.ref.send .shutdown

end LspRef

/-! ## LSP Actor Context -/

/-- Runtime context for the LSP actor -/
structure LspRuntime (UserState : Type) where
  config : LspConfig UserState
  vfs : VfsRef
  outputChannel : OutputChannel
  pendingResponses : PendingResponses
  userStateRef : IO.Ref UserState
  /-- Progress manager for work done progress -/
  progressManager : ProgressManager
  /-- Shared ref for pending requests (for async cleanup) -/
  pendingRequestsRef : IO.Ref (HashMap String PendingRequest)

/-- Handle initialize request -/
private def handleInitialize (rt : LspRuntime UserState) (params : InitializeParams) : IO InitializeResult := do
  if let some hook := rt.config.initializeHook then
    let ctx := {
      vfs := rt.vfs
      outputChannel := rt.outputChannel
      pendingResponses := rt.pendingResponses
      userStateRef := rt.userStateRef
      capabilities := rt.config.capabilities
      serverInfo := { name := rt.config.name, version := rt.config.version }
      progressManager := rt.progressManager
      cancelToken := (← IO.CancelToken.new) -- not cancellable during initialize
    }
    hook ctx params

  return {
    capabilities := rt.config.capabilities
    serverInfo := some { name := rt.config.name, version := rt.config.version }
  }

/-! ## LSP Actor Implementation -/

/-- Process a request asynchronously -/
private def processRequest (rt : LspRuntime UserState) (state : LspState UserState)
    (msg : RequestMessage) : IO (LspState UserState) := do
  let idStr := toString msg.id
  let cancelToken ← IO.CancelToken.new

  let ctx : RequestContext UserState := {
    vfs := rt.vfs
    outputChannel := rt.outputChannel
    pendingResponses := rt.pendingResponses
    userStateRef := rt.userStateRef
    capabilities := rt.config.capabilities
    serverInfo := { name := rt.config.name, version := rt.config.version }
    progressManager := rt.progressManager
    cancelToken := cancelToken
  }

  let task ← IO.asTask (prio := .default) do
    try
      -- Check cancellation before starting
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
        return

      let response ← match msg.method with
        | "initialize" =>
          match msg.params with
          | none => pure (mkInvalidParams msg.id "Missing params")
          | some params =>
            match FromJson.fromJson? params with
            | .error e => pure (mkInvalidParams msg.id s!"Invalid params: {e}")
            | .ok initParams =>
              let result ← handleInitialize rt initParams
              pure (mkResponse msg.id (toJson result))

        | "shutdown" =>
          pure (mkResponse msg.id Json.null)

        | method =>
          match rt.config.requestHandlers.get? method with
          | none => pure (mkMethodNotFound msg.id method)
          | some handler =>
            let params := msg.params.getD (Json.mkObj [])
            match ← handler ctx params with
            | .ok result => pure (mkResponse msg.id result)
            | .error code message => pure (mkErrorResponse (some msg.id) code message)

      -- Check cancellation before sending response
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
      else
        rt.outputChannel.send response

    catch e =>
      rt.outputChannel.send (mkInternalError (some msg.id) s!"Handler error: {e}")
    finally
      rt.pendingRequestsRef.modify fun m => m.erase idStr

  let pending : PendingRequest := { id := msg.id, cancelToken, task }
  rt.pendingRequestsRef.modify fun m => m.insert idStr pending
  return { state with activeRequests := state.activeRequests + 1 }

/-- Process a notification -/
private def processNotification (rt : LspRuntime UserState) (state : LspState UserState)
    (msg : NotificationMessage) : IO (LspState UserState) := do
  -- Create context for handler
  let cancelToken ← IO.CancelToken.new
  let ctx : RequestContext UserState := {
    vfs := rt.vfs
    outputChannel := rt.outputChannel
    pendingResponses := rt.pendingResponses
    userStateRef := rt.userStateRef
    capabilities := rt.config.capabilities
    serverInfo := { name := rt.config.name, version := rt.config.version }
    progressManager := rt.progressManager
    cancelToken := cancelToken
  }

  -- Handle built-in notifications
  match msg.method with
  | "initialized" =>
    return { state with initialized := true }

  | "window/workDoneProgress/cancel" =>
    if let some params := msg.params then
      if let .ok token := FromJson.fromJson? (α := ProgressToken) (params.getObjValD "token") then
        rt.progressManager.markCancelled token
    return state

  | _ =>
    -- Try user handler
    if let some handler := rt.config.notificationHandlers.get? msg.method then
      let params := msg.params.getD (Json.mkObj [])
      -- Run notification handlers async (fire and forget)
      let _ ← IO.asTask (prio := .default) do
        try
          handler ctx params
        catch _ =>
          pure ()
    return state

/-- Handle the LSP actor message -/
private def handleLspMsg (rt : LspRuntime UserState) (state : LspState UserState)
    (msg : LspMsg UserState) : IO (HandleResult (LspState UserState)) := do
  match msg with
  | .request reqMsg =>
    -- Check if initialized (except for initialize)
    if reqMsg.method != "initialize" && !state.initialized then
      rt.outputChannel.send (mkErrorResponse (some reqMsg.id) serverNotInitialized "Server not initialized")
      return .continue state

    -- Track shutdown
    let state := if reqMsg.method == "shutdown" then
      { state with shutdownRequested := true }
    else
      state

    let newState ← processRequest rt state reqMsg
    return .continue newState

  | .notification notifMsg =>
    let newState ← processNotification rt state notifMsg
    return .continue newState

  | .cancelRequest id =>
    let idStr := toString id
    let pending ← rt.pendingRequestsRef.get
    match pending.get? idStr with
    | some req =>
      req.cancelToken.set
      return .continue state
    | none =>
      return .continue state

  | .response id result =>
    rt.pendingResponses.execute id result
    return .continue state

  | .errorResponse id error =>
    rt.pendingResponses.executeError id error
    return .continue state

  | .shutdown =>
    let pending ← rt.pendingRequestsRef.get
    for (_, req) in pending.toList do
      req.cancelToken.set
    return .stop

/-! ## Spawn LSP Actor -/

/-- Spawn the LSP actor -/
def spawnLspActor (config : LspConfig UserState) (vfs : VfsRef)
    (outputChannel : OutputChannel) (pendingResponses : PendingResponses)
    (userStateRef : IO.Ref UserState)
    : IO (Actor (LspMsg UserState) (LspState UserState) × LspRef UserState) := do

  -- Create shared ref for pending requests (enables async cleanup)
  let pendingRequestsRef ← IO.mkRef ({} : HashMap String PendingRequest)

  -- Create progress manager for work done progress
  let progressManager ← ProgressManager.new outputChannel pendingResponses

  let rt : LspRuntime UserState := {
    config := config
    vfs := vfs
    outputChannel := outputChannel
    pendingResponses := pendingResponses
    userStateRef := userStateRef
    progressManager := progressManager
    pendingRequestsRef := pendingRequestsRef
  }

  let initialState : LspState UserState := {}

  let actor ← spawn initialState (handleLspMsg rt) { name := "lsp" }
  let lspRef : LspRef UserState := { ref := actor.ref }

  return (actor, lspRef)

/-! ## Config Builder -/

namespace LspConfig

/-- Create a new LSP config -/
def new (name : String) : LspConfig UserState :=
  { name }

/-- Set version -/
def withVersion (config : LspConfig UserState) (version : String) : LspConfig UserState :=
  { config with version := some version }

/-- Set capabilities -/
def withCapabilities (config : LspConfig UserState) (caps : ServerCapabilities) : LspConfig UserState :=
  { config with capabilities := caps }

/-- Add a request handler -/
def onRequest [FromJson Params] [ToJson Result]
    (config : LspConfig UserState)
    (method : String)
    (handler : RequestContext UserState → Params → IO Result) : LspConfig UserState :=
  let wrappedHandler : RequestHandler UserState := fun ctx json => do
    match FromJson.fromJson? json with
    | .error e => return .error invalidParams s!"Invalid params: {e}"
    | .ok params =>
      let result ← handler ctx params
      return .ok (toJson result)
  { config with requestHandlers := config.requestHandlers.insert method wrappedHandler }

/-- Add a request handler that can return null -/
def onRequestOpt [FromJson Params] [ToJson Result]
    (config : LspConfig UserState)
    (method : String)
    (handler : RequestContext UserState → Params → IO (Option Result)) : LspConfig UserState :=
  let wrappedHandler : RequestHandler UserState := fun ctx json => do
    match FromJson.fromJson? json with
    | .error e => return .error invalidParams s!"Invalid params: {e}"
    | .ok params =>
      match ← handler ctx params with
      | none => return .ok Json.null
      | some result => return .ok (toJson result)
  { config with requestHandlers := config.requestHandlers.insert method wrappedHandler }

/-- Add a notification handler -/
def onNotification [FromJson Params]
    (config : LspConfig UserState)
    (method : String)
    (handler : RequestContext UserState → Params → IO Unit) : LspConfig UserState :=
  let wrappedHandler : NotificationHandler UserState := fun ctx json => do
    match FromJson.fromJson? json with
    | .error _ => pure ()
    | .ok params => handler ctx params
  { config with notificationHandlers := config.notificationHandlers.insert method wrappedHandler }

/-- Set max concurrent requests -/
def withMaxConcurrentRequests (config : LspConfig UserState) (n : Nat) : LspConfig UserState :=
  { config with maxConcurrentRequests := n }
  
def onInitialize
    (config : LspConfig UserState)
    (hook : RequestContext UserState → InitializeParams → IO Unit) : LspConfig UserState :=
  { config with initializeHook := some hook }

end LspConfig

end Lapis.Concurrent.LspActor
