/- stdin/stdout transport for LSP -/
import Lapis.Transport.Base

namespace Lapis.Transport.Stdio

open Lapis.Protocol.JsonRpc
open Lean Json

structure StdioTransport where
  stdin : IO.FS.Stream
  stdout : IO.FS.Stream

def create : IO StdioTransport := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  return { stdin, stdout }

private def readByte (stream : IO.FS.Stream) : IO (Option UInt8) := do
  let buf ← stream.read 1
  if buf.size == 0 then
    return none
  else
    return some buf[0]!

private def readUntil (stream : IO.FS.Stream) (delim : ByteArray) : IO (Option ByteArray) := do
  let mut result : ByteArray := ByteArray.empty
  let mut matchIdx := 0

  while true do
    match ← readByte stream with
    | none => return none  -- EOF
    | some b =>
      result := result.push b

      if b == delim[matchIdx]! then
        matchIdx := matchIdx + 1
        if matchIdx == delim.size then
          let endIdx := result.size - delim.size
          return some (result.extract 0 endIdx)
      else
        matchIdx := 0

  return none

private def parseHeaders (headerBlock : String) : Except String (List (String × String)) := do
  let lines := headerBlock.splitOn "\r\n"
  let mut headers := []
  for line in lines do
    if line.isEmpty then continue
    match line.splitOn ": " with
    | [key, value] => headers := (key.toLower, value) :: headers
    | _ => throw s!"Invalid header line: {line}"
  return headers

def readMessage (t : StdioTransport) : IO (Option Message) := do
  let headerDelim := "\r\n\r\n".toUTF8
  let some headerBytes ← readUntil t.stdin headerDelim
    | return none

  let headerStr := String.fromUTF8! headerBytes
  let headers ← IO.ofExcept (parseHeaders headerStr)

  let some (_, lengthStr) := headers.find? (·.1 == "content-length")
    | throw (IO.userError "Missing Content-Length header")

  let some contentLength := lengthStr.toNat?
    | throw (IO.userError s!"Invalid Content-Length: {lengthStr}")

  let content ← t.stdin.read contentLength.toUSize
  if content.size != contentLength then
    throw (IO.userError s!"Unexpected EOF: expected {contentLength} bytes, got {content.size}")

  let contentStr := String.fromUTF8! content

  let json ← IO.ofExcept (Json.parse contentStr)
  let msg ← IO.ofExcept (Message.fromJson? json)

  return some msg

def writeMessage (t : StdioTransport) (msg : Message) : IO Unit := do
  let json := toJson msg
  let content := json.compress
  let contentBytes := content.toUTF8

  let header := s!"Content-Length: {contentBytes.size}\r\n\r\n"

  t.stdout.write header.toUTF8
  t.stdout.write contentBytes
  t.stdout.flush

def close (_ : StdioTransport) : IO Unit := pure ()

instance : Transport StdioTransport where
  readMessage := readMessage
  writeMessage := writeMessage
  close := close

end Lapis.Transport.Stdio
