import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Server.Monad
import Lean.Data.Json

namespace Lapis.Server.Builder

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Server.Monad

/-- Result of handling a request -/
inductive HandlerResult where
  | ok (result : Json)
  | error (code : Int) (message : String)
  deriving Inhabited

/-- A request handler -/
def RequestHandler (UserState : Type) := Json → ServerM UserState HandlerResult

/-- A notification handler -/
def NotificationHandler (UserState : Type) := Json → ServerM UserState Unit

/-- Server configuration -/
structure ServerConfig (UserState : Type) where
  /-- Server name -/
  name : String
  /-- Server version -/
  version : Option String := none
  /-- Server capabilities -/
  capabilities : ServerCapabilities := {}
  /-- Initial user state -/
  initialState : UserState
  /-- Request handlers by method name -/
  requestHandlers : List (String × RequestHandler UserState) := []
  /-- Notification handlers by method name -/
  notificationHandlers : List (String × NotificationHandler UserState) := []
  deriving Inhabited

/-- Create a new server config -/
def ServerConfig.new (name : String) (initialState : UserState) : ServerConfig UserState :=
  { name, initialState }

/-- Set server version -/
def ServerConfig.withVersion (config : ServerConfig UserState) (version : String) : ServerConfig UserState :=
  { config with version := some version }

/-- Set capabilities -/
def ServerConfig.withCapabilities (config : ServerConfig UserState) (caps : ServerCapabilities) : ServerConfig UserState :=
  { config with capabilities := caps }

/-- Add a request handler with typed params and result -/
def ServerConfig.onRequest [FromJson Params] [ToJson Result]
    (config : ServerConfig UserState)
    (method : String)
    (handler : Params → ServerM UserState Result) : ServerConfig UserState :=
  let wrappedHandler : RequestHandler UserState := fun json => do
    match FromJson.fromJson? json with
    | .error e => return .error invalidParams s!"Invalid params: {e}"
    | .ok params =>
      let result ← handler params
      return .ok (toJson result)
  { config with requestHandlers := (method, wrappedHandler) :: config.requestHandlers }

/-- Add a request handler that can return null -/
def ServerConfig.onRequestOpt [FromJson Params] [ToJson Result]
    (config : ServerConfig UserState)
    (method : String)
    (handler : Params → ServerM UserState (Option Result)) : ServerConfig UserState :=
  let wrappedHandler : RequestHandler UserState := fun json => do
    match FromJson.fromJson? json with
    | .error e => return .error invalidParams s!"Invalid params: {e}"
    | .ok params =>
      match ← handler params with
      | none => return .ok Json.null
      | some result => return .ok (toJson result)
  { config with requestHandlers := (method, wrappedHandler) :: config.requestHandlers }

/-- Add a notification handler with typed params -/
def ServerConfig.onNotification [FromJson Params]
    (config : ServerConfig UserState)
    (method : String)
    (handler : Params → ServerM UserState Unit) : ServerConfig UserState :=
  let wrappedHandler : NotificationHandler UserState := fun json => do
    match FromJson.fromJson? json with
    | .error _ => pure ()  -- Ignore invalid notifications
    | .ok params => handler params
  { config with notificationHandlers := (method, wrappedHandler) :: config.notificationHandlers }

/-- Find a request handler -/
def ServerConfig.findRequestHandler (config : ServerConfig UserState) (method : String) : Option (RequestHandler UserState) :=
  config.requestHandlers.find? (·.1 == method) |>.map (·.2)

/-- Find a notification handler -/
def ServerConfig.findNotificationHandler (config : ServerConfig UserState) (method : String) : Option (NotificationHandler UserState) :=
  config.notificationHandlers.find? (·.1 == method) |>.map (·.2)

end Lapis.Server.Builder
