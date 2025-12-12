/-
  Concurrent Channel Primitives

  Provides bounded and unbounded channels for message passing between actors.
  These are the foundation of the actor model implementation.

  Built on Lean 4's IO.Promise for synchronization and atomic IO.Ref operations.
-/

namespace Lapis.Concurrent.Channel

/-! ## Unbounded Channel -/

/-- An unbounded MPSC (multi-producer, single-consumer) channel.
    Multiple actors can send messages, one actor receives them in order.
    Uses atomic IO.Ref operations - no mutex needed. -/
structure Unbounded (α : Type) where
  /-- Queue of pending messages -/
  queue : IO.Ref (Array α)
  /-- Promise for signaling new messages (recreated after each wait) -/
  signal : IO.Ref (IO.Promise Unit)

namespace Unbounded

/-- Create a new unbounded channel -/
def new : IO (Unbounded α) := do
  let queue ← IO.mkRef #[]
  let signal ← IO.Promise.new
  let signalRef ← IO.mkRef signal
  return { queue, signal := signalRef }

/-- Send a message to the channel (non-blocking).
    Uses atomic modify - safe for concurrent sends. -/
def send (ch : Unbounded α) (msg : α) : IO Unit := do
  -- Atomically add message to queue
  ch.queue.modify (·.push msg)
  -- Signal any waiting receiver (resolve is idempotent)
  let sig ← ch.signal.get
  sig.resolve ()

/-- Receive a message from the channel (blocking) -/
partial def recv (ch : Unbounded α) : IO α := do
  -- Atomically try to take from queue
  let result ← ch.queue.modifyGet fun q =>
    if h : 0 < q.size then
      (some q[0], q.extract 1 q.size)
    else
      (none, q)

  match result with
  | some msg => return msg
  | none =>
    -- No message, wait for signal then retry
    -- First refresh the signal for next wait
    let newSig ← IO.Promise.new
    let oldSig ← ch.signal.swap newSig
    -- Wait on the old signal
    let _ := oldSig.result!
    recv ch

/-- Try to receive a message without blocking -/
def tryRecv (ch : Unbounded α) : IO (Option α) := do
  ch.queue.modifyGet fun q =>
    if h : 0 < q.size then
      (some q[0], q.extract 1 q.size)
    else
      (none, q)

/-- Check if the channel has pending messages -/
def isEmpty (ch : Unbounded α) : IO Bool := do
  let q ← ch.queue.get
  return q.isEmpty

/-- Get the number of pending messages -/
def size (ch : Unbounded α) : IO Nat := do
  let q ← ch.queue.get
  return q.size

end Unbounded

/-! ## Bounded Channel -/

/-- A bounded MPSC channel with backpressure.
    Senders block when the channel is full.
    Uses atomic IO.Ref operations - no mutex needed. -/
structure Bounded (α : Type) where
  /-- Queue of pending messages -/
  queue : IO.Ref (Array α)
  /-- Maximum capacity -/
  capacity : Nat
  /-- Signal for receivers (queue not empty) -/
  notEmptySignal : IO.Ref (IO.Promise Unit)
  /-- Signal for senders (queue not full) -/
  notFullSignal : IO.Ref (IO.Promise Unit)

namespace Bounded

/-- Create a new bounded channel with given capacity -/
def new (capacity : Nat) : IO (Bounded α) := do
  let queue ← IO.mkRef #[]
  let notEmpty ← IO.Promise.new
  let notFull ← IO.Promise.new
  let notEmptyRef ← IO.mkRef notEmpty
  let notFullRef ← IO.mkRef notFull
  return { queue, capacity, notEmptySignal := notEmptyRef, notFullSignal := notFullRef }

/-- Send a message to the channel (blocks if full) -/
partial def send (ch : Bounded α) (msg : α) : IO Unit := do
  -- Atomically try to add to queue
  let couldSend ← ch.queue.modifyGet fun q =>
    if q.size < ch.capacity then
      (true, q.push msg)
    else
      (false, q)

  if couldSend then
    -- Signal receivers
    let sig ← ch.notEmptySignal.get
    sig.resolve ()
  else
    -- Wait for space then retry
    let newSig ← IO.Promise.new
    let oldSig ← ch.notFullSignal.swap newSig
    let _ := oldSig.result!
    send ch msg

/-- Try to send a message without blocking -/
def trySend (ch : Bounded α) (msg : α) : IO Bool := do
  let couldSend ← ch.queue.modifyGet fun q =>
    if q.size < ch.capacity then
      (true, q.push msg)
    else
      (false, q)

  if couldSend then
    let sig ← ch.notEmptySignal.get
    sig.resolve ()
  return couldSend

/-- Receive a message from the channel (blocking) -/
partial def recv (ch : Bounded α) : IO α := do
  let result ← ch.queue.modifyGet fun q =>
    if h : 0 < q.size then
      (some q[0], q.extract 1 q.size)
    else
      (none, q)

  match result with
  | some msg =>
    -- Signal senders that there's space
    let sig ← ch.notFullSignal.get
    sig.resolve ()
    return msg
  | none =>
    -- Wait for messages
    let newSig ← IO.Promise.new
    let oldSig ← ch.notEmptySignal.swap newSig
    let _ := oldSig.result!
    recv ch

/-- Try to receive a message without blocking -/
def tryRecv (ch : Bounded α) : IO (Option α) := do
  let result ← ch.queue.modifyGet fun q =>
    if h : 0 < q.size then
      (some q[0], q.extract 1 q.size)
    else
      (none, q)

  if result.isSome then
    let sig ← ch.notFullSignal.get
    sig.resolve ()
  return result

/-- Check if the channel is full -/
def isFull (ch : Bounded α) : IO Bool := do
  let q ← ch.queue.get
  return q.size >= ch.capacity

/-- Check if the channel is empty -/
def isEmpty (ch : Bounded α) : IO Bool := do
  let q ← ch.queue.get
  return q.isEmpty

end Bounded

/-! ## Oneshot Channel -/

/-- A oneshot channel for single request-response patterns.
    Can only be used once: one send, one receive. -/
structure Oneshot (α : Type) where
  promise : IO.Promise α

namespace Oneshot

/-- Create a new oneshot channel -/
def new [Nonempty α] : IO (Oneshot α) := do
  let promise ← IO.Promise.new
  return { promise }

/-- Send a value (can only be called once) -/
def send (ch : Oneshot α) (value : α) : IO Unit := do
  ch.promise.resolve value

/-- Receive the value (blocks until sent) -/
def recv (ch : Oneshot α) : IO α := do
  -- result! returns a Task, .get blocks until complete
  return ch.promise.result!.get

/-- Try to receive without blocking (returns none if not yet resolved) -/
def tryRecv (ch : Oneshot α) : IO (Option α) := do
  return ch.promise.result?.get

/-- Check if the value has been sent -/
def isReady (ch : Oneshot α) : IO Bool := do
  return (ch.promise.result?.get).isSome

end Oneshot

/-! ## Select (Multi-channel waiting) -/

/-- Result of a select operation -/
inductive SelectResult (α β : Type) where
  | first : α → SelectResult α β
  | second : β → SelectResult α β

/-- Wait on two unbounded channels, return whichever has a message first.
    Note: This is a polling implementation. -/
partial def selectTwo (ch1 : Unbounded α) (ch2 : Unbounded β) : IO (SelectResult α β) := do
  match ← ch1.tryRecv with
  | some msg => return .first msg
  | none =>
    match ← ch2.tryRecv with
    | some msg => return .second msg
    | none =>
      -- Brief sleep to avoid busy waiting
      IO.sleep 1
      selectTwo ch1 ch2

end Lapis.Concurrent.Channel
