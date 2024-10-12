import gleam/erlang/process
import gleam/io
import gleam/option.{None}
import gleam/otp/actor
import glisten
import handlers/handler

pub fn main() {
  // Ensures gleam doesn't complain about unused imports in stage 1 (feel free to remove this!)
  let _ = glisten.handler
  let _ = glisten.serve
  let _ = process.sleep_forever
  let _ = actor.continue
  let _ = None

  // You can use print statements as follows for debugging, they'll be visible when running tests.
  io.println("Logs from your program will appear here!")

  let assert Ok(_) =
    glisten.handler(fn(_conn) { #(Nil, None) }, fn(msg, state, conn) {
      io.println("Received message!")
      let assert glisten.Packet(req) = msg
      let response = handler.request_handler(req)
      io.println("Sending response")
      let res = glisten.send(conn, response)
      case res {
        Ok(_) -> Nil
        Error(err) -> {
          io.debug(err)
          Nil
        }
      }
      actor.continue(state)
    })
    |> glisten.serve(9092)

  process.sleep_forever()
}
