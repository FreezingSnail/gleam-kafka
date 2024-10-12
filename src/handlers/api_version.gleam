pub type ApiKeySupport {
  ApiKeySupport(version: Int, min: Int, max: Int)
}

pub fn api_versions() -> List(ApiKeySupport) {
  [ApiKeySupport(18, 4, 4)]
}

pub fn serialize_api_key_support(data: ApiKeySupport) -> BitArray {
  <<data.version:size(2), data.min:size(2), data.max:size(2)>>
}
