pub type ApiKeySupport {
  ApiKeySupport(version: Int, min: Int, max: Int)
}

pub fn api_versions() -> List(ApiKeySupport) {
  [ApiKeySupport(18, 0, 4)]
}

pub fn serialize_api_key_support(data: ApiKeySupport) -> BitArray {
  <<
    data.version:big-size(16),
    data.min:big-size(16),
    data.max:big-size(16),
    0:big-size(8),
  >>
}
