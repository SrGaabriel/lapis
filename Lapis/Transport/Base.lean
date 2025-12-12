import Lapis.Protocol.JsonRpc

namespace Lapis.Transport

open Lapis.Protocol.JsonRpc

class Transport (T : Type) where
  readMessage : T → IO (Option Message)
  writeMessage : T → Message → IO Unit
  close : T → IO Unit

/-! ## Writer Actor for Output Channel -/

/-- A thread-safe output channel for sending messages to the client.
    Uses a simple polling approach with the queue itself as the signal. -/
structure OutputChannel where
  /-- Queue of pending messages -/
  queue : IO.Ref (Array Message)
  /-- Shutdown flag -/
  shutdownFlag : IO.Ref Bool
  /-- Writer task -/
  task : Task (Except IO.Error Unit)

namespace OutputChannel

/-- The writer loop that processes messages -/
private partial def writerLoop (queue : IO.Ref (Array Message))
    (shutdownFlag : IO.Ref Bool) (writeFunc : Message → IO Unit) : IO Unit := do
  -- Check shutdown
  if ← shutdownFlag.get then return

  -- Try to get messages
  let msgs ← queue.swap #[]

  if msgs.isEmpty then
    -- No messages, brief sleep and retry
    IO.sleep 1
    writerLoop queue shutdownFlag writeFunc
  else
    -- Write all messages
    for msg in msgs do
      writeFunc msg
    writerLoop queue shutdownFlag writeFunc

/-- Create a new output channel with a writer actor -/
def new (writeFunc : Message → IO Unit) : IO OutputChannel := do
  let queue ← IO.mkRef #[]
  let shutdownFlag ← IO.mkRef false

  -- Spawn writer actor
  let task ← IO.asTask (prio := .default) (writerLoop queue shutdownFlag writeFunc)

  return { queue, shutdownFlag, task }

/-- Send a message through the output channel (non-blocking) -/
def send (ch : OutputChannel) (msg : Message) : IO Unit := do
  ch.queue.modify (·.push msg)

/-- Send a notification through the output channel -/
def sendNotification (ch : OutputChannel) (method : String) (params : Lean.Json) : IO Unit := do
  let notif : NotificationMessage := { method, params := some params }
  ch.send (.notification notif)

/-- Send a request through the output channel -/
def sendRequest (ch : OutputChannel) (id : RequestId) (method : String) (params : Lean.Json) : IO Unit := do
  let req : RequestMessage := { id, method, params := some params }
  ch.send (.request req)

/-- Shutdown the writer actor -/
def shutdown (ch : OutputChannel) : IO Unit := do
  ch.shutdownFlag.set true
  -- Wait for writer to finish
  let _ ← IO.wait ch.task

end OutputChannel

partial def messageLoop [Transport T] (transport : T) (handler : Message → IO (Option Message)) : IO Unit := do
  match ← Transport.readMessage transport with
  | none => return () -- EOF
  | some msg =>
    if let some response ← handler msg then
      Transport.writeMessage transport response
    messageLoop transport handler

end Lapis.Transport
