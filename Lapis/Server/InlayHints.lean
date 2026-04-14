import Lapis.Protocol.Generated

namespace Lapis.Server.InlayHints

open Lean Json

open Lapis.Protocol.Generated

/-- Build an inlay hint label from a plain string -/
def labelString (label : String) : Json := Json.str label

/-- Build an inlay hint label from label parts -/
def labelParts (parts : Array InlayHintLabelPart) : Json := toJson parts

/-- Builder for collecting inlay hints -/
structure InlayHintBuilder where
  hints : Array InlayHint := #[]
  deriving Inhabited

namespace InlayHintBuilder

/-- Create a new inlay hint builder -/
def new : InlayHintBuilder := { hints := #[] }

/-- Add an inlay hint with a raw JSON label -/
def push (b : InlayHintBuilder) (position : Position) (label : Json)
    (kind : Option InlayHintKind := none)
    (tooltip : Option String := none)
    (textEdits : Option (Array TextEdit) := none)
    (paddingLeft : Option Bool := none)
    (paddingRight : Option Bool := none)
    (data : Option Json := none) : InlayHintBuilder :=
  let tooltipJson := match tooltip with
    | some t => Json.str t
    | none => Json.null
  let dataJson := data.getD Json.null
  { b with hints := b.hints.push {
      position, label, kind, textEdits,
      tooltip := tooltipJson,
      paddingLeft, paddingRight,
      data := dataJson
    } }

/-- Add an inlay hint with a string label -/
def pushStringLabel (b : InlayHintBuilder) (position : Position) (label : String)
    (kind : Option InlayHintKind := none)
    (tooltip : Option String := none)
    (textEdits : Option (Array TextEdit) := none)
    (paddingLeft : Option Bool := none)
    (paddingRight : Option Bool := none)
    (data : Option Json := none) : InlayHintBuilder :=
  b.push position (labelString label) kind tooltip textEdits paddingLeft paddingRight data

/-- Add an inlay hint with label parts -/
def pushLabelParts (b : InlayHintBuilder) (position : Position) (parts : Array InlayHintLabelPart)
    (kind : Option InlayHintKind := none)
    (tooltip : Option String := none)
    (textEdits : Option (Array TextEdit) := none)
    (paddingLeft : Option Bool := none)
    (paddingRight : Option Bool := none)
    (data : Option Json := none) : InlayHintBuilder :=
  b.push position (labelParts parts) kind tooltip textEdits paddingLeft paddingRight data

/-- Build the inlay hint array -/
def build (b : InlayHintBuilder) : Array InlayHint :=
  b.hints

/-- Check if the builder has any hints -/
def isEmpty (b : InlayHintBuilder) : Bool :=
  b.hints.isEmpty

/-- Get the number of hints -/
def size (b : InlayHintBuilder) : Nat :=
  b.hints.size

end InlayHintBuilder

end Lapis.Server.InlayHints
