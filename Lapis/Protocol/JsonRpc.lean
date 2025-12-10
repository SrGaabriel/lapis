/-
  JSON-RPC 2.0 Protocol Implementation
  https://www.jsonrpc.org/specification
-/
import Lean.Data.Json

namespace Lapis.Protocol.JsonRpc

open Lean Json

inductive RequestId where
  | num (n : Int)
  | str (s : String)
  deriving Inhabited, BEq, Hashable

instance : Repr RequestId where
  reprPrec
    | .num n, _ => repr n
    | .str s, _ => repr s

instance : ToJson RequestId where
  toJson
    | .num n => toJson n
    | .str s => toJson s

instance : FromJson RequestId where
  fromJson? json :=
    (RequestId.num <$> fromJson? json) <|>
    (RequestId.str <$> fromJson? json)

instance : ToString RequestId where
  toString
    | .num n => toString n
    | .str s => s

/-- JSON-RPC 2.0 error codes -/
def parseError : Int := -32700
def invalidRequest : Int := -32600
def methodNotFound : Int := -32601
def invalidParams : Int := -32602
def internalError : Int := -32603

-- LSP-specific error codes
def serverNotInitialized : Int := -32002
def unknownErrorCode : Int := -32001
def requestCancelled : Int := -32800
def contentModified : Int := -32801

structure ResponseError where
  code : Int
  message : String
  data : Option Json := none
  deriving Inhabited

instance : Repr ResponseError where
  reprPrec e _ := s!"ResponseError(\{code := {e.code}, message := {repr e.message}})"

instance : ToJson ResponseError where
  toJson e := Json.mkObj <|
    [("code", toJson e.code), ("message", toJson e.message)] ++
    (match e.data with | some d => [("data", d)] | none => [])

instance : FromJson ResponseError where
  fromJson? json := do
    let code ← json.getObjValAs? Int "code"
    let message ← json.getObjValAs? String "message"
    let data := json.getObjVal? "data" |>.toOption
    return { code, message, data }

/-- A JSON-RPC 2.0 request message -/
structure RequestMessage where
  id : RequestId
  method : String
  params : Option Json := none
  deriving Inhabited

instance : Repr RequestMessage where
  reprPrec r _ := s!"RequestMessage(\{id := {repr r.id}, method := {repr r.method}})"

instance : ToJson RequestMessage where
  toJson r := Json.mkObj <|
    [("jsonrpc", toJson "2.0"), ("id", toJson r.id), ("method", toJson r.method)] ++
    (match r.params with | some p => [("params", p)] | none => [])

instance : FromJson RequestMessage where
  fromJson? json := do
    let _ ← json.getObjValAs? String "jsonrpc"
    let id ← json.getObjValAs? RequestId "id"
    let method ← json.getObjValAs? String "method"
    let params := json.getObjVal? "params" |>.toOption
    return { id, method, params }

/-- A JSON-RPC 2.0 notification message (no id, no response expected) -/
structure NotificationMessage where
  method : String
  params : Option Json := none
  deriving Inhabited

instance : Repr NotificationMessage where
  reprPrec n _ := s!"NotificationMessage(\{method := {repr n.method}})"

instance : ToJson NotificationMessage where
  toJson n := Json.mkObj <|
    [("jsonrpc", toJson "2.0"), ("method", toJson n.method)] ++
    (match n.params with | some p => [("params", p)] | none => [])

instance : FromJson NotificationMessage where
  fromJson? json := do
    let _ ← json.getObjValAs? String "jsonrpc"
    let method ← json.getObjValAs? String "method"
    let params := json.getObjVal? "params" |>.toOption
    return { method, params }

/-- A JSON-RPC 2.0 successful response -/
structure ResponseMessage where
  id : RequestId
  result : Json
  deriving Inhabited

instance : Repr ResponseMessage where
  reprPrec r _ := s!"ResponseMessage(\{id := {repr r.id}})"

instance : ToJson ResponseMessage where
  toJson r := Json.mkObj
    [("jsonrpc", toJson "2.0"), ("id", toJson r.id), ("result", r.result)]

instance : FromJson ResponseMessage where
  fromJson? json := do
    let _ ← json.getObjValAs? String "jsonrpc"
    let id ← json.getObjValAs? RequestId "id"
    let result ← json.getObjVal? "result"
    return { id, result }

/-- A JSON-RPC 2.0 error response -/
structure ErrorResponseMessage where
  id : Option RequestId  -- Can be null if we couldn't parse the request id
  error : ResponseError
  deriving Inhabited

instance : Repr ErrorResponseMessage where
  reprPrec r _ := s!"ErrorResponseMessage(\{id := {repr r.id}, error := {repr r.error}})"

instance : ToJson ErrorResponseMessage where
  toJson r := Json.mkObj
    [("jsonrpc", toJson "2.0"),
     ("id", match r.id with | some id => toJson id | none => Json.null),
     ("error", toJson r.error)]

instance : FromJson ErrorResponseMessage where
  fromJson? json := do
    let _ ← json.getObjValAs? String "jsonrpc"
    let idJson := json.getObjVal? "id" |>.toOption
    let id ← match idJson with
      | some j => if j.isNull then pure none else some <$> fromJson? j
      | none => pure none
    let error ← json.getObjValAs? ResponseError "error"
    return { id, error }

inductive Message where
  | request (msg : RequestMessage)
  | notification (msg : NotificationMessage)
  | response (msg : ResponseMessage)
  | errorResponse (msg : ErrorResponseMessage)
  deriving Inhabited, Repr

def Message.fromJson? (json : Json) : Except String Message := do
  let hasId := json.getObjVal? "id" |>.toOption |>.isSome
  let idIsNull := json.getObjVal? "id" |>.toOption |>.map (·.isNull) |>.getD false

  let hasResult := json.getObjVal? "result" |>.toOption |>.isSome
  let hasError := json.getObjVal? "error" |>.toOption |>.isSome

  if hasError then
    .errorResponse <$> FromJson.fromJson? json
  else if hasResult then
    .response <$> FromJson.fromJson? json
  else if hasId && !idIsNull then
    .request <$> FromJson.fromJson? json
  else
    .notification <$> FromJson.fromJson? json

instance : FromJson Message where
  fromJson? := Message.fromJson?

def Message.toJson : Message → Json
  | .request msg => Lean.toJson msg
  | .notification msg => Lean.toJson msg
  | .response msg => Lean.toJson msg
  | .errorResponse msg => Lean.toJson msg

instance : ToJson Message where
  toJson := Message.toJson

def mkResponse (id : RequestId) (result : Json) : Message :=
  .response { id, result }

def mkErrorResponse (id : Option RequestId) (code : Int) (message : String) (data : Option Json := none) : Message :=
  .errorResponse { id, error := { code, message, data } }

def mkParseError (message : String) : Message :=
  mkErrorResponse none parseError message

def mkInvalidRequest (id : Option RequestId) (message : String) : Message :=
  mkErrorResponse id invalidRequest message

def mkMethodNotFound (id : RequestId) (method : String) : Message :=
  mkErrorResponse (some id) methodNotFound s!"Method not found: {method}"

def mkInvalidParams (id : RequestId) (message : String) : Message :=
  mkErrorResponse (some id) invalidParams message

def mkInternalError (id : Option RequestId) (message : String) : Message :=
  mkErrorResponse id internalError message

end Lapis.Protocol.JsonRpc
