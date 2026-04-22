# zeroreg

Write regex without the tears or confusion.

`zeroreg` is a Gleam port of [`zeroreg-go`](https://github.com/sodiqscript111/zeroreg-go): a small, readable regex builder with pre-built patterns for common validation tasks.

## Status

This package currently targets Erlang/OTP because the runtime helpers use Erlang's `re` module.

## Installation

```sh
gleam add zeroreg
```

## Usage

```gleam
import zeroreg

pub fn phone() {
  let phone_pattern =
    zeroreg.optional_str("+")
    |> zeroreg.then(zeroreg.digit(3))
    |> zeroreg.then_str("-")
    |> zeroreg.then(zeroreg.digit(3))
    |> zeroreg.then_str("-")
    |> zeroreg.then(zeroreg.digit(4))

  zeroreg.test(phone_pattern, "+123-456-7890")
}
```

You can also use the built-in patterns:

```gleam
import zeroreg/patterns

pub fn valid_email(input: String) -> Bool {
  patterns.email()
  |> patterns.matches(input)
}
```

## Builder API

Character classes:

- `digit(count)`
- `non_digit()`
- `word()`
- `non_word()`
- `whitespace()`
- `non_whitespace()`
- `letter()`
- `lowercase()`
- `uppercase()`
- `alphanumeric()`
- `any()`
- `literal(string)`
- `char_in(chars)`
- `char_not_in(chars)`
- `range(from, to)`

Composition:

- `then(pattern, next)`
- `then_str(pattern, string)`
- `or_(pattern, other)`
- `or_str(pattern, string)`
- `group(pattern)`
- `capture(pattern)`
- `named_capture(pattern, name)`
- `one_of(patterns)`
- `one_of_str(strings)`

Quantifiers:

- `one_or_more(pattern)`
- `zero_or_more(pattern)`
- `optional(pattern)`
- `times(pattern, count)`
- `between(pattern, min, max)`
- `at_least(pattern, min)`
- `at_most(pattern, max)`

Anchors and escapes:

- `start_of_line()`
- `end_of_line()`
- `word_boundary()`
- `non_word_boundary()`
- `newline()`
- `tab()`
- `carriage_return()`

Runtime helpers:

- `source(pattern)`
- `test(pattern, input)`
- `match(pattern, input)`
- `match_all(pattern, input)`
- `replace(pattern, input, replacement)`

## Pre-built Patterns

The `zeroreg/patterns` module includes:

- `email`
- `url`
- `phone`
- `date`
- `time`
- `ipv4`
- `ipv6`
- `hex_color`
- `hex`
- `uuid`
- `slug`
- `hashtag`
- `mention`
- `credit_card`
- `ssn`
- `zip_code`
- `username`
- `semver`
- `mac_address`

And `strong_password(input)` as a helper function.

## CLI

The package also includes a tiny CLI module:

```sh
gleam run -m zeroreg_cli list
gleam run -m zeroreg_cli test email hello@world.com
gleam run -m zeroreg_cli match "\\d{3}-\\d{4}" 555-1234
gleam run -m zeroreg_cli demo
```
