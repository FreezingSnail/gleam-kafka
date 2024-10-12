import gleam/bit_array
import gleam/list
import gleeunit/should
import handlers/api_version

pub fn api_version_serialze_test() {
  let supported = api_version.api_versions()
  let serialized = list.map(supported, api_version.serialize_api_key_support)
  should.equal(serialized, [<<18:size(16), 4:size(16), 4:size(16)>>])
  let serialized2 =
    bit_array.concat(
      supported
      |> list.map(api_version.serialize_api_key_support),
    )

  should.equal(serialized2, <<18:size(16), 4:size(16), 4:size(16)>>)
}
