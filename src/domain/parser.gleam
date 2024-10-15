import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import request/errors.{type APIError}
import request/request

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

pub fn parse_request_header_v1(request: BitArray) -> request.RequestHeader {
  let assert <<
    req_len:size(32),
    req_api_key:size(16),
    req_api_version:size(16),
    correlation_id:size(32),
    _rest:bits,
  >> = request

  request.HeaderV1(req_len, req_api_key, req_api_version, correlation_id)
}

pub fn parse_request_header_v2(request: BitArray) -> request.RequestHeader {
  let assert <<
    req_len:size(32),
    req_api_key:size(16),
    req_api_version:size(16),
    correlation_id:size(32),
    rest:bits,
  >> = request

  let #(client_id, _rest) = parse_client_id(rest)

  request.HeaderV2(
    req_len,
    req_api_key,
    req_api_version,
    correlation_id,
    client_id,
  )
}

pub fn parse_describe_partitions(body: BitArray) -> DescribePartitionsRequest {
  let assert <<length:size(16), rest:bits>> = body

  let topics = parse_topics(length, rest)

  let assert <<response_partition_limit:size(32), rest:bits>> = <<rest:bits>>
  case rest {
    <<255:size(8), 0:size(8)>> -> 0
    _ -> 0
  }

  DescribePartitionsRequest(topics, response_partition_limit, Cursor("", 0))
}

fn parse_topics(length: Int, body: bits) -> List(String) {
  parse_topics_loop(length, body, [])
}

fn parse_topics_loop(length: Int, body: bits, acc: List(String)) -> List(String) {
  case length {
    0 -> []
    1 -> acc
    _ -> {
      parse_topics_loop({ length - 1 }, body, acc)
    }
  }
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

pub fn parse_var_int(body: BitArray) -> #(Int, BitArray) {
  let #(l, rest) = parse_var_int_loop(body, [])
  let l = list.reverse(l)

  let val =
    list.fold(l, <<>>, fn(b, a) {
      let assert <<_:size(1), val:size(7)>> = <<a:size(8)>>
      bit_array.concat([b, <<val:size(7)>>])
    })
  let byte_count = bit_array.byte_size(val)
  let size = { byte_count * 8 } - byte_count
  let assert <<num:size(size)>> = val

  #(num, rest)
}

pub fn parse_var_int_loop(
  body: BitArray,
  acc: List(Int),
) -> #(List(Int), BitArray) {
  io.debug(body)
  case body {
    <<1:size(1), val:size(7), rest:bits>> -> {
      io.debug(<<rest:bits>>)
      let list = list.append(acc, [val])
      parse_var_int_loop(rest, list)
    }
    <<1:size(1), val:size(7)>> -> {
      let list = list.append(acc, [val])
      parse_var_int_loop(<<>>, list)
    }
    <<0:size(1), val:size(7), rest:bits>> -> {
      let list = list.append(acc, [val])
      #(list, rest)
    }
    <<0:size(1), val:size(7)>> -> {
      let list = list.append(acc, [val])
      #(list, <<>>)
    }
    <<rest:bits>> -> {
      #(acc, rest)
    }
    _ -> {
      #(acc, <<>>)
    }
  }
}
