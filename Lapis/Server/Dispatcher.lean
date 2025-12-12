import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Transport.Base
import Lapis.Transport.Stdio
import Lapis.Server.Monad
import Lapis.Server.Builder
import Lapis.Server.Receiver
import Lapis.Concurrent.Actor
import Lapis.Concurrent.VfsActor
import Std.Data.HashMap

namespace Lapis.Server.Dispatcher

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Transport
open Lapis.Server.Monad
open Lapis.Server.Builder
open Lapis.Server.Receiver
open Lapis.Concurrent.Actor
open Lapis.Concurrent.VfsActor
open Std (HashMap)

/-! ## Pending Request Tracking -/

structure PendingRequests where
  ref : IO.Ref (HashMap String IO.CancelToken)

def PendingRequests.new : IO PendingRequests := do
  let ref ← IO.mkRef (HashMap.emptyWithCapacity 16)
  return { ref }

def PendingRequests.add (pr : PendingRequests) (id : String) (token : IO.CancelToken) : IO Unit := do
  pr.ref.modify fun m => m.insert id token

def PendingRequests.remove (pr : PendingRequests) (id : String) : IO Unit := do
  pr.ref.modify fun m => m.erase id

def PendingRequests.cancel (pr : PendingRequests) (id : String) : IO Bool := do
  -- Atomically get and remove the token
  let maybeToken ← pr.ref.modifyGet fun m =>
    (m.get? id, m.erase id)
  match maybeToken with
  | some token =>
    token.set
    return true
  | none =>
    return false

/-! ## Request Coalescing -/

/-- Key for coalescing requests: method + uri + position -/
structure CoalesceKey where
  method : String
  uri : String
  line : Nat
  character : Nat
  deriving BEq, Hashable

/-- Pending coalesced request -/
structure CoalescedRequest where
  requestId : RequestId
  cancelToken : IO.CancelToken

/-- Tracks requests that can be coalesced (hover, definition, etc.).
    Uses atomic IO.Ref operations - no mutex needed. -/
structure RequestCoalescer where
  ref : IO.Ref (HashMap CoalesceKey CoalescedRequest)

def RequestCoalescer.new : IO RequestCoalescer := do
  let ref ← IO.mkRef (HashMap.emptyWithCapacity 16)
  return { ref }

/-- Methods that support coalescing -/
def coalescableMethods : List String :=
  ["textDocument/hover", "textDocument/definition", "textDocument/typeDefinition",
   "textDocument/implementation", "textDocument/references"]

/-- Extract position from request params for coalescing -/
def extractPosition (params : Json) : Option (String × Nat × Nat) := do
  let textDoc ← params.getObjVal? "textDocument" |>.toOption
  let uri ← textDoc.getObjValAs? String "uri" |>.toOption
  let pos ← params.getObjVal? "position" |>.toOption
  let line ← pos.getObjValAs? Nat "line" |>.toOption
  let char ← pos.getObjValAs? Nat "character" |>.toOption
  return (uri, line, char)

/-- Try to coalesce a request. Cancels any existing request for the same key. -/
def RequestCoalescer.tryCoalesce (rc : RequestCoalescer) (method : String) (params : Json)
    (requestId : RequestId) (cancelToken : IO.CancelToken) : IO Bool := do
  -- Only coalesce certain methods
  if !coalescableMethods.contains method then
    return true

  -- Extract position for coalescing key
  let some (uri, line, char) := extractPosition params
    | return true

  let key : CoalesceKey := { method, uri, line, character := char }

  -- Atomically swap in new request, get old one
  let maybeExisting ← rc.ref.modifyGet fun map =>
    (map.get? key, map.insert key { requestId, cancelToken })

  -- Cancel any existing request for the same key
  if let some existing := maybeExisting then
    existing.cancelToken.set

  return true

/-- Remove a completed request from the coalescer -/
def RequestCoalescer.complete (rc : RequestCoalescer) (method : String) (params : Json) : IO Unit := do
  if !coalescableMethods.contains method then
    return

  let some (uri, line, char) := extractPosition params
    | return

  let key : CoalesceKey := { method, uri, line, character := char }
  rc.ref.modify fun m => m.erase key

/-! ## Server Runtime -/

/-- Complete server runtime -/
structure ServerRuntime (UserState : Type) where
  /-- Server configuration -/
  config : ServerConfig UserState
  /-- VFS actor -/
  vfsActor : Actor VfsMsg VfsState
  /-- VFS reference -/
  vfs : VfsRef
  /-- Output channel -/
  outputChannel : OutputChannel
  /-- Pending requests for cancellation -/
  pendingRequests : PendingRequests
  /-- Request coalescer -/
  coalescer : RequestCoalescer
  /-- Pending responses for server-initiated requests -/
  pendingResponses : PendingResponses
  /-- User state reference -/
  userStateRef : IO.Ref UserState
  /-- Initialized flag -/
  initializedRef : IO.Ref Bool
  /-- Shutdown requested flag -/
  shutdownRef : IO.Ref Bool

namespace ServerRuntime

/-- Create a ServerContext for running a handler -/
def mkContext (rt : ServerRuntime UserState) (cancelToken : Option IO.CancelToken) : IO (ServerContext UserState) := do
  let userState ← rt.userStateRef.get
  let initialized ← rt.initializedRef.get
  let shutdownRequested ← rt.shutdownRef.get

  let state : ServerState UserState := {
    initialized
    shutdownRequested
    userState
  }
  let stateRef ← IO.mkRef state

  return {
    capabilities := rt.config.capabilities
    serverInfo := { name := rt.config.name, version := rt.config.version }
    outputChannel := rt.outputChannel
    vfs := rt.vfs
    stateRef
    pendingResponses := rt.pendingResponses
    cancelToken
  }

/-- Run a ServerM action and sync state changes back -/
def runServerM (rt : ServerRuntime UserState) (cancelToken : Option IO.CancelToken)
    (action : ServerM UserState α) : IO α := do
  let ctx ← rt.mkContext cancelToken
  let result ← action.run ctx

  -- Sync state changes back to runtime
  let state ← ctx.stateRef.get
  rt.userStateRef.set state.userState
  rt.initializedRef.set state.initialized
  rt.shutdownRef.set state.shutdownRequested

  return result

/-- Check if initialized -/
def isInitialized (rt : ServerRuntime UserState) : IO Bool :=
  rt.initializedRef.get

/-- Check if shutdown requested -/
def isShutdownRequested (rt : ServerRuntime UserState) : IO Bool :=
  rt.shutdownRef.get

/-- Shutdown the runtime -/
def shutdown (rt : ServerRuntime UserState) : IO Unit := do
  rt.outputChannel.shutdown
  rt.vfs.shutdown
  rt.vfsActor.join

end ServerRuntime

/-! ## Request Handling -/

/-- Handle the initialize request -/
private def handleInitialize (rt : ServerRuntime UserState) (params : InitializeParams) : IO InitializeResult := do
  rt.initializedRef.set true
  return {
    capabilities := rt.config.capabilities
    serverInfo := some { name := rt.config.name, version := rt.config.version }
  }

/-- Handle the shutdown request -/
private def handleShutdown (rt : ServerRuntime UserState) : IO Unit := do
  rt.shutdownRef.set true

/-- Dispatch a request -/
def dispatchRequest (rt : ServerRuntime UserState) (msg : RequestMessage)
    (cancelToken : IO.CancelToken) : IO Message := do
  -- Check if initialized (except for initialize request)
  if msg.method != "initialize" && !(← rt.isInitialized) then
    return mkErrorResponse (some msg.id) serverNotInitialized "Server not initialized"

  match msg.method with
  | "initialize" =>
    match msg.params with
    | none => return mkInvalidParams msg.id "Missing params"
    | some params =>
      match FromJson.fromJson? params with
      | .error e => return mkInvalidParams msg.id s!"Invalid params: {e}"
      | .ok initParams =>
        let result ← handleInitialize rt initParams
        return mkResponse msg.id (toJson result)

  | "shutdown" =>
    handleShutdown rt
    return mkResponse msg.id Json.null

  | method =>
    match rt.config.findRequestHandler method with
    | none => return mkMethodNotFound msg.id method
    | some handler =>
      let params := msg.params.getD (Json.mkObj [])
      match ← rt.runServerM (some cancelToken) (handler params) with
      | .ok result => return mkResponse msg.id result
      | .error code message => return mkErrorResponse (some msg.id) code message

/-- Dispatch a notification -/
def dispatchNotification (rt : ServerRuntime UserState) (msg : NotificationMessage) : IO Unit := do
  match msg.method with
  | "initialized" =>
    pure ()

  | "exit" =>
    pure ()

  | "textDocument/didOpen" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidOpenTextDocumentParams) params then
        rt.vfs.openDocument p

  | "textDocument/didChange" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidChangeTextDocumentParams) params then
        rt.vfs.changeDocument p

  | "textDocument/didClose" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidCloseTextDocumentParams) params then
        rt.vfs.closeDocument p

  | _ =>
    pure ()

  -- Run user notification handlers
  if let some handler := rt.config.findNotificationHandler msg.method then
    let params := msg.params.getD (Json.mkObj [])
    let _ ← IO.asTask (prio := .default) do
      try
        rt.runServerM none (handler params)
      catch _ =>
        pure ()

/-- Process a request asynchronously with cancellation support -/
def processRequestAsync (rt : ServerRuntime UserState) (msg : RequestMessage) : IO Unit := do
  let idStr := toString msg.id
  let cancelToken ← IO.CancelToken.new
  let params := msg.params.getD (Json.mkObj [])

  -- Register for cancellation
  rt.pendingRequests.add idStr cancelToken

  -- Try to coalesce this request
  let _ ← rt.coalescer.tryCoalesce msg.method params msg.id cancelToken

  let _task ← IO.asTask (prio := .default) do
    try
      -- Check if already cancelled before starting
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
        return

      let response ← dispatchRequest rt msg cancelToken

      -- Check if cancelled before sending response
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
      else
        rt.outputChannel.send response

      -- Clean up coalescer
      rt.coalescer.complete msg.method params

    catch e =>
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
      else
        rt.outputChannel.send (mkInternalError (some msg.id) s!"Handler error: {e}")
    finally
      rt.pendingRequests.remove idStr

  return ()

/-- Process a cancel notification -/
def processCancelRequest (rt : ServerRuntime UserState) (params : Json) : IO Unit := do
  if let .ok idJson := params.getObjVal? "id" then
    if let .ok reqId := FromJson.fromJson? (α := RequestId) idJson then
      let _ ← rt.pendingRequests.cancel (toString reqId)

/-! ## Main Server Loop -/

/-- The main message loop -/
partial def runMainLoop [Transport T] (transport : T) (rt : ServerRuntime UserState) : IO Unit := do
  let rec loop : IO Unit := do
    match ← Transport.readMessage transport with
    | none =>
      -- EOF, shutdown
      rt.shutdown
      return

    | some msg =>
      match msg with
      | .notification notif =>
        if notif.method == "exit" then
          let shutdownRequested ← rt.isShutdownRequested
          if shutdownRequested then
            rt.shutdown
            return
          else
            throw (IO.userError "Exit without shutdown")

        else if notif.method == "$/cancelRequest" then
          if let some params := notif.params then
            processCancelRequest rt params

        else
          dispatchNotification rt notif

      | .request req =>
        processRequestAsync rt req

      | .response resp =>
        rt.pendingResponses.execute resp.id resp.result

      | .errorResponse errResp =>
        match errResp.id with
        | some id =>
          let errorMsg := s!"Error {errResp.error.code}: {errResp.error.message}"
          rt.pendingResponses.executeError id errorMsg
        | none => pure ()

      loop

  loop

/-! ## Server Startup -/

/-- Create the server runtime -/
def createRuntime [Transport T] (transport : T) (config : ServerConfig UserState) : IO (ServerRuntime UserState) := do
  -- Create output channel
  let outputChannel ← OutputChannel.new (Transport.writeMessage transport)

  -- Spawn VFS actor
  let (vfsActor, vfs) ← spawnVfsActor

  -- Create pending requests tracker
  let pendingRequests ← PendingRequests.new

  -- Create request coalescer
  let coalescer ← RequestCoalescer.new

  -- Create pending responses
  let pendingResponses ← PendingResponses.new

  -- Create state refs
  let userStateRef ← IO.mkRef config.initialState
  let initializedRef ← IO.mkRef false
  let shutdownRef ← IO.mkRef false

  return {
    config
    vfsActor
    vfs
    outputChannel
    pendingRequests
    coalescer
    pendingResponses
    userStateRef
    initializedRef
    shutdownRef
  }

/-- Run the server with the given configuration -/
def runServer [Transport T] (transport : T) (config : ServerConfig UserState) : IO Unit := do
  let runtime ← createRuntime transport config
  runMainLoop transport runtime

/-- Run the server on stdio -/
def runStdio (config : ServerConfig UserState) : IO Unit := do
  let transport ← Stdio.create
  runServer transport config

end Lapis.Server.Dispatcher
