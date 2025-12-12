import Lapis.Protocol.JsonRpc

namespace Lapis.Transport

open Lapis.Protocol.JsonRpc

class Transport (T : Type) where
  readMessage : T → IO (Option Message)
  writeMessage : T → Message → IO Unit
  close : T → IO Unit

/-! ## Writer Actor for Output Channel -/

/-- State for the output writer actor -/
private structure WriterState where
  /-- Queue of pending messages -/
  queue : IO.Ref (Array Message)
  /-- Signal for new messages -/
  signal : IO.Ref (IO.Promise Unit)
  /-- Shutdown flag -/
  shutdown : IO.Ref Bool

/-- A thread-safe output channel for sending messages to the client -/
structure OutputChannel where
  /-- Writer state -/
  state : WriterState
  /-- Writer task -/
  task : Task (Except IO.Error Unit)

namespace OutputChannel

/-- The writer loop that processes messages -/
private partial def writerLoop (state : WriterState) (writeFunc : Message → IO Unit) : IO Unit := do
  -- Check shutdown
  if ← state.shutdown.get then return

  -- Try to get messages
  let msgs ← state.queue.swap #[]

  if msgs.isEmpty then
    -- Wait for signal
    let sig ← state.signal.get
    let _ := sig.result!
    writerLoop state writeFunc
  else
    -- Write all messages
    for msg in msgs do
      writeFunc msg
    writerLoop state writeFunc

/-- Create a new output channel with a writer actor -/
def new (writeFunc : Message → IO Unit) : IO OutputChannel := do
  let queue ← IO.mkRef #[]
  let signal ← IO.Promise.new
  let signalRef ← IO.mkRef signal
  let shutdown ← IO.mkRef false
  let state : WriterState := { queue, signal := signalRef, shutdown }

  -- Spawn writer actor
  let task ← IO.asTask (prio := .default) (writerLoop state writeFunc)

  return { state, task }

/-- Send a message through the output channel (non-blocking) -/
def send (ch : OutputChannel) (msg : Message) : IO Unit := do
  -- Add message to queue
  ch.state.queue.modify (·.push msg)
  -- Signal the writer
  let sig ← ch.state.signal.get
  sig.resolve ()
  -- Create new signal for next wait
  let newSig ← IO.Promise.new
  ch.state.signal.set newSig

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
  ch.state.shutdown.set true
  -- Signal to wake up the writer if it's waiting
  let sig ← ch.state.signal.get
  sig.resolve ()
  -- Wait for writer to finish
  let _ ← IO.wait ch.task

end OutputChannel

end Lapis.Transport
