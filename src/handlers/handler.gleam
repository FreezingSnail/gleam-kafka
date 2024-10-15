import domain/parser
import gleam/bit_array
import gleam/bytes_builder
import gleam/io
import gleam/list
import handlers/api_version
import request/errors.{type APIError}
import request/request.{type RequestHeader}
import request/validate

pub fn request_handler(request: BitArray) -> bytes_builder.BytesBuilder {
  io.println("handling request")
  let header: request.RequestHeader = parser.parse_request_header_v2(request)
  io.debug(header)
  case validate.validate_api_version(header.api_version) {
    Ok(_) -> route_api_key(header, request)
    Error(err) -> {
      io.println("failed to validate header")
      error_message(header.correlation_id, err)
    }
  }
}

fn route_api_key(
  header: RequestHeader,
  _request: BitArray,
) -> bytes_builder.BytesBuilder {
  case header.api_key {
    18 -> api_version_handler(header.correlation_id)
    75 -> describe_topic_partitions_handler(header.correlation_id)
    _ -> error_message(header.correlation_id, errors.Unsuported)
  }
}

fn error_message(
  correlation_id: Int,
  error: errors.APIError,
) -> bytes_builder.BytesBuilder {
  let err = case error {
    errors.InvalidApiVersion -> <<35:size(16)>>
    _ -> <<1:size(8)>>
  }
  bytes_builder.new()
  |> bytes_builder.append(<<6:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  |> bytes_builder.append(err)
}

fn api_version_handler(correlation_id: Int) -> bytes_builder.BytesBuilder {
  io.println("responding to api version request")
  let versions = api_version.api_versions()
  let len = list.length(versions)
  let body =
    bit_array.concat(
      versions
      |> list.map(api_version.serialize_api_key_support),
    )

  let resp_len = 4 + 2 + 1 + { len * 7 } + 5

  // offset forward by 1, 0 is null, 1 -> 0, 2 -> 1...
  let array_len = len + 1

  bytes_builder.new()
  //size 
  |> bytes_builder.append(<<resp_len:size(32)>>)
  //header
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  //err code
  |> bytes_builder.append(<<0:size(16)>>)
  //count
  |> bytes_builder.append(<<array_len:size(8)>>)
  //array
  |> bytes_builder.append(body)
  //throttle and tag buffer
  |> bytes_builder.append(<<0:size(32), 0:size(8)>>)
}

fn describe_topic_partitions_handler(
  correlation_id: Int,
) -> bytes_builder.BytesBuilder {
  let resp_len = 0
  let partion = get_partition_info()

  case partion {
    Ok(_) -> {
      bytes_builder.new()
      //size 
      |> bytes_builder.append(<<resp_len:size(32)>>)
      //header
      |> bytes_builder.append(<<correlation_id:size(32)>>)
      //err code
      |> bytes_builder.append(<<0:size(16)>>)
      //count
      //array
      //throttle and tag buffer
      |> bytes_builder.append(<<0:size(32), 0:size(8)>>)
    }
    Error(_) -> describe_topic_partitions_error(correlation_id, "")
  }
}

fn get_partition_info() -> Result(Int, APIError) {
  Error(errors.UnknownTopicOrPartition)
}

fn describe_topic_partitions_error(
  correlation_id: Int,
  topic: String,
) -> bytes_builder.BytesBuilder {
  bytes_builder.new()
  //size 
  |> bytes_builder.append(<<0:size(32)>>)
  //header
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  //throttle and buffer
  |> bytes_builder.append(<<0:size(40)>>)
}
