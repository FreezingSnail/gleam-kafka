pub type RequestHeader {
  HeaderV1(req_len: Int, api_key: Int, api_version: Int, correlation_id: Int)
  HeaderV2(
    req_len: Int,
    api_key: Int,
    api_version: Int,
    correlation_id: Int,
    client_id: String,
  )
}
