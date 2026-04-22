import gleam/option
import gleeunit
import zeroreg

pub fn main() {
  gleeunit.main()
}

pub fn new_test() {
  let assert "\\d+" = zeroreg.new("\\d+") |> zeroreg.source
}

pub fn then_test() {
  let pattern =
    zeroreg.digit(0)
    |> zeroreg.then(zeroreg.literal("-"))
    |> zeroreg.then(zeroreg.digit(0))

  let assert "\\d-\\d" = zeroreg.source(pattern)
}

pub fn then_str_test() {
  let pattern =
    zeroreg.digit(0)
    |> zeroreg.then_str("-")
    |> zeroreg.then(zeroreg.digit(0))

  let assert "\\d-\\d" = zeroreg.source(pattern)
}

pub fn quantifier_test() {
  let pattern =
    zeroreg.start_of_line()
    |> zeroreg.then(zeroreg.digit(0) |> zeroreg.between(2, 4))
    |> zeroreg.then(zeroreg.end_of_line())

  let assert True = zeroreg.matches(pattern, "12")
  let assert True = zeroreg.matches(pattern, "1234")
  let assert False = zeroreg.matches(pattern, "1")
  let assert False = zeroreg.matches(pattern, "12345")
}

pub fn optional_test() {
  let pattern =
    zeroreg.start_of_line()
    |> zeroreg.then(zeroreg.literal("+") |> zeroreg.optional())
    |> zeroreg.then(zeroreg.digit(3))
    |> zeroreg.then(zeroreg.end_of_line())

  let assert True = zeroreg.matches(pattern, "123")
  let assert True = zeroreg.matches(pattern, "+123")
  let assert False = zeroreg.matches(pattern, "++123")
}

pub fn match_test() {
  let pattern = zeroreg.capture(zeroreg.digit(3))
  let assert option.Some([matched, area]) = zeroreg.match(pattern, "call 555-1234")
  let assert "555" = matched
  let assert "555" = area
}

pub fn match_all_test() {
  let matches = zeroreg.match_all(zeroreg.digit(3), "123-456-789")
  let assert 3 = list_length(matches)
}

pub fn replace_test() {
  let assert "aXbXcX" = zeroreg.replace(zeroreg.digit(0), "a1b2c3", "X")
}

pub fn one_of_test() {
  let pattern =
    zeroreg.one_of([zeroreg.literal("cat"), zeroreg.literal("dog"), zeroreg.literal("bird")])

  let assert True = zeroreg.matches(pattern, "cat")
  let assert True = zeroreg.matches(pattern, "bird")
  let assert False = zeroreg.matches(pattern, "fish")
}

pub fn phone_builder_test() {
  let phone =
    zeroreg.optional_str("+")
    |> zeroreg.then(zeroreg.digit(3))
    |> zeroreg.then_str("-")
    |> zeroreg.then(zeroreg.digit(3))
    |> zeroreg.then_str("-")
    |> zeroreg.then(zeroreg.digit(4))

  let assert True = zeroreg.matches(phone, "+123-456-7890")
  let assert True = zeroreg.matches(phone, "123-456-7890")
}

fn list_length(values: List(a)) -> Int {
  case values {
    [] -> 0
    [_, ..rest] -> 1 + list_length(rest)
  }
}
