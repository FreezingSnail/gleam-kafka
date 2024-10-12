pub type RequestHeader {
  Header(
    req_len: Int,
    req_api_key: Int,
    req_api_version: Int,
    correlation_id: Int,
  )
}

pub fn parse_request_header(request: BitArray) -> RequestHeader {
  let assert <<
    req_len:size(32),
    req_api_key:size(16),
    req_api_version:size(16),
    correlation_id:size(32),
    _rest:bits,
  >> = request

  Header(req_len, req_api_key, req_api_version, correlation_id)
}
