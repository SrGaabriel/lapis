import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Transport.Base
import Lapis.Transport.Stdio
import Lapis.Server.Monad
import Lapis.Server.Builder
import Lapis.Server.Receiver
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
open Std (HashMap)

structure PendingRequests where
  ref : IO.Ref (HashMap String IO.CancelToken)
  mutex : AsyncMutex

def PendingRequests.new : IO PendingRequests := do
  let ref ← IO.mkRef (HashMap.emptyWithCapacity 16)
  let mutex ← AsyncMutex.new
  return { ref, mutex }

def PendingRequests.add (pr : PendingRequests) (id : String) (token : IO.CancelToken) : IO Unit := do
  pr.mutex.withLock do
    pr.ref.modify fun m => m.insert id token

def PendingRequests.remove (pr : PendingRequests) (id : String) : IO Unit := do
  pr.mutex.withLock do
    pr.ref.modify fun m => m.erase id

def PendingRequests.cancel (pr : PendingRequests) (id : String) : IO Bool := do
  pr.mutex.withLock do
    let m ← pr.ref.get
    match m.get? id with
    | some token =>
      token.set
      pr.ref.modify fun m => m.erase id
      return true
    | none =>
      return false

/-- Handle the initialize request -/
private def handleInitialize (config : ServerConfig UserState) (_params : InitializeParams) : ServerM UserState InitializeResult := do
  setInitialized
  return {
    capabilities := config.capabilities
    serverInfo := some { name := config.name, version := config.version }
  }

/-- Handle the shutdown request -/
private def handleShutdown : ServerM UserState Unit := do
  requestShutdown

/-- Dispatch a request and return the response -/
def dispatchRequest (config : ServerConfig UserState) (msg : RequestMessage) : ServerM UserState Message := do
  -- Check if initialized (except for initialize request)
  if msg.method != "initialize" && !(← isInitialized) then
    return mkErrorResponse (some msg.id) serverNotInitialized "Server not initialized"

  match msg.method with
  | "initialize" =>
    match msg.params with
    | none => return mkInvalidParams msg.id "Missing params"
    | some params =>
      match FromJson.fromJson? params with
      | .error e => return mkInvalidParams msg.id s!"Invalid params: {e}"
      | .ok initParams =>
        let result ← handleInitialize config initParams
        return mkResponse msg.id (toJson result)

  | "shutdown" =>
    handleShutdown
    return mkResponse msg.id Json.null

  | method =>
    match config.findRequestHandler method with
    | none => return mkMethodNotFound msg.id method
    | some handler =>
      let params := msg.params.getD (Json.mkObj [])
      match ← handler params with
      | .ok result => return mkResponse msg.id result
      | .error code message => return mkErrorResponse (some msg.id) code message

/-- Dispatch a notification -/
def dispatchNotification (config : ServerConfig UserState) (msg : NotificationMessage) : ServerM UserState Unit := do
  match msg.method with
  | "initialized" =>
    pure ()

  | "exit" =>
    pure ()

  | "textDocument/didOpen" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidOpenTextDocumentParams) params then
        openDocument p

  | "textDocument/didChange" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidChangeTextDocumentParams) params then
        changeDocument p

  | "textDocument/didClose" =>
    if let some params := msg.params then
      if let .ok p := FromJson.fromJson? (α := DidCloseTextDocumentParams) params then
        closeDocument p

  | _ =>
    pure ()

  if let some handler := config.findNotificationHandler msg.method then
    let params := msg.params.getD (Json.mkObj [])
    let _ ← handler params
    pure ()

structure ServerRuntime (UserState : Type) where
  config : ServerConfig UserState
  context : ServerContext UserState
  pendingRequests : PendingRequests
  outputChannel : OutputChannel

/-- Run a ServerM action with the runtime context -/
def ServerRuntime.run (rt : ServerRuntime UserState) (action : ServerM UserState α) : IO α := do
  action.run rt.context

def processRequestAsync (rt : ServerRuntime UserState) (msg : RequestMessage) : IO Unit := do
  let idStr := toString msg.id
  let cancelToken ← IO.CancelToken.new

  rt.pendingRequests.add idStr cancelToken

  let _task ← IO.asTask (prio := .default) do
    try
      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
        return

      let response ← rt.run (dispatchRequest rt.config msg)

      if ← cancelToken.isSet then
        rt.outputChannel.send (mkErrorResponse (some msg.id) requestCancelled "Request cancelled")
      else
        rt.outputChannel.send response
    catch e =>
      rt.outputChannel.send (mkInternalError (some msg.id) s!"Handler error: {e}")
    finally
      rt.pendingRequests.remove idStr

  return ()

def processNotification (rt : ServerRuntime UserState) (msg : NotificationMessage) : IO Unit := do
  if msg.method == "$/cancelRequest" then
    if let some params := msg.params then
      if let .ok idJson := params.getObjVal? "id" then
        if let .ok reqId := FromJson.fromJson? (α := RequestId) idJson then
          let _ ← rt.pendingRequests.cancel (toString reqId)
    return

  match msg.method with
  | "textDocument/didOpen" | "textDocument/didChange" | "textDocument/didClose" | "initialized" =>
    let _ ← rt.run (dispatchNotification rt.config msg)
    pure ()
  | _ =>
    let _task ← IO.asTask (prio := .default) do
      try
        rt.run (dispatchNotification rt.config msg)
      catch _ =>
        -- Notifications don't have responses, so we just log errors (todo)
        pure ()
    return ()

partial def runServer [Transport T] (transport : T) (config : ServerConfig UserState) : IO Unit := do
  let outputChannel ← OutputChannel.new (Transport.writeMessage transport)

  let initialState : ServerState UserState := {
    userState := config.initialState
  }
  let stateRef ← IO.mkRef initialState
  let stateMutex ← AsyncMutex.new

  let pendingResponses ← PendingResponses.new

  let ctx : ServerContext UserState := {
    capabilities := config.capabilities
    serverInfo := { name := config.name, version := config.version }
    outputChannel := outputChannel
    stateRef := stateRef
    stateMutex := stateMutex
    pendingResponses := pendingResponses
  }

  let pendingRequests ← PendingRequests.new

  let runtime : ServerRuntime UserState := {
    config := config
    context := ctx
    pendingRequests := pendingRequests
    outputChannel := outputChannel
  }

  let rec loop : IO Unit := do
    match ← Transport.readMessage transport with
    | none =>
      -- EOF, exit
      return ()
    | some msg =>
      match msg with
      | .notification notif =>
        if notif.method == "exit" then
          let state ← stateRef.get
          if state.shutdownRequested then
            return ()
          else
            throw (IO.userError "Exit without shutdown")
        else
          processNotification runtime notif

      | .request req =>
        processRequestAsync runtime req

      | .response resp =>
        pendingResponses.execute resp.id resp.result
        pure ()

      | .errorResponse errResp =>
        match errResp.id with
        | some id =>
          let errorMsg := s!"Error {errResp.error.code}: {errResp.error.message}"
          pendingResponses.executeError id errorMsg
        | none => pure ()
        pure ()

      loop

  loop

def runStdio (config : ServerConfig UserState) : IO Unit := do
  let transport ← Stdio.create
  runServer transport config

end Lapis.Server.Dispatcher
