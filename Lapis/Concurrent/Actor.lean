/-
  Actor Model Primitives

  Provides the core actor abstraction for concurrent message processing.
  Each actor:
  - Owns its state exclusively (no shared mutable state)
  - Processes messages sequentially from its mailbox
  - Communicates with other actors only via message passing
-/

import Lapis.Concurrent.Channel

namespace Lapis.Concurrent.Actor

open Channel

/-! ## Actor Types -/

/-- A handle to send messages to an actor.
    Can be freely cloned and shared across threads. -/
structure ActorRef (Msg : Type) where
  mailbox : Unbounded Msg

namespace ActorRef

/-- Send a message to the actor -/
def send (ref : ActorRef Msg) (msg : Msg) : IO Unit :=
  ref.mailbox.send msg

/-- Send a message and get a response via oneshot channel -/
def call [Nonempty Resp] (ref : ActorRef Msg) (mkMsg : Oneshot Resp → Msg) : IO Resp := do
  let reply ← Oneshot.new
  ref.send (mkMsg reply)
  reply.recv

/-- Try to send without blocking (always succeeds for unbounded) -/
def trySend (ref : ActorRef Msg) (msg : Msg) : IO Bool := do
  ref.mailbox.send msg
  return true

end ActorRef

/-- Actor lifecycle state -/
inductive ActorStatus where
  | running
  | stopping
  | stopped
  deriving BEq, Repr

/-- Configuration for actor behavior -/
structure ActorConfig where
  /-- Name for debugging/logging -/
  name : String := "anonymous"
  /-- Whether to restart on handler panic -/
  restartOnPanic : Bool := false

/-- A running actor instance -/
structure Actor (Msg State : Type) where
  /-- Reference to send messages -/
  ref : ActorRef Msg
  /-- The running task -/
  task : Task (Except IO.Error Unit)
  /-- Actor status -/
  status : IO.Ref ActorStatus
  /-- Configuration -/
  config : ActorConfig

namespace Actor

/-- Check if the actor is still running -/
def isRunning (actor : Actor Msg State) : IO Bool := do
  let status ← actor.status.get
  return status == .running

/-- Request the actor to stop (gracefully) -/
def stop (actor : Actor Msg State) : IO Unit := do
  actor.status.set .stopping

/-- Wait for the actor to finish -/
def join (actor : Actor Msg State) : IO Unit := do
  let _ ← IO.wait actor.task

/-- Stop and wait for the actor to finish -/
def shutdown (actor : Actor Msg State) : IO Unit := do
  actor.stop
  actor.join

/-- Get the actor's reference for sending messages -/
def getRef (actor : Actor Msg State) : ActorRef Msg :=
  actor.ref

end Actor

/-! ## Actor Spawning -/

/-- Message handler result -/
inductive HandleResult (State : Type) where
  /-- Continue with new state -/
  | continue (state : State)
  /-- Stop the actor -/
  | stop
  /-- Stop with error -/
  | error (msg : String)

/-- Internal actor loop implementation -/
private partial def actorLoop (mailbox : Unbounded Msg) (status : IO.Ref ActorStatus)
    (handler : State → Msg → IO (HandleResult State)) (state : State) : IO Unit := do
  let currentStatus ← status.get
  if currentStatus != .running then
    status.set .stopped
    return

  -- Try to get a message (with timeout to check status)
  match ← mailbox.tryRecv with
  | none =>
    -- No message, brief sleep and retry
    IO.sleep 1
    actorLoop mailbox status handler state
  | some msg =>
    match ← handler state msg with
    | .continue newState => actorLoop mailbox status handler newState
    | .stop =>
      status.set .stopped
      return
    | .error _ =>
      status.set .stopped
      return

/-- Internal actor loop with error handling -/
private partial def actorLoopWithErrors (mailbox : Unbounded Msg) (status : IO.Ref ActorStatus)
    (handler : State → Msg → IO (HandleResult State))
    (onError : String → IO Unit) (config : ActorConfig) (state : State) : IO Unit := do
  let currentStatus ← status.get
  if currentStatus != .running then
    status.set .stopped
    return

  match ← mailbox.tryRecv with
  | none =>
    IO.sleep 1
    actorLoopWithErrors mailbox status handler onError config state
  | some msg =>
    try
      match ← handler state msg with
      | .continue newState => actorLoopWithErrors mailbox status handler onError config newState
      | .stop =>
        status.set .stopped
        return
      | .error errMsg =>
        onError errMsg
        if config.restartOnPanic then
          actorLoopWithErrors mailbox status handler onError config state
        else
          status.set .stopped
          return
    catch e =>
      onError s!"Actor '{config.name}' panicked: {e}"
      if config.restartOnPanic then
        actorLoopWithErrors mailbox status handler onError config state
      else
        status.set .stopped
        return

/-- Spawn a new actor with the given initial state and message handler.
    The handler is called sequentially for each message. -/
def spawn (initialState : State) (handler : State → Msg → IO (HandleResult State))
    (config : ActorConfig := {}) : IO (Actor Msg State) := do
  let mailbox ← Unbounded.new
  let status ← IO.mkRef ActorStatus.running
  let ref : ActorRef Msg := { mailbox }

  let task ← IO.asTask (prio := .default) (actorLoop mailbox status handler initialState)

  return { ref, task, status, config }

/-- Spawn an actor that can handle IO errors gracefully -/
def spawnWithErrorHandler (initialState : State)
    (handler : State → Msg → IO (HandleResult State))
    (onError : String → IO Unit)
    (config : ActorConfig := {}) : IO (Actor Msg State) := do
  let mailbox ← Unbounded.new
  let status ← IO.mkRef ActorStatus.running
  let ref : ActorRef Msg := { mailbox }

  let task ← IO.asTask (prio := .default)
    (actorLoopWithErrors mailbox status handler onError config initialState)

  return { ref, task, status, config }

/-! ## Typed Request-Response Pattern -/

/-- A request message that expects a response -/
structure Request (Req Resp : Type) where
  payload : Req
  replyTo : Oneshot Resp

namespace Request

/-- Create a request and get the response channel -/
def new [Nonempty Resp] (payload : Req) : IO (Request Req Resp × Oneshot Resp) := do
  let reply ← Oneshot.new
  return ({ payload, replyTo := reply }, reply)

/-- Reply to a request -/
def reply (req : Request Req Resp) (response : Resp) : IO Unit :=
  req.replyTo.send response

end Request

/-- Send a request to an actor and wait for response -/
def ask [Nonempty Resp] (ref : ActorRef Msg) (mkRequest : Request Req Resp → Msg)
    (payload : Req) : IO Resp := do
  let (request, reply) ← Request.new payload
  ref.send (mkRequest request)
  reply.recv

/-! ## Actor Supervision -/

/-- A supervisor that manages multiple actors -/
structure Supervisor where
  /-- All managed actors (as tasks) -/
  actors : IO.Ref (Array (Task (Except IO.Error Unit)))
  /-- Supervisor status -/
  status : IO.Ref ActorStatus

namespace Supervisor

/-- Create a new supervisor -/
def new : IO Supervisor := do
  let actors ← IO.mkRef #[]
  let status ← IO.mkRef .running
  return { actors, status }

/-- Add an actor to supervision -/
def supervise (sup : Supervisor) (actor : Actor Msg State) : IO Unit := do
  sup.actors.modify (·.push actor.task)

/-- Shutdown all supervised actors -/
def shutdownAll (sup : Supervisor) : IO Unit := do
  sup.status.set .stopping
  let tasks ← sup.actors.get
  for task in tasks do
    let _ ← IO.wait task
  sup.status.set .stopped

end Supervisor

/-! ## Utility Functions -/

/-- Create an actor ref from an existing mailbox -/
def refFromMailbox (mailbox : Unbounded Msg) : ActorRef Msg :=
  { mailbox }

/-- Broadcast a message to multiple actors -/
def broadcast (refs : Array (ActorRef Msg)) (msg : Msg) : IO Unit := do
  for ref in refs do
    ref.send msg

end Lapis.Concurrent.Actor
