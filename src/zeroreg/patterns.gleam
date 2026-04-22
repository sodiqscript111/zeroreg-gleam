import zeroreg
import gleam/string

pub type PatternInfo {
  PatternInfo(String, String, String, zeroreg.Pattern)
}

pub fn email() -> zeroreg.Pattern {
  zeroreg.new("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")
}

pub fn url() -> zeroreg.Pattern {
  zeroreg.new(
    "^https?://(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&/=]*)$",
  )
}

pub fn phone() -> zeroreg.Pattern {
  zeroreg.new("^\\+?[1-9]?[0-9]{0,3}?[-. (]?[0-9]{1,4}[-. )]?[0-9]{1,4}[-. ]?[0-9]{1,9}$")
}

pub fn date() -> zeroreg.Pattern {
  zeroreg.new("^\\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\\d|3[01])$")
}

pub fn time() -> zeroreg.Pattern {
  zeroreg.new("^(?:[01]\\d|2[0-3]):[0-5]\\d(?::[0-5]\\d)?$")
}

pub fn ipv4() -> zeroreg.Pattern {
  zeroreg.new("^(?:(?:25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$")
}

pub fn ipv6() -> zeroreg.Pattern {
  zeroreg.new("^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$")
}

pub fn hex_color() -> zeroreg.Pattern {
  zeroreg.new("^#(?:[0-9a-fA-F]{3}){1,2}$")
}

pub fn hex() -> zeroreg.Pattern {
  zeroreg.new("^[0-9a-fA-F]+$")
}

pub fn uuid() -> zeroreg.Pattern {
  zeroreg.new(
    "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$",
  )
}

pub fn slug() -> zeroreg.Pattern {
  zeroreg.new("^[a-z0-9]+(?:-[a-z0-9]+)*$")
}

pub fn hashtag() -> zeroreg.Pattern {
  zeroreg.new("#[a-zA-Z0-9_]+")
}

pub fn mention() -> zeroreg.Pattern {
  zeroreg.new("@[a-zA-Z0-9_]+")
}

pub fn credit_card() -> zeroreg.Pattern {
  zeroreg.new("^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})$")
}

pub fn ssn() -> zeroreg.Pattern {
  zeroreg.new("^\\d{3}-\\d{2}-\\d{4}$")
}

pub fn zip_code() -> zeroreg.Pattern {
  zeroreg.new("^\\d{5}(?:-\\d{4})?$")
}

pub fn username() -> zeroreg.Pattern {
  zeroreg.new("^[a-zA-Z0-9_]{3,16}$")
}

pub fn semver() -> zeroreg.Pattern {
  zeroreg.new("^(?:0|[1-9]\\d*)\\.(?:0|[1-9]\\d*)\\.(?:0|[1-9]\\d*)(?:-[a-zA-Z0-9]+)?$")
}

pub fn mac_address() -> zeroreg.Pattern {
  zeroreg.new("^(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$")
}

pub fn strong_password(input: String) -> Bool {
  string_length_at_least(input, 8)
    && zeroreg.test(zeroreg.new("[a-z]"), input)
    && zeroreg.test(zeroreg.new("[A-Z]"), input)
    && zeroreg.test(zeroreg.new("\\d"), input)
    && zeroreg.test(zeroreg.new("[@$!%*?&]"), input)
}

pub fn matches(pattern: zeroreg.Pattern, input: String) -> Bool {
  zeroreg.test(pattern, input)
}

pub fn all() -> List(PatternInfo) {
  [
    PatternInfo("email", "Email address", "user@example.com", email()),
    PatternInfo("url", "HTTP/HTTPS URL", "https://example.com", url()),
    PatternInfo("phone", "Phone number", "+1-234-567-8900", phone()),
    PatternInfo("date", "ISO date (YYYY-MM-DD)", "2024-03-15", date()),
    PatternInfo("time", "24-hour time (HH:MM:SS)", "14:30", time()),
    PatternInfo("ipv4", "IPv4 address", "192.168.1.1", ipv4()),
    PatternInfo(
      "ipv6",
      "IPv6 address",
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
      ipv6(),
    ),
    PatternInfo("hexcolor", "Hex color code", "#ff5733", hex_color()),
    PatternInfo("hex", "Hexadecimal string", "DEADBEEF", hex()),
    PatternInfo("uuid", "UUID v1-v5", "550e8400-e29b-41d4-a716-446655440000", uuid()),
    PatternInfo("slug", "URL slug", "my-awesome-post", slug()),
    PatternInfo("hashtag", "Hashtag", "#gleam", hashtag()),
    PatternInfo("mention", "@mention", "@username", mention()),
    PatternInfo("creditcard", "Credit card number", "4111111111111111", credit_card()),
    PatternInfo("ssn", "US Social Security Number", "123-45-6789", ssn()),
    PatternInfo("zipcode", "US ZIP code", "12345", zip_code()),
    PatternInfo("username", "Username (3-16 chars)", "cool_user42", username()),
    PatternInfo("semver", "Semantic version", "2.1.3", semver()),
    PatternInfo("macaddress", "MAC address", "00:1A:2B:3C:4D:5E", mac_address()),
  ]
}

fn string_length_at_least(value: String, min: Int) -> Bool {
  string.length(value) >= min
}
