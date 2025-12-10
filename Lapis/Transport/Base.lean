import Lapis.Protocol.JsonRpc

namespace Lapis.Transport

open Lapis.Protocol.JsonRpc

class Transport (T : Type) where
  readMessage : T → IO (Option Message)
  writeMessage : T → Message → IO Unit
  close : T → IO Unit

partial def messageLoop [Transport T] (transport : T) (handler : Message → IO (Option Message)) : IO Unit := do
  match ← Transport.readMessage transport with
  | none => return () -- EOF
  | some msg =>
    if let some response ← handler msg then
      Transport.writeMessage transport response
    messageLoop transport handler

end Lapis.Transport
