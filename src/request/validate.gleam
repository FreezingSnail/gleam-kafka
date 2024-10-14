import request/errors.{type APIError}

pub fn validate_api_version(version: Int) -> Result(Nil, APIError) {
  case version {
    0 | 1 | 2 | 3 | 4 -> Ok(Nil)
    _ -> Error(errors.InvalidApiVersion)
  }
}
