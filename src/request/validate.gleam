pub type APIError {
  InvalidApiVersion
  Unsuported
}

pub fn validate_api_version(version: Int) -> Result(Nil, APIError) {
  case version {
    0 | 1 | 2 | 3 | 4 -> Ok(Nil)
    _ -> Error(InvalidApiVersion)
  }
}
