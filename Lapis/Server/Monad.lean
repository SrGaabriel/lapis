import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Protocol.Capabilities
import Lapis.Server.Documents

namespace Lapis.Server.Monad

open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Protocol.Capabilities
open Lapis.Server.Documents

/-- Server state -/
structure ServerState (UserState : Type) where
  /-- Whether the server has been initialized -/
  initialized : Bool := false
  /-- Whether shutdown has been requested -/
  shutdownRequested : Bool := false
  /-- Document store -/
  documents : DocumentStore := DocumentStore.empty
  /-- User-defined state -/
  userState : UserState
  deriving Inhabited

/-- Server context (immutable during request handling) -/
structure ServerContext where
  /-- Server capabilities -/
  capabilities : ServerCapabilities
  /-- Server info -/
  serverInfo : ServerInfo
  deriving Inhabited

/-- The server monad -/
abbrev ServerM (UserState : Type) := ReaderT ServerContext (StateT (ServerState UserState) IO)

/-- Run a ServerM action -/
def ServerM.run' (ctx : ServerContext) (state : ServerState UserState) (action : ServerM UserState α) : IO (α × ServerState UserState) :=
  (ReaderT.run action ctx) |> (StateT.run · state)

/-- Get the server context -/
def getContext : ServerM UserState ServerContext := read

/-- Get the full server state -/
def getServerState : ServerM UserState (ServerState UserState) := get

/-- Modify the server state -/
def modifyServerState (f : ServerState UserState → ServerState UserState) : ServerM UserState Unit := modify f

/-- Get user state -/
def getUserState : ServerM UserState UserState := do
  return (← get).userState

/-- Set user state -/
def setUserState (s : UserState) : ServerM UserState Unit :=
  modify fun st => { st with userState := s }

/-- Modify user state -/
def modifyUserState (f : UserState → UserState) : ServerM UserState Unit :=
  modify fun st => { st with userState := f st.userState }

/-- Check if initialized -/
def isInitialized : ServerM UserState Bool := do
  return (← get).initialized

/-- Mark as initialized -/
def setInitialized : ServerM UserState Unit :=
  modify fun st => { st with initialized := true }

/-- Check if shutdown was requested -/
def isShutdownRequested : ServerM UserState Bool := do
  return (← get).shutdownRequested

/-- Request shutdown -/
def requestShutdown : ServerM UserState Unit :=
  modify fun st => { st with shutdownRequested := true }

/-- Get a document by URI -/
def getDocument (uri : DocumentUri) : ServerM UserState (Option Document) := do
  return (← get).documents.get? uri

/-- Get all documents -/
def getDocuments : ServerM UserState DocumentStore := do
  return (← get).documents

/-- Open a document -/
def openDocument (params : DidOpenTextDocumentParams) : ServerM UserState Unit :=
  modify fun st => { st with documents := st.documents.open params }

/-- Close a document -/
def closeDocument (params : DidCloseTextDocumentParams) : ServerM UserState Unit :=
  modify fun st => { st with documents := st.documents.close params }

/-- Apply document changes -/
def changeDocument (params : DidChangeTextDocumentParams) : ServerM UserState Unit :=
  modify fun st => { st with documents := st.documents.change params }

/-- Lift IO into ServerM -/
instance : MonadLift IO (ServerM UserState) where
  monadLift := liftM

end Lapis.Server.Monad
