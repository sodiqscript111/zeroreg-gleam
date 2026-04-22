import gleam/int
import gleam/option.{type Option}
import gleam/string

pub opaque type Pattern {
  Pattern(String)
}

@external(erlang, "zeroreg_ffi", "escape")
fn escape_ffi(value: String) -> String

@external(erlang, "zeroreg_ffi", "test")
fn test_ffi(source: String, input: String) -> Bool

@external(erlang, "zeroreg_ffi", "match")
fn match_ffi(source: String, input: String) -> Option(List(String))

@external(erlang, "zeroreg_ffi", "match_all")
fn match_all_ffi(source: String, input: String) -> List(List(String))

@external(erlang, "zeroreg_ffi", "replace")
fn replace_ffi(source: String, input: String, replacement: String) -> String

pub fn new(source: String) -> Pattern {
  Pattern(source)
}

pub fn raw(source: String) -> Pattern {
  new(source)
}

pub fn source(pattern: Pattern) -> String {
  let Pattern(source) = pattern
  source
}

pub fn escape(value: String) -> String {
  escape_ffi(value)
}

pub fn then(pattern: Pattern, next: Pattern) -> Pattern {
  new(source(pattern) <> source(next))
}

pub fn then_str(pattern: Pattern, value: String) -> Pattern {
  new(source(pattern) <> escape(value))
}

pub fn one_or_more(pattern: Pattern) -> Pattern {
  new(wrap(pattern) <> "+")
}

pub fn zero_or_more(pattern: Pattern) -> Pattern {
  new(wrap(pattern) <> "*")
}

pub fn optional(pattern: Pattern) -> Pattern {
  new(wrap(pattern) <> "?")
}

pub fn times(pattern: Pattern, count: Int) -> Pattern {
  new(wrap(pattern) <> "{" <> int.to_string(count) <> "}")
}

pub fn between(pattern: Pattern, min: Int, max: Int) -> Pattern {
  new(
    wrap(pattern)
      <> "{"
      <> int.to_string(min)
      <> ","
      <> int.to_string(max)
      <> "}",
  )
}

pub fn at_least(pattern: Pattern, min: Int) -> Pattern {
  new(wrap(pattern) <> "{" <> int.to_string(min) <> ",}")
}

pub fn at_most(pattern: Pattern, max: Int) -> Pattern {
  new(wrap(pattern) <> "{0," <> int.to_string(max) <> "}")
}

pub fn or_(pattern: Pattern, other: Pattern) -> Pattern {
  new("(?:" <> source(pattern) <> "|" <> source(other) <> ")")
}

pub fn or_str(pattern: Pattern, value: String) -> Pattern {
  new("(?:" <> source(pattern) <> "|" <> escape(value) <> ")")
}

pub fn matches(pattern: Pattern, input: String) -> Bool {
  test_ffi(source(pattern), input)
}

pub fn match(pattern: Pattern, input: String) -> Option(List(String)) {
  match_ffi(source(pattern), input)
}

pub fn match_all(pattern: Pattern, input: String) -> List(List(String)) {
  match_all_ffi(source(pattern), input)
}

pub fn replace(pattern: Pattern, input: String, replacement: String) -> String {
  replace_ffi(source(pattern), input, replacement)
}

pub fn digit(count: Int) -> Pattern {
  case count > 0 {
    True -> new("\\d{" <> int.to_string(count) <> "}")
    False -> new("\\d")
  }
}

pub fn non_digit() -> Pattern {
  new("\\D")
}

pub fn word() -> Pattern {
  new("\\w")
}

pub fn non_word() -> Pattern {
  new("\\W")
}

pub fn whitespace() -> Pattern {
  new("\\s")
}

pub fn non_whitespace() -> Pattern {
  new("\\S")
}

pub fn letter() -> Pattern {
  new("[a-zA-Z]")
}

pub fn lowercase() -> Pattern {
  new("[a-z]")
}

pub fn uppercase() -> Pattern {
  new("[A-Z]")
}

pub fn alphanumeric() -> Pattern {
  new("[a-zA-Z0-9]")
}

pub fn any() -> Pattern {
  new(".")
}

pub fn literal(value: String) -> Pattern {
  new(escape(value))
}

pub fn char_in(chars: String) -> Pattern {
  new("[" <> escape_char_class(chars) <> "]")
}

pub fn char_not_in(chars: String) -> Pattern {
  new("[^" <> escape_char_class(chars) <> "]")
}

pub fn range(from: String, to: String) -> Pattern {
  new("[" <> from <> "-" <> to <> "]")
}

pub fn optional_str(value: String) -> Pattern {
  new("(?:" <> escape(value) <> ")?")
}

pub fn capture(pattern: Pattern) -> Pattern {
  new("(" <> source(pattern) <> ")")
}

pub fn named_capture(pattern: Pattern, name: String) -> Pattern {
  new("(?<" <> name <> ">" <> source(pattern) <> ")")
}

pub fn group(pattern: Pattern) -> Pattern {
  new("(?:" <> source(pattern) <> ")")
}

pub fn one_of(patterns: List(Pattern)) -> Pattern {
  let collected =
    patterns
    |> collect_sources([])
    |> reverse_strings([])
    |> join_with("|")

  new("(?:" <> collected <> ")")
}

pub fn one_of_str(values: List(String)) -> Pattern {
  let collected =
    values
    |> escape_all([])
    |> reverse_strings([])
    |> join_with("|")

  new("(?:" <> collected <> ")")
}

pub fn start_of_line() -> Pattern {
  new("^")
}

pub fn end_of_line() -> Pattern {
  new("$")
}

pub fn word_boundary() -> Pattern {
  new("\\b")
}

pub fn non_word_boundary() -> Pattern {
  new("\\B")
}

pub fn newline() -> Pattern {
  new("\\n")
}

pub fn tab() -> Pattern {
  new("\\t")
}

pub fn carriage_return() -> Pattern {
  new("\\r")
}

fn wrap(pattern: Pattern) -> String {
  let value = source(pattern)

  case string.length(value) <= 1 || is_wrapped(value) {
    True -> value
    False -> "(?:" <> value <> ")"
  }
}

fn is_wrapped(value: String) -> Bool {
  string.starts_with(value, "(?:") && string.ends_with(value, ")")
    || string.starts_with(value, "(") && string.ends_with(value, ")")
    || string.starts_with(value, "[") && string.ends_with(value, "]")
    || string.starts_with(value, "\\")
}

fn escape_char_class(chars: String) -> String {
  chars
  |> string.replace("\\", "\\\\")
  |> string.replace("]", "\\]")
  |> string.replace("^", "\\^")
  |> string.replace("-", "\\-")
}

fn collect_sources(patterns: List(Pattern), collected: List(String)) -> List(String) {
  case patterns {
    [] -> collected
    [pattern, ..rest] -> collect_sources(rest, [source(pattern), ..collected])
  }
}

fn escape_all(values: List(String), collected: List(String)) -> List(String) {
  case values {
    [] -> collected
    [value, ..rest] -> escape_all(rest, [escape(value), ..collected])
  }
}

fn reverse_strings(values: List(String), reversed: List(String)) -> List(String) {
  case values {
    [] -> reversed
    [value, ..rest] -> reverse_strings(rest, [value, ..reversed])
  }
}

fn join_with(values: List(String), separator: String) -> String {
  case values {
    [] -> ""
    [first, ..rest] -> join_rest(rest, separator, first)
  }
}

fn join_rest(values: List(String), separator: String, collected: String) -> String {
  case values {
    [] -> collected
    [value, ..rest] -> join_rest(rest, separator, collected <> separator <> value)
  }
}
