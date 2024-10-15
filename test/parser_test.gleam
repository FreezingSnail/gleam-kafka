import domain/parser
import gleam/bit_array
import gleam/io
import gleeunit/should

pub fn test_clientid_parse_test() {
  let client_name = "test"
  let client_name_bytes = bit_array.from_string(client_name)
  let client_name_len = bit_array.byte_size(client_name_bytes) + 1
  let message = <<client_name_len:size(16), client_name_bytes:bits, 0:size(8)>>

  let #(parsed, _rest) = parser.parse_client_id(message)
  should.equal(parsed, client_name)
}

pub fn var_int_parse_test() {
  let val = 0b1001011000000001
  let #(l, _rest) = parser.parse_var_int(<<val:big-size(16)>>)
  io.debug(l)
  should.equal(l, 150)
}
