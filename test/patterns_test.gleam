import gleeunit
import zeroreg
import zeroreg/patterns

pub fn main() {
  gleeunit.main()
}

pub fn email_pattern_test() {
  let assert True = zeroreg.test(patterns.email(), "user@example.com")
  let assert True = zeroreg.test(patterns.email(), "test.user+tag@domain.co.uk")
  let assert False = zeroreg.test(patterns.email(), "@example.com")
}

pub fn url_pattern_test() {
  let assert True = zeroreg.test(patterns.url(), "https://example.com")
  let assert False = zeroreg.test(patterns.url(), "ftp://example.com")
}

pub fn date_pattern_test() {
  let assert True = zeroreg.test(patterns.date(), "2024-03-15")
  let assert False = zeroreg.test(patterns.date(), "2024-13-01")
}

pub fn time_pattern_test() {
  let assert True = zeroreg.test(patterns.time(), "14:30")
  let assert False = zeroreg.test(patterns.time(), "25:00")
}

pub fn ipv4_pattern_test() {
  let assert True = zeroreg.test(patterns.ipv4(), "192.168.1.1")
  let assert False = zeroreg.test(patterns.ipv4(), "256.1.1.1")
}

pub fn uuid_pattern_test() {
  let assert True = zeroreg.test(patterns.uuid(), "550e8400-e29b-41d4-a716-446655440000")
  let assert False = zeroreg.test(patterns.uuid(), "not-a-uuid")
}

pub fn slug_pattern_test() {
  let assert True = zeroreg.test(patterns.slug(), "my-awesome-post")
  let assert False = zeroreg.test(patterns.slug(), "Hello-World")
}

pub fn hex_color_pattern_test() {
  let assert True = zeroreg.test(patterns.hex_color(), "#ff5733")
  let assert False = zeroreg.test(patterns.hex_color(), "#gggggg")
}

pub fn username_pattern_test() {
  let assert True = zeroreg.test(patterns.username(), "cool_user42")
  let assert False = zeroreg.test(patterns.username(), "ab")
}

pub fn semver_pattern_test() {
  let assert True = zeroreg.test(patterns.semver(), "2.1.3")
  let assert False = zeroreg.test(patterns.semver(), "v1.0.0")
}

pub fn mac_address_pattern_test() {
  let assert True = zeroreg.test(patterns.mac_address(), "00:1A:2B:3C:4D:5E")
  let assert False = zeroreg.test(patterns.mac_address(), "GG:HH:II:JJ:KK:LL")
}

pub fn strong_password_test() {
  let assert True = patterns.strong_password("MyP@ss1!")
  let assert False = patterns.strong_password("short1!")
}

pub fn all_patterns_test() {
  let assert 19 = list_length(patterns.all())
}

fn list_length(values: List(a)) -> Int {
  case values {
    [] -> 0
    [_, ..rest] -> 1 + list_length(rest)
  }
}
