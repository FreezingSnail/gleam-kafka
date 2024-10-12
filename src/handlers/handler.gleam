import gleam/bytes_builder
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
  |> bytes_builder.append(<<0:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
  |> bytes_builder.append(err)
}

fn response_message(correlation_id, _resonse) -> bytes_builder.BytesBuilder {
  bytes_builder.new()
  |> bytes_builder.append(<<0:size(32)>>)
  |> bytes_builder.append(<<correlation_id:size(32)>>)
}
