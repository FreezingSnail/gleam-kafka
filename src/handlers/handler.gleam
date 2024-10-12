import gleam/bit_array
import gleam/bytes_builder
import gleam/io
import gleam/list
import handlers/api_version
import request/request.{type RequestHeader}
import request/validate

pub fn request_handler(request: BitArray) -> bytes_builder.BytesBuilder {
  io.println("handling request")
  let header = request.parse_request_header(request)
  case validate.validate_api_version(header.req_api_version) {
    Ok(_) -> route_api_key(header, request)
    Error(err) -> error_message(header.correlation_id, err)
  }
}

fn route_api_key(
  header: RequestHeader,
  _request: BitArray,
) -> bytes_builder.BytesBuilder {
  case header.req_api_version {
    18 -> api_version_handler(header.correlation_id, "resp")
    _ -> error_message(header.correlation_id, validate.Unsuported)
  }
}

fn error_message(
  correlation_id: Int,
  error: validate.APIError,
) -> bytes_builder.BytesBuilder {
  let err = case error {
    validate.InvalidApiVersion -> <<35:size(16)>>
    _ -> <<111:size(8)>>
  }
  bytes_builder.new()
  |> bytes_builder.append(<<6:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  |> bytes_builder.append(err)
}

fn api_version_handler(correlation_id, _resonse) -> bytes_builder.BytesBuilder {
  io.println("responding to api version request")
  let versions = api_version.api_versions()
  let len = list.length(versions)
  let body =
    bit_array.concat(
      versions
      |> list.map(api_version.serialize_api_key_support),
    )

  let resp_len = 4 + 2 + 1 + { len * 7 } + 5

  bytes_builder.new()
  //size 
  |> bytes_builder.append(<<resp_len:size(32)>>)
  //header
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  //err code
  |> bytes_builder.append(<<0:size(16)>>)
  //count
  |> bytes_builder.append(<<2:size(8)>>)
  //array
  |> bytes_builder.append(body)
  //throttle and tag buffer
  |> bytes_builder.append(<<0:size(32), 0:size(8)>>)
}
