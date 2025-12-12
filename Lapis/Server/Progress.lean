import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Transport.Base
import Lapis.Server.Receiver
import Std.Data.HashMap

namespace Lapis.Server.Progress

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Transport
open Lapis.Server.Receiver
open Std (HashMap)

/-- A progress token can be a string or number -/
inductive ProgressToken where
  | string (s : String)
  | number (n : Int)
  deriving Inhabited, BEq, Hashable

instance : ToString ProgressToken where
  toString
    | .string s => s
    | .number n => toString n

instance : ToJson ProgressToken where
  toJson
    | .string s => toJson s
    | .number n => toJson n

instance : FromJson ProgressToken where
  fromJson? json :=
    (json.getStr?.map .string) <|>
    (json.getInt?.map .number)

structure WorkDoneProgressBegin where
  title : String
  cancellable : Option Bool := none
  message : Option String := none
  percentage : Option Nat := none
  deriving Inhabited

instance : ToJson WorkDoneProgressBegin where
  toJson p := Json.mkObj <|
    [("kind", Json.str "begin"), ("title", Json.str p.title)] ++
    (match p.cancellable with | some c => [("cancellable", toJson c)] | none => []) ++
    (match p.message with | some m => [("message", Json.str m)] | none => []) ++
    (match p.percentage with | some pct => [("percentage", toJson pct)] | none => [])

structure WorkDoneProgressReport where
  cancellable : Option Bool := none
  message : Option String := none
  percentage : Option Nat := none
  deriving Inhabited

instance : ToJson WorkDoneProgressReport where
  toJson p := Json.mkObj <|
    [("kind", Json.str "report")] ++
    (match p.cancellable with | some c => [("cancellable", toJson c)] | none => []) ++
    (match p.message with | some m => [("message", Json.str m)] | none => []) ++
    (match p.percentage with | some pct => [("percentage", toJson pct)] | none => [])

structure WorkDoneProgressEnd where
  message : Option String := none
  deriving Inhabited

instance : ToJson WorkDoneProgressEnd where
  toJson p := Json.mkObj <|
    [("kind", Json.str "end")] ++
    (match p.message with | some m => [("message", Json.str m)] | none => [])

/-- State of an active progress operation -/
structure ProgressState where
  token : ProgressToken
  title : String
  cancellable : Bool
  cancelled : IO.Ref Bool
  started : Bool

/-- Manages active progress tokens and their lifecycle -/
structure ProgressManager where
  /-- Active progress operations -/
  activeProgress : IO.Ref (HashMap String ProgressState)
  /-- Counter for generating unique tokens -/
  tokenCounter : IO.Ref Nat
  /-- Output channel for sending notifications -/
  outputChannel : OutputChannel
  /-- Pending responses for create requests -/
  pendingResponses : PendingResponses

namespace ProgressManager

/-- Create a new progress manager -/
def new (outputChannel : OutputChannel) (pendingResponses : PendingResponses) : IO ProgressManager := do
  let activeProgress ← IO.mkRef (HashMap.emptyWithCapacity 16)
  let tokenCounter ← IO.mkRef 0
  return { activeProgress, tokenCounter, outputChannel, pendingResponses }

/-- Generate a unique progress token -/
def generateToken (pm : ProgressManager) : IO ProgressToken := do
  -- Atomically get and increment counter
  let n ← pm.tokenCounter.modifyGet fun n => (n, n + 1)
  return .number (Int.ofNat n)

/-- Send a progress notification -/
private def sendProgress (pm : ProgressManager) (token : ProgressToken) (value : Json) : IO Unit := do
  let params := Json.mkObj [("token", toJson token), ("value", value)]
  let notif : NotificationMessage := { method := "$/progress", params := some params }
  pm.outputChannel.send (.notification notif)

/-- Request the client to create a progress token (for server-initiated progress) -/
def createToken (pm : ProgressManager) (token : ProgressToken) : IO Bool := do
  let params := Json.mkObj [("token", toJson token)]

  let promise ← IO.Promise.new
  let requestId ← pm.pendingResponses.register promise
  let _ ← pm.outputChannel.sendRequest requestId "window/workDoneProgress/create" params

  -- Wait for response
  let some result := promise.result?.get
    | return false

  -- Check if it's an error (null means success)
  match result with
  | Json.null => return true
  | _ =>
    -- Check for error object
    match result.getObjVal? "code" with
    | .ok _ => return false
    | .error _ => return true

/-- Begin a progress operation -/
def begin (pm : ProgressManager) (token : ProgressToken) (title : String)
    (cancellable : Bool := false) (message : Option String := none)
    (percentage : Option Nat := none) : IO Unit := do
  let cancelled ← IO.mkRef false
  let state : ProgressState := {
    token, title, cancellable, cancelled, started := true
  }

  pm.activeProgress.modify fun m => m.insert (toString token) state

  let beginValue : WorkDoneProgressBegin := {
    title
    cancellable := if cancellable then some true else none
    message
    percentage
  }
  pm.sendProgress token (toJson beginValue)

/-- Report progress update -/
def report (pm : ProgressManager) (token : ProgressToken)
    (message : Option String := none) (percentage : Option Nat := none)
    (cancellable : Option Bool := none) : IO Unit := do
  let reportValue : WorkDoneProgressReport := { message, percentage, cancellable }
  pm.sendProgress token (toJson reportValue)

/-- End a progress operation -/
def «end» (pm : ProgressManager) (token : ProgressToken)
    (message : Option String := none) : IO Unit := do
  pm.activeProgress.modify fun m => m.erase (toString token)

  let endValue : WorkDoneProgressEnd := { message }
  pm.sendProgress token (toJson endValue)

/-- Check if a progress operation was cancelled -/
def isCancelled (pm : ProgressManager) (token : ProgressToken) : IO Bool := do
  let active ← pm.activeProgress.get
  match active.get? (toString token) with
  | some state => state.cancelled.get
  | none => return true  -- Treat missing as cancelled

/-- Mark a progress operation as cancelled (called when client sends cancel) -/
def markCancelled (pm : ProgressManager) (token : ProgressToken) : IO Unit := do
  let active ← pm.activeProgress.get
  if let some state := active.get? (toString token) then
    state.cancelled.set true

/-- Run an action with progress reporting -/
def withProgress (pm : ProgressManager) (title : String)
    (cancellable : Bool := false)
    (action : ProgressToken → IO α) : IO α := do
  let token ← pm.generateToken

  -- Try to create token with client (optional, some clients don't support it)
  let _ ← pm.createToken token

  pm.begin token title cancellable
  try
    let result ← action token
    pm.end token (message := some "Done")
    return result
  catch e =>
    pm.end token (message := some s!"Failed: {e}")
    throw e

end ProgressManager

/-- A handle for reporting progress within an operation -/
structure ProgressHandle where
  manager : ProgressManager
  token : ProgressToken

namespace ProgressHandle

/-- Report progress -/
def report (h : ProgressHandle) (message : Option String := none)
    (percentage : Option Nat := none) : IO Unit :=
  h.manager.report h.token message percentage

/-- Check if cancelled -/
def isCancelled (h : ProgressHandle) : IO Bool :=
  h.manager.isCancelled h.token

/-- Throw if cancelled -/
def checkCancelled (h : ProgressHandle) : IO Unit := do
  if ← h.isCancelled then
    throw (IO.userError "Operation cancelled")

end ProgressHandle

end Lapis.Server.Progress
