import Lapis.Transport.Base
import Lapis.Protocol.JsonRpc
import Lapis.Concurrent.Channel
import Std.Data.HashMap

namespace Lapis.Server.Receiver

open Lean Json
open Lapis.Transport
open Lapis.Concurrent (AtomicCounter)
open Std (HashMap)
open Lapis.Protocol.JsonRpc

/-- Tracks pending responses for server-initiated requests.
    Uses atomic IO.Ref operations - no mutex needed. -/
structure PendingResponses where
  ref : IO.Ref (HashMap RequestId (IO.Promise Json))
  nextId : AtomicCounter

def PendingResponses.new : IO PendingResponses := do
  let ref ← IO.mkRef (HashMap.emptyWithCapacity 16)
  let nextId ← AtomicCounter.new
  return { ref, nextId }

private def PendingResponses.add (pr : PendingResponses) (id : RequestId) (token : IO.Promise Json) : IO Unit := do
  pr.ref.modify fun m => m.insert id token

def PendingResponses.register (pr : PendingResponses) (promise : IO.Promise Json) : IO RequestId := do
  let id ← pr.nextId.incrementAndGet
  let reqId := RequestId.num id
  pr.add reqId promise
  return reqId

private def PendingResponses.remove (pr : PendingResponses) (id : RequestId) : IO Unit := do
  pr.ref.modify fun m => m.erase id

def PendingResponses.execute (pr : PendingResponses) (id : RequestId) (payload : Json) : IO Unit := do
  -- Atomically remove and get the promise
  let maybePromise ← pr.ref.modifyGet fun m =>
    (m.get? id, m.erase id)
  match maybePromise with
  | some promise => promise.resolve payload
  | none => return

def PendingResponses.executeError (pr : PendingResponses) (id : RequestId) (error : String) : IO Unit := do
  -- Atomically remove and get the promise
  let maybePromise ← pr.ref.modifyGet fun m =>
    (m.get? id, m.erase id)
  match maybePromise with
  | some promise =>
    -- Resolve with an error marker JSON object
    promise.resolve (Json.mkObj [("error", Json.str error)])
  | none => return
