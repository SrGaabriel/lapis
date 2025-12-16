/-
  Actor-Based Message Dispatcher

  The main loop that:
  - Reads messages from the transport
  - Routes them to the appropriate actors
  - Never blocks on handler execution

  This is the thin coordination layer of the actor model.
-/

import Lapis.Concurrent.Actor
import Lapis.Concurrent.VfsActor
import Lapis.Concurrent.LspActor
import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Transport.Base
import Lapis.Transport.Stdio
import Lapis.Server.Receiver

namespace Lapis.Concurrent.Dispatcher

open Lean Json
open Lapis.Concurrent.Actor
open Lapis.Concurrent.VfsActor
open Lapis.Concurrent.LspActor
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Transport
open Lapis.Server.Receiver

/-! ## Server Runtime -/

/-- Complete server runtime with all actors -/
structure ServerRuntime (UserState : Type) where
  /-- VFS actor for document management -/
  vfsActor : Actor VfsMsg VfsState
  /-- VFS reference for sending messages -/
  vfs : VfsRef
  /-- LSP actor for request handling -/
  lspActor : Actor (LspMsg UserState) (LspState UserState)
  /-- LSP reference for sending messages -/
  lsp : LspRef UserState
  /-- Output channel for responses -/
  outputChannel : OutputChannel
  /-- Pending responses for server-initiated requests -/
  pendingResponses : PendingResponses
  /-- User state reference (for notifications that need to update it) -/
  userStateRef : IO.Ref UserState

namespace ServerRuntime

/-- Get current user state -/
def getUserState (rt : ServerRuntime UserState) : IO UserState :=
  rt.userStateRef.get

/-- Modify user state -/
def modifyUserState (rt : ServerRuntime UserState) (f : UserState → UserState) : IO Unit :=
  rt.userStateRef.modify f

/-- Set user state -/
def setUserState (rt : ServerRuntime UserState) (state : UserState) : IO Unit :=
  rt.userStateRef.set state

/-- Shutdown all actors -/
def shutdown (rt : ServerRuntime UserState) : IO Unit := do
  rt.lsp.shutdown
  rt.vfs.shutdown
  rt.lspActor.join
  rt.vfsActor.join

end ServerRuntime

/-! ## Message Routing -/

private def routeNotification
  (rt : ServerRuntime UserState)
  (msg : NotificationMessage) : IO Unit := do

  match msg.method with
  | "textDocument/didOpen" =>
    if let some params := msg.params then
      if let .ok p :=
        FromJson.fromJson? (α := DidOpenTextDocumentParams) params then
        rt.vfs.openDocument p

  | "textDocument/didChange" =>
    if let some params := msg.params then
      if let .ok p :=
        FromJson.fromJson? (α := DidChangeTextDocumentParams) params then
        rt.vfs.changeDocument p

  | "textDocument/didClose" =>
    if let some params := msg.params then
      if let .ok p :=
        FromJson.fromJson? (α := DidCloseTextDocumentParams) params then
        rt.vfs.closeDocument p

  | "$/cancelRequest" =>
    if let some params := msg.params then
      if let .ok idJson := params.getObjVal? "id" then
        if let .ok reqId :=
          FromJson.fromJson? (α := RequestId) idJson then
          rt.lsp.cancelRequest reqId

  | _ =>
    pure ()

  -- Everything goes to LSP actor
  rt.lsp.handleNotification msg

/-- Route a request to the LSP actor -/
private def routeRequest (rt : ServerRuntime UserState) (msg : RequestMessage) : IO Unit := do
  rt.lsp.handleRequest msg

/-- Route a response to the LSP actor -/
private def routeResponse (rt : ServerRuntime UserState) (id : RequestId) (result : Json) : IO Unit := do
  rt.lsp.handleResponse id result

/-- Route an error response to the LSP actor -/
private def routeErrorResponse (rt : ServerRuntime UserState) (id : RequestId) (error : String) : IO Unit := do
  rt.lsp.handleErrorResponse id error

/-! ## Main Loop -/

/-- The main message loop - reads from transport and routes to actors -/
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
          -- Check if shutdown was requested
          -- For now, we'll just exit
          rt.shutdown
          return
        else
          routeNotification rt notif

      | .request req =>
        routeRequest rt req

      | .response resp =>
        routeResponse rt resp.id resp.result

      | .errorResponse errResp =>
        match errResp.id with
        | some id =>
          let errorMsg := s!"Error {errResp.error.code}: {errResp.error.message}"
          routeErrorResponse rt id errorMsg
        | none => pure ()

      loop

  loop

/-! ## Server Startup -/

/-- Create and start the server runtime -/
def createRuntime [Transport T] (transport : T) (config : LspConfig UserState)
    (initialState : UserState) : IO (ServerRuntime UserState) := do
  -- Create output channel
  let outputChannel ← OutputChannel.new (Transport.writeMessage transport)

  -- Create pending responses
  let pendingResponses ← PendingResponses.new

  -- Create user state ref
  let userStateRef ← IO.mkRef initialState

  -- Spawn VFS actor
  let (vfsActor, vfs) ← spawnVfsActor

  -- Spawn LSP actor
  let (lspActor, lsp) ← spawnLspActor config vfs outputChannel pendingResponses userStateRef

  return {
    vfsActor, vfs
    lspActor, lsp
    outputChannel
    pendingResponses
    userStateRef
  }

/-- Run the server with the given configuration -/
def runServer [Transport T] (transport : T) (config : LspConfig UserState)
    (initialState : UserState) : IO Unit := do
  let runtime ← createRuntime transport config initialState
  runMainLoop transport runtime

/-- Run the server on stdio -/
def runStdio (config : LspConfig UserState) (initialState : UserState) : IO Unit := do
  let transport ← Stdio.create
  runServer transport config initialState

end Lapis.Concurrent.Dispatcher
