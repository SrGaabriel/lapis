import Lapis.Protocol.JsonRpc

namespace Lapis.Transport

open Lapis.Protocol.JsonRpc

class Transport (T : Type) where
  readMessage : T → IO (Option Message)
  writeMessage : T → Message → IO Unit
  close : T → IO Unit

/-- A simple async mutex built on IO.Promise.
    Guarantees mutual exclusion for critical sections. -/
structure AsyncMutex where
  /-- Reference to the current lock state: none = unlocked, some promise = locked -/
  state : IO.Ref (Option (IO.Promise Unit))

def AsyncMutex.new : BaseIO AsyncMutex := do
  let state ← IO.mkRef none
  return { state }

/-- Acquire the lock. Blocks until the lock is available. -/
partial def AsyncMutex.lock (m : AsyncMutex) : IO Unit := do
  -- Try to acquire the lock
  let myPromise ← IO.Promise.new (α := Unit)
  let prev ← m.state.modifyGet fun s =>
    match s with
    | none => (none, some myPromise)  -- We got the lock
    | some p => (some p, some myPromise)  -- Someone else has it, we'll wait and then take it
  match prev with
  | none => return ()  -- We acquired the lock immediately
  | some p =>
    -- Wait for the previous holder to release
    let _ := p.result?.get  -- Block until resolved
    -- Now try again (the previous holder released, but someone else might have grabbed it)
    m.lock

/-- Release the lock. -/
def AsyncMutex.unlock (m : AsyncMutex) : IO Unit := do
  let prev ← m.state.swap none
  match prev with
  | none => return ()  -- Wasn't locked (shouldn't happen in correct usage)
  | some p => p.resolve ()  -- Wake up any waiters

/-- Run an action while holding the lock. -/
def AsyncMutex.withLock (m : AsyncMutex) (action : IO α) : IO α := do
  m.lock
  try
    action
  finally
    m.unlock

/-- A thread-safe output channel for sending messages to the client.
    Multiple tasks can safely send messages through this channel. -/
structure OutputChannel where
  /-- Mutex to ensure only one message is written at a time -/
  mutex : AsyncMutex
  /-- The write function (captured from transport) -/
  write : Message → IO Unit

def OutputChannel.new (writeFunc : Message → IO Unit) : IO OutputChannel := do
  let mutex ← AsyncMutex.new
  return { mutex, write := writeFunc }

/-- Send a message through the output channel (thread-safe) -/
def OutputChannel.send (ch : OutputChannel) (msg : Message) : IO Unit := do
  ch.mutex.withLock do
    ch.write msg

/-- Send a notification through the output channel -/
def OutputChannel.sendNotification (ch : OutputChannel) (method : String) (params : Lean.Json) : IO Unit := do
  let notif : NotificationMessage := { method, params := some params }
  ch.send (.notification notif)

/-- Send a request through the output channel -/
def OutputChannel.sendRequest (ch : OutputChannel) (id : RequestId) (method : String) (params : Lean.Json) : IO Unit := do
  let req : RequestMessage := { id, method, params := some params }
  ch.send (.request req)

partial def messageLoop [Transport T] (transport : T) (handler : Message → IO (Option Message)) : IO Unit := do
  match ← Transport.readMessage transport with
  | none => return () -- EOF
  | some msg =>
    if let some response ← handler msg then
      Transport.writeMessage transport response
    messageLoop transport handler

end Lapis.Transport
