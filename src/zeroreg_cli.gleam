import gleam/int
import gleam/io
import gleam/option
import gleam/string
import zeroreg
import zeroreg/patterns

@external(erlang, "zeroreg_cli_ffi", "argv")
fn argv() -> List(String)

pub fn main() {
  case argv() {
    ["list"] -> cmd_list()
    ["test", name, input] -> cmd_test(name, input)
    ["match", regex, input] -> cmd_match(regex, input)
    ["demo"] -> cmd_demo()
    _ -> print_usage()
  }
}

fn print_usage() {
  io.println("zeroreg cli")
  io.println("")
  io.println("Usage:")
  io.println("  gleam run -m zeroreg_cli list")
  io.println("  gleam run -m zeroreg_cli test <pattern-name> <input>")
  io.println("  gleam run -m zeroreg_cli match <regex> <input>")
  io.println("  gleam run -m zeroreg_cli demo")
}

fn cmd_list() {
  io.println("Available patterns:")
  print_infos(patterns.all())
  io.println("strongpassword - password helper function")
}

fn cmd_test(name: String, input: String) {
  let lower = string.lowercase(name)

  case lower == "strongpassword" {
    True -> print_result(lower, input, patterns.strong_password(input))
    False ->
      case find_pattern(patterns.all(), lower) {
        option.Some(patterns.PatternInfo(_, _, _, pattern)) -> {
          io.println("Regex: " <> zeroreg.source(pattern))
          print_result(lower, input, zeroreg.test(pattern, input))
        }
        option.None -> io.println("Unknown pattern: " <> lower)
      }
  }
}

fn cmd_match(regex: String, input: String) {
  let pattern = zeroreg.raw(regex)
  let captures = zeroreg.match(pattern, input)

  io.println("Pattern: " <> regex)
  io.println("Input:   " <> input)
  print_result(regex, input, zeroreg.test(pattern, input))
  print_captures(captures)
}

fn cmd_demo() {
  let #(passed, failed) = demo_all(patterns.all(), 0, 0)
  let strong_password_passed = patterns.strong_password("MyP@ss1!")
  let final_passed =
    case strong_password_passed {
      True -> passed + 1
      False -> passed
    }

  let final_failed =
    case strong_password_passed {
      True -> failed
      False -> failed + 1
    }

  io.println("")
  io.println("Summary:")
  io.println(
    int.to_string(final_passed)
      <> " passed, "
      <> int.to_string(final_failed)
      <> " failed",
  )
}

fn print_infos(infos: List(patterns.PatternInfo)) {
  case infos {
    [] -> Nil
    [patterns.PatternInfo(name, description, example, _), ..rest] -> {
      io.println(name <> " - " <> description <> " (" <> example <> ")")
      print_infos(rest)
    }
  }
}

fn find_pattern(
  infos: List(patterns.PatternInfo),
  wanted: String,
) -> option.Option(patterns.PatternInfo) {
  case infos {
    [] -> option.None
    [info, ..rest] ->
      case info {
        patterns.PatternInfo(name, _, _, _) ->
          case name == wanted {
            True -> option.Some(info)
            False -> find_pattern(rest, wanted)
          }
      }
  }
}

fn print_result(name: String, input: String, matched: Bool) {
  case matched {
    True -> io.println("MATCH: " <> name <> " -> " <> input)
    False -> io.println("NO MATCH: " <> name <> " -> " <> input)
  }
}

fn print_captures(captures: option.Option(List(String))) {
  case captures {
    option.None -> Nil
    option.Some(values) -> {
      io.println("Captures:")
      print_capture_values(values, 0)
    }
  }
}

fn print_capture_values(values: List(String), index: Int) {
  case values {
    [] -> Nil
    [value, ..rest] -> {
      io.println("  [" <> int.to_string(index) <> "] " <> value)
      print_capture_values(rest, index + 1)
    }
  }
}

fn demo_all(
  infos: List(patterns.PatternInfo),
  passed: Int,
  failed: Int,
) -> #(Int, Int) {
  case infos {
    [] -> #(passed, failed)
    [patterns.PatternInfo(name, _, example, pattern), ..rest] -> {
      let matched = zeroreg.test(pattern, example)
      print_result(name, example, matched)

      case matched {
        True -> demo_all(rest, passed + 1, failed)
        False -> demo_all(rest, passed, failed + 1)
      }
    }
  }
}
