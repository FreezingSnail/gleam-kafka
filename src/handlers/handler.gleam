import gleam/bit_array
import gleam/bytes_builder
import gleam/list
import handlers/api_version
import request/request
import request/validate

pub fn request_handler(request: BitArray) -> bytes_builder.BytesBuilder {
  let header = request.parse_request_header(request)
  case validate.validate_api_version(header.req_api_version) {
    Ok(_) -> response_message(header.correlation_id, "resp")
    Error(err) -> error_message(header.correlation_id, err)
  }
}

fn error_message(
  correlation_id: Int,
  error: validate.APIError,
) -> bytes_builder.BytesBuilder {
  let err = case error {
    validate.InvalidApiVersion -> <<35:size(16)>>
    //_ -> <<1:size(8)>>
  }
  bytes_builder.new()
  |> bytes_builder.append(<<6:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  |> bytes_builder.append(err)
}

fn response_message(correlation_id, _resonse) -> bytes_builder.BytesBuilder {
  let versions = api_version.api_versions()
  let len = list.length(versions) * 6
  let body =
    bit_array.concat(
      versions
      |> list.map(api_version.serialize_api_key_support),
    )

  let resp_len = 6 + len

  bytes_builder.new()
  |> bytes_builder.append(<<resp_len:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  |> bytes_builder.append(<<0:size(16)>>)
  |> bytes_builder.append(body)
}
