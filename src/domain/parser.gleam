import gleam/bit_array
import request/errors.{type APIError}

pub type Cursor {
  Cursor(topic_name: String, partition_index: Int)
}

pub type DescribePartitionsRequest {
  DescribePartitionsRequest(
    topics: List(String),
    response_partition_limit: Int,
    cursor: Cursor,
  )
}

pub fn parse_describe_partitions(body: BitArray) {
  let assert <<length:size(16), _rest:bits>> = body
}

fn parse_topics(length, body: bits, acc: List(String)) {
  todo
}

pub fn parse_client_id(body: BitArray) -> #(String, BitArray) {
  let assert <<length:size(16), rest:bits>> = body
  let client_length = { length - 1 } * 8

  let assert <<
    client_id_bytes:size(client_length),
    0:size(8),
    remaining_body:bits,
  >> = <<rest:bits>>

  let assert Ok(client_id_string) =
    bit_array.to_string(<<client_id_bytes:size(client_length)>>)
  #(client_id_string, remaining_body)
}
