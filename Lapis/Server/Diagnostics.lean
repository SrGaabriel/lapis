import Lapis.Protocol.JsonRpc
import Lapis.Protocol.Types
import Lapis.Protocol.Messages
import Lapis.Transport.Base
import Std.Data.HashMap

namespace Lapis.Server.Diagnostics

open Lean Json
open Lapis.Protocol.JsonRpc
open Lapis.Protocol.Types
open Lapis.Protocol.Messages
open Lapis.Transport
open Std (HashMap)

/-! ## Diagnostic Job -/

/-- State of a pending diagnostic job -/
structure DiagnosticJob where
  /-- Document URI -/
  uri : DocumentUri
  /-- Document version when job was scheduled -/
  version : Int
  /-- Cancellation flag -/
  cancelled : IO.Ref Bool
  /-- Task running the diagnostic computation -/
  task : Task (Except IO.Error Unit)

/-- Configuration for debounced diagnostics -/
structure DiagnosticsConfig where
  /-- Delay in milliseconds before running diagnostics -/
  debounceMs : Nat := 300
  /-- Source name for diagnostics -/
  source : Option String := none
  deriving Inhabited

/-- Manages debounced diagnostic publishing -/
structure DiagnosticsManager where
  /-- Pending diagnostic jobs per URI -/
  pendingJobs : IO.Ref (HashMap String DiagnosticJob)
  /-- Configuration -/
  config : DiagnosticsConfig
  /-- Output channel for publishing -/
  outputChannel : OutputChannel
  /-- Mutex for state modifications -/
  mutex : AsyncMutex

namespace DiagnosticsManager

/-- Create a new diagnostics manager -/
def new (outputChannel : OutputChannel) (config : DiagnosticsConfig := {}) : IO DiagnosticsManager := do
  let pendingJobs ← IO.mkRef (HashMap.emptyWithCapacity 32)
  let mutex ← AsyncMutex.new
  return { pendingJobs, config, outputChannel, mutex }

/-- Publish diagnostics for a document -/
private def publish (dm : DiagnosticsManager) (uri : DocumentUri)
    (version : Option Int) (diagnostics : Array Diagnostic) : IO Unit := do
  let params : PublishDiagnosticsParams := { uri, version, diagnostics }
  let notif : NotificationMessage := {
    method := "textDocument/publishDiagnostics"
    params := some (toJson params)
  }
  dm.outputChannel.send (.notification notif)

/-- Cancel any pending diagnostic job for a URI -/
def cancel (dm : DiagnosticsManager) (uri : DocumentUri) : IO Unit := do
  dm.mutex.withLock do
    let jobs ← dm.pendingJobs.get
    if let some job := jobs.get? uri then
      job.cancelled.set true
      dm.pendingJobs.modify fun m => m.erase uri

/-- Clear diagnostics for a document -/
def clear (dm : DiagnosticsManager) (uri : DocumentUri) : IO Unit := do
  dm.cancel uri
  dm.publish uri none #[]

/-- Schedule diagnostics with debouncing -/
def schedule (dm : DiagnosticsManager) (uri : DocumentUri) (version : Int)
    (compute : IO (Array Diagnostic)) : IO Unit := do
  -- Cancel any existing job for this URI
  dm.cancel uri

  let cancelled ← IO.mkRef false

  let task ← IO.asTask (prio := .default) do
    -- Wait for debounce period
    IO.sleep dm.config.debounceMs.toUInt32

    -- Check if cancelled during debounce
    if ← cancelled.get then
      return

    -- Run the diagnostic computation
    let diagnostics ← compute

    -- Check if cancelled during computation
    if ← cancelled.get then
      return

    -- Apply source to all diagnostics if configured
    let diagnostics := match dm.config.source with
      | some src => diagnostics.map fun d => { d with source := some src }
      | none => diagnostics

    -- Publish the diagnostics
    dm.publish uri (some version) diagnostics

  let job : DiagnosticJob := { uri, version, cancelled, task }

  dm.mutex.withLock do
    dm.pendingJobs.modify fun m => m.insert uri job

/-- Schedule diagnostics with a pure computation -/
def schedulePure (dm : DiagnosticsManager) (uri : DocumentUri) (version : Int)
    (diagnostics : Array Diagnostic) : IO Unit :=
  dm.schedule uri version (pure diagnostics)

/-- Trigger immediate diagnostics (no debounce) -/
def triggerImmediate (dm : DiagnosticsManager) (uri : DocumentUri) (version : Int)
    (compute : IO (Array Diagnostic)) : IO Unit := do
  -- Cancel any pending job
  dm.cancel uri

  -- Run immediately
  let diagnostics ← compute

  let diagnostics := match dm.config.source with
    | some src => diagnostics.map fun d => { d with source := some src }
    | none => diagnostics

  dm.publish uri (some version) diagnostics

/-- Wait for all pending diagnostic jobs to complete -/
def flush (dm : DiagnosticsManager) : IO Unit := do
  let jobs ← dm.pendingJobs.get
  for (_, job) in jobs.toList do
    let _ ← IO.wait job.task

/-- Cancel all pending diagnostic jobs -/
def cancelAll (dm : DiagnosticsManager) : IO Unit := do
  dm.mutex.withLock do
    let jobs ← dm.pendingJobs.get
    for (_, job) in jobs.toList do
      job.cancelled.set true
    dm.pendingJobs.set {}

end DiagnosticsManager

/-- Builder for creating diagnostics -/
structure DiagnosticBuilder where
  diagnostics : Array Diagnostic
  source : Option String

namespace DiagnosticBuilder

/-- Create a new diagnostic builder -/
def new (source : Option String := none) : DiagnosticBuilder :=
  { diagnostics := #[], source }

/-- Add an error diagnostic -/
def error (b : DiagnosticBuilder) (range : Range) (message : String)
    (code : Option String := none) : DiagnosticBuilder :=
  let diag : Diagnostic := {
    range, message, code
    severity := some .error
    source := b.source
  }
  { b with diagnostics := b.diagnostics.push diag }

/-- Add a warning diagnostic -/
def warning (b : DiagnosticBuilder) (range : Range) (message : String)
    (code : Option String := none) : DiagnosticBuilder :=
  let diag : Diagnostic := {
    range, message, code
    severity := some .warning
    source := b.source
  }
  { b with diagnostics := b.diagnostics.push diag }

/-- Add an info diagnostic -/
def info (b : DiagnosticBuilder) (range : Range) (message : String)
    (code : Option String := none) : DiagnosticBuilder :=
  let diag : Diagnostic := {
    range, message, code
    severity := some .information
    source := b.source
  }
  { b with diagnostics := b.diagnostics.push diag }

/-- Add a hint diagnostic -/
def hint (b : DiagnosticBuilder) (range : Range) (message : String)
    (code : Option String := none) : DiagnosticBuilder :=
  let diag : Diagnostic := {
    range, message, code
    severity := some .hint
    source := b.source
  }
  { b with diagnostics := b.diagnostics.push diag }

/-- Add a diagnostic with tags -/
def withTags (b : DiagnosticBuilder) (range : Range) (message : String)
    (severity : DiagnosticSeverity) (tags : Array DiagnosticTag)
    (code : Option String := none) : DiagnosticBuilder :=
  let diag : Diagnostic := {
    range, message, code
    severity := some severity
    source := b.source
    tags := some tags
  }
  { b with diagnostics := b.diagnostics.push diag }

/-- Mark code as deprecated -/
def deprecated (b : DiagnosticBuilder) (range : Range) (message : String) : DiagnosticBuilder :=
  b.withTags range message .hint #[.deprecated]

/-- Mark code as unnecessary -/
def unnecessary (b : DiagnosticBuilder) (range : Range) (message : String) : DiagnosticBuilder :=
  b.withTags range message .hint #[.unnecessary]

/-- Add a custom diagnostic -/
def add (b : DiagnosticBuilder) (diag : Diagnostic) : DiagnosticBuilder :=
  let diag := match diag.source, b.source with
    | none, some src => { diag with source := some src }
    | _, _ => diag
  { b with diagnostics := b.diagnostics.push diag }

/-- Build the final diagnostic array -/
def build (b : DiagnosticBuilder) : Array Diagnostic :=
  b.diagnostics

end DiagnosticBuilder

/-- Create a single error diagnostic -/
def mkError (range : Range) (message : String) (source : Option String := none) : Diagnostic :=
  { range, message, severity := some .error, source }

/-- Create a single warning diagnostic -/
def mkWarning (range : Range) (message : String) (source : Option String := none) : Diagnostic :=
  { range, message, severity := some .warning, source }

/-- Create a single info diagnostic -/
def mkInfo (range : Range) (message : String) (source : Option String := none) : Diagnostic :=
  { range, message, severity := some .information, source }

/-- Create a single hint diagnostic -/
def mkHint (range : Range) (message : String) (source : Option String := none) : Diagnostic :=
  { range, message, severity := some .hint, source }

end Lapis.Server.Diagnostics
