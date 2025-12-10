import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Transport.Base
import Lapis.Transport.Stdio
import Lapis.Server.Monad
import Lapis.Server.Builder

namespace Lapis.Server.Dispatcher

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Transport
open Lapis.Server.Monad
open Lapis.Server.Builder

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

/-- Dispatch a request -/
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
  -- Handle built-in notifications
  match msg.method with
  | "initialized" =>
    -- Client signals it received initialize result
    pure ()

  | "exit" =>
    -- Exit is handled specially in the main loop
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

  | method =>
    -- Look for user-defined handler
    if let some handler := config.findNotificationHandler method then
      let params := msg.params.getD (Json.mkObj [])
      handler params

/-- Process a single message -/
def processMessage (config : ServerConfig UserState) (msg : Message) : ServerM UserState (Option Message) := do
  match msg with
  | .request req =>
    let response ← dispatchRequest config req
    return some response

  | .notification notif =>
    dispatchNotification config notif
    return none

  | .response _ =>
    -- TODO: handle responses
    return none

  | .errorResponse _ =>
    -- TODO: handle error responses
    return none

partial def runServer [Transport T] (transport : T) (config : ServerConfig UserState) : IO Unit := do
  let ctx : ServerContext := {
    capabilities := config.capabilities
    serverInfo := { name := config.name, version := config.version }
  }
  let initialState : ServerState UserState := {
    userState := config.initialState
  }

  let rec loop (state : ServerState UserState) : IO Unit := do
    match ← Transport.readMessage transport with
    | none =>
      -- EOF, exit
      return ()
    | some msg =>
      -- Check for exit notification
      if let .notification notif := msg then
        if notif.method == "exit" then
          -- Exit with 0 if shutdown was requested, 1 otherwise
          if state.shutdownRequested then
            return ()
          else
            throw (IO.userError "Exit without shutdown")

      let (response, newState) ← (processMessage config msg).run ctx state

      if let some resp := response then
        Transport.writeMessage transport resp

      loop newState

  loop initialState

def runStdio (config : ServerConfig UserState) : IO Unit := do
  let transport ← Stdio.create
  runServer transport config

end Lapis.Server.Dispatcher
