import Lapis.Transport.Base
import Lapis.Protocol.JsonRpc
import Std.Data.HashMap

namespace Lapis.Server.Receiver

open Lean Json
open Lapis.Transport
open Std (HashMap)
open Lapis.Protocol.JsonRpc

structure PendingResponses where
  ref : IO.Ref (HashMap RequestId (IO.Promise Json))
  mutex : AsyncMutex
  nextId : IO.Ref Nat

def PendingResponses.new : IO PendingResponses := do
  let ref ← IO.mkRef (HashMap.emptyWithCapacity 16)
  let mutex ← AsyncMutex.new
  let nextId ← IO.mkRef 0
  return { ref, mutex, nextId }

def PendingResponses.register (pr : PendingResponses) (promise : IO.Promise Json) : IO RequestId := do
  pr.mutex.withLock do
    let id ← pr.nextId.get
    pr.nextId.set (id + 1)
    let reqId := RequestId.num id
    pr.ref.modify fun m => m.insert reqId promise
    return reqId

def PendingResponses.add (pr : PendingResponses) (id : RequestId) (token : IO.Promise (Json)) : IO Unit := do
  pr.mutex.withLock do
    pr.ref.modify fun m => m.insert id token

def PendingResponses.remove (pr : PendingResponses) (id : RequestId) : IO Unit := do
  pr.mutex.withLock do
    pr.ref.modify fun m => m.erase id

def PendingResponses.execute (pr : PendingResponses) (id : RequestId) (payload : Json) : IO Unit := do
  pr.mutex.withLock do
    let m ← pr.ref.get
    match m.get? id with
    | some promise =>
      pr.ref.modify fun m => m.erase id
      promise.resolve payload
    | none => return

def PendingResponses.executeError (pr : PendingResponses) (id : RequestId) (error : String) : IO Unit := do
  pr.mutex.withLock do
    let m ← pr.ref.get
    match m.get? id with
    | some promise =>
      pr.ref.modify fun m => m.erase id
      -- Resolve with an error marker JSON object
      promise.resolve (Json.mkObj [("error", Json.str error)])
    | none => return
