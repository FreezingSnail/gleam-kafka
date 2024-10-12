import gleam/io

import gleam/bytes_builder
import gleam/erlang/process
import gleam/option.{None}
import gleam/otp/actor
import glisten

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
      let response = request_handler(req)
      let assert Ok(_) = glisten.send(conn, response)
      actor.continue(state)
    })
    |> glisten.serve(9092)

  process.sleep_forever()
}

fn request_handler(request: BitArray) -> bytes_builder.BytesBuilder {
  let correlation_id = parse_request_header(request)
  bytes_builder.new()
  |> bytes_builder.append(<<0:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
}

fn parse_request_header(request: BitArray) -> Int {
  let assert <<
    _req_len:size(32),
    _req_api_key:size(16),
    _req_api_version:size(16),
    correlation_id:size(32),
    _rest:bits,
  >> = request

  correlation_id
}
