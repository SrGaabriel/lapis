import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Transport.Base
import Lapis.Server.Receiver
import Std.Data.HashMap

namespace Lapis.Server.Registration

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Transport
open Lapis.Server.Receiver
open Std (HashMap)

/-- A unique registration ID -/
abbrev RegistrationId := String

/-- A registration for a capability -/
structure Registration where
  id : RegistrationId
  method : String
  registerOptions : Option Json := none
  deriving Inhabited

instance : ToJson Registration where
  toJson r := Json.mkObj <|
    [("id", Json.str r.id), ("method", Json.str r.method)] ++
    (match r.registerOptions with | some o => [("registerOptions", o)] | none => [])

instance : FromJson Registration where
  fromJson? json := do
    let id ← json.getObjValAs? String "id"
    let method ← json.getObjValAs? String "method"
    let registerOptions := json.getObjVal? "registerOptions" |>.toOption
    return { id, method, registerOptions }

/-- Unregistration for a capability -/
structure Unregistration where
  id : RegistrationId
  method : String
  deriving Inhabited

instance : ToJson Unregistration where
  toJson u := Json.mkObj [("id", Json.str u.id), ("method", Json.str u.method)]

/-- Parameters for client/registerCapability -/
structure RegistrationParams where
  registrations : Array Registration
  deriving Inhabited

instance : ToJson RegistrationParams where
  toJson p := Json.mkObj [("registrations", toJson p.registrations)]

/-- Parameters for client/unregisterCapability -/
structure UnregistrationParams where
  unregistrations : Array Unregistration
  deriving Inhabited

instance : ToJson UnregistrationParams where
  toJson p := Json.mkObj [("unregisterations", toJson p.unregistrations)]  -- Note: LSP spec has typo

/-- Kind of file events to watch -/
inductive WatchKind where
  | create
  | change
  | delete
  deriving Inhabited, BEq

def WatchKind.toNat : WatchKind → Nat
  | .create => 1
  | .change => 2
  | .delete => 4

/-- File system watcher pattern -/
structure FileSystemWatcher where
  globPattern : String
  kind : Option Nat := none  -- Bitmask of WatchKind
  deriving Inhabited

instance : ToJson FileSystemWatcher where
  toJson w := Json.mkObj <|
    [("globPattern", Json.str w.globPattern)] ++
    (match w.kind with | some k => [("kind", toJson k)] | none => [])

/-- Options for registering file watchers -/
structure DidChangeWatchedFilesRegistrationOptions where
  watchers : Array FileSystemWatcher
  deriving Inhabited

instance : ToJson DidChangeWatchedFilesRegistrationOptions where
  toJson o := Json.mkObj [("watchers", toJson o.watchers)]

/-- Document filter for registration -/
structure DocumentFilter where
  language : Option String := none
  scheme : Option String := none
  pattern : Option String := none
  deriving Inhabited

instance : ToJson DocumentFilter where
  toJson f := Json.mkObj <|
    (match f.language with | some l => [("language", Json.str l)] | none => []) ++
    (match f.scheme with | some s => [("scheme", Json.str s)] | none => []) ++
    (match f.pattern with | some p => [("pattern", Json.str p)] | none => [])

/-- Document selector is an array of filters -/
abbrev DocumentSelector := Array DocumentFilter

/-- Text document registration options -/
structure TextDocumentRegistrationOptions where
  documentSelector : DocumentSelector
  deriving Inhabited

instance : ToJson TextDocumentRegistrationOptions where
  toJson o := Json.mkObj [("documentSelector", toJson o.documentSelector)]

/-- Tracks active capability registrations -/
structure RegistrationState where
  /-- Method to list of registration IDs -/
  registrations : HashMap String (Array RegistrationId)
  /-- All registrations by ID -/
  byId : HashMap RegistrationId Registration

/-- Manages dynamic capability registration -/
structure RegistrationManager where
  /-- Current registration state -/
  state : IO.Ref RegistrationState
  /-- Counter for generating unique IDs -/
  idCounter : IO.Ref Nat
  /-- Output channel for sending requests -/
  outputChannel : OutputChannel
  /-- Pending responses -/
  pendingResponses : PendingResponses
  /-- Mutex for state modifications -/
  mutex : AsyncMutex

namespace RegistrationManager

/-- Create a new registration manager -/
def new (outputChannel : OutputChannel) (pendingResponses : PendingResponses) : IO RegistrationManager := do
  let state ← IO.mkRef { registrations := {}, byId := {} : RegistrationState }
  let idCounter ← IO.mkRef 0
  let mutex ← AsyncMutex.new
  return { state, idCounter, outputChannel, pendingResponses, mutex }

/-- Generate a unique registration ID -/
def generateId (rm : RegistrationManager) (pfx : String := "reg") : IO RegistrationId := do
  rm.mutex.withLock do
    let n ← rm.idCounter.get
    rm.idCounter.set (n + 1)
    return s!"{pfx}-{n}"

/-- Send a registration request to the client -/
private def sendRegister (rm : RegistrationManager) (registrations : Array Registration) : IO Bool := do
  if registrations.isEmpty then return true

  let params : RegistrationParams := { registrations }

  let promise ← IO.Promise.new
  let requestId ← rm.pendingResponses.register promise
  let _ ← rm.outputChannel.sendRequest requestId "client/registerCapability" (toJson params)

  let some result := promise.result?.get
    | return false

  -- null means success
  match result with
  | Json.null => return true
  | _ =>
    match result.getObjVal? "code" with
    | .ok _ => return false
    | .error _ => return true

/-- Send an unregistration request to the client -/
private def sendUnregister (rm : RegistrationManager) (unregistrations : Array Unregistration) : IO Bool := do
  if unregistrations.isEmpty then return true

  let params : UnregistrationParams := { unregistrations }

  let promise ← IO.Promise.new
  let requestId ← rm.pendingResponses.register promise
  let _ ← rm.outputChannel.sendRequest requestId "client/unregisterCapability" (toJson params)

  let some result := promise.result?.get
    | return false

  match result with
  | Json.null => return true
  | _ =>
    match result.getObjVal? "code" with
    | .ok _ => return false
    | .error _ => return true

/-- Register a capability -/
def register (rm : RegistrationManager) (method : String)
    (options : Option Json := none) : IO (Option RegistrationId) := do
  let id ← rm.generateId method

  let reg : Registration := { id, method, registerOptions := options }

  let success ← rm.sendRegister #[reg]
  if !success then return none

  rm.mutex.withLock do
    rm.state.modify fun s =>
      let existing := s.registrations.getD method #[]
      { registrations := s.registrations.insert method (existing.push id)
        byId := s.byId.insert id reg }

  return some id

/-- Unregister a capability by ID -/
def unregister (rm : RegistrationManager) (id : RegistrationId) : IO Bool := do
  let s ← rm.state.get
  let some reg := s.byId.get? id
    | return false

  let unreg : Unregistration := { id, method := reg.method }
  let success ← rm.sendUnregister #[unreg]
  if !success then return false

  rm.mutex.withLock do
    rm.state.modify fun s =>
      let existing := s.registrations.getD reg.method #[]
      let filtered := existing.filter (· != id)
      { registrations := s.registrations.insert reg.method filtered
        byId := s.byId.erase id }

  return true

/-- Unregister all capabilities for a method -/
def unregisterAll (rm : RegistrationManager) (method : String) : IO Bool := do
  let s ← rm.state.get
  let ids := s.registrations.getD method #[]
  if ids.isEmpty then return true

  let unregs := ids.map fun id => { id, method : Unregistration }
  let success ← rm.sendUnregister unregs
  if !success then return false

  rm.mutex.withLock do
    rm.state.modify fun s =>
      let byId := ids.foldl (fun m id => m.erase id) s.byId
      { registrations := s.registrations.erase method
        byId := byId }

  return true

/-- Check if a method has any active registrations -/
def isRegistered (rm : RegistrationManager) (method : String) : IO Bool := do
  let s ← rm.state.get
  let ids := s.registrations.getD method #[]
  return ids.size > 0

/-- Get all registration IDs for a method -/
def getRegistrations (rm : RegistrationManager) (method : String) : IO (Array RegistrationId) := do
  let s ← rm.state.get
  return s.registrations.getD method #[]

/-- Register file watchers -/
def registerFileWatchers (rm : RegistrationManager) (patterns : Array String)
    (watchKinds : Option Nat := none) : IO (Option RegistrationId) := do
  let watchers := patterns.map fun p => { globPattern := p, kind := watchKinds : FileSystemWatcher }
  let options : DidChangeWatchedFilesRegistrationOptions := { watchers }
  rm.register "workspace/didChangeWatchedFiles" (some (toJson options))

/-- Register a single file watcher -/
def registerFileWatcher (rm : RegistrationManager) (pattern : String)
    (watchKinds : Option Nat := none) : IO (Option RegistrationId) :=
  rm.registerFileWatchers #[pattern] watchKinds

/-- Create a watch kind bitmask -/
def mkWatchKind (create change delete : Bool) : Nat :=
  (if create then WatchKind.create.toNat else 0) +
  (if change then WatchKind.change.toNat else 0) +
  (if delete then WatchKind.delete.toNat else 0)

/-- Register a text document capability for specific languages -/
def registerForLanguages (rm : RegistrationManager) (method : String)
    (languages : Array String) (additionalOptions : Option Json := none) : IO (Option RegistrationId) := do
  let filters := languages.map fun lang => { language := some lang : DocumentFilter }
  let docOptions : TextDocumentRegistrationOptions := { documentSelector := filters }

  -- Merge with additional options if provided
  let options := match additionalOptions with
    | none => toJson docOptions
    | some addl =>
      match toJson docOptions, addl with
      | .obj m1, .obj m2 =>
        let merged := m2.toList.foldl (fun acc (k, v) => acc.insert k v) m1
        .obj merged
      | _, _ => toJson docOptions

  rm.register method (some options)

/-- Register a text document capability for a file scheme -/
def registerForScheme (rm : RegistrationManager) (method : String)
    (scheme : String) : IO (Option RegistrationId) := do
  let filter : DocumentFilter := { scheme := some scheme }
  let options : TextDocumentRegistrationOptions := { documentSelector := #[filter] }
  rm.register method (some (toJson options))

end RegistrationManager

end Lapis.Server.Registration
