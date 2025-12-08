import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{type FileError}

pub fn main() -> Nil {
  let assert Ok(ranges) = parse_input("../input")
  io.println(
    "part one: "
    <> int.to_string(sum_invalid(ranges, find_invalid_in_range_part_one)),
  )
  io.println(
    "part two: "
    <> int.to_string(sum_invalid(ranges, find_invalid_in_range_part_two)),
  )
}

fn parse_input(input_path: String) -> Result(List(IdRange), FileError) {
  input_path
  |> simplifile.read
  |> result.map(fn(input) {
    input
    |> string.trim
    |> string.split(",")
    |> list.map(parse_id_range)
  })
}

fn parse_id_range(id_range: String) -> IdRange {
  case string.split(id_range, "-") {
    [left, right] -> {
      let assert Ok(first) = int.parse(left)
        as { "failed to parse left: " <> id_range }
      let assert Ok(last) = int.parse(right)
        as { "failed to parse right: " <> id_range }
      IdRange(first:, last:)
    }
    _ -> panic as { "unexpected id range: " <> id_range }
  }
}

type IdRange {
  IdRange(first: Int, last: Int)
}

type IdRangeSameDigits {
  IdRangeSameDigits(first: Int, last: Int)
}

fn sum_invalid(
  id_ranges: List(IdRange),
  find_invalid_in_range: fn(IdRangeSameDigits) -> Set(Int),
) {
  id_ranges
  |> list.flat_map(split_range_into_same_digit_ranges)
  |> list.map(find_invalid_in_range)
  |> list.reduce(set.union)
  |> result.unwrap(set.new())
  |> set.to_list
  |> int.sum
}

fn find_invalid_in_range_part_one(range: IdRangeSameDigits) -> Set(Int) {
  assert count_digits(range.first) == count_digits(range.last)
  let range_digits = count_digits(range.first)
  case range_digits % 2 {
    0 -> find_repeats_in(range:, prefix_len: range_digits / 2)
    _ -> set.new()
  }
}

fn find_invalid_in_range_part_two(range: IdRangeSameDigits) -> Set(Int) {
  assert count_digits(range.first) == count_digits(range.last)
  let range_digits = count_digits(range.first)
  case range_digits {
    range_digits if range_digits < 1 -> panic
    1 -> set.new()
    range_digits ->
      list.range(1, range_digits / 2)
      |> list.map(find_repeats_in(range:, prefix_len: _))
      |> list.reduce(set.union)
      |> result.unwrap(set.new())
  }
}

fn find_repeats_in(
  range range: IdRangeSameDigits,
  prefix_len len: Int,
) -> Set(Int) {
  let min = get_first_digits(range.first, len)
  let max = get_first_digits(range.last, len)
  let repeats = count_digits(range.first) / len
  list.range(min, max)
  |> list.map(repeat_digits(_, repeats))
  |> list.filter(fn(x) { range.first <= x && x <= range.last })
  |> set.from_list
}

fn split_range_into_same_digit_ranges(range: IdRange) -> List(IdRangeSameDigits) {
  split_range_into_same_digit_ranges_loop(range, [])
}

fn split_range_into_same_digit_ranges_loop(
  range: IdRange,
  acc: List(IdRangeSameDigits),
) -> List(IdRangeSameDigits) {
  let first = range.first
  let last = range.last
  let first_digits = count_digits(first)
  let last_digits = count_digits(last)
  case first_digits != last_digits {
    False -> [IdRangeSameDigits(first: range.first, last: range.last), ..acc]
    True -> {
      let assert Ok(rest_range_first) =
        first_digits
        |> int.to_float
        |> int.power(10, _)
        |> result.map(float.round)
      let first_range =
        IdRangeSameDigits(first: range.first, last: rest_range_first - 1)
      let rest_range = IdRange(first: rest_range_first, last: range.last)
      split_range_into_same_digit_ranges_loop(rest_range, [first_range, ..acc])
    }
  }
}

fn count_digits(x: Int) -> Int {
  count_digits_loop(x, 0)
}

fn count_digits_loop(x: Int, acc: Int) -> Int {
  case int.absolute_value(x) < 10 {
    True -> acc + 1
    False -> count_digits_loop(x / 10, acc + 1)
  }
}

fn repeat_digits(x: Int, times: Int) -> Int {
  let digits = count_digits(x)
  repeat_digits_loop(x, digits, times, 0)
}

fn repeat_digits_loop(x: Int, digits: Int, times: Int, acc: Int) -> Int {
  case times {
    times if times < 0 -> panic
    0 -> acc
    times -> {
      let assert Ok(offset) =
        digits
        |> int.to_float
        |> int.power(10, _)
        |> result.map(float.round)
      repeat_digits_loop(x, digits, times - 1, acc * offset + x)
    }
  }
}

fn get_first_digits(x: Int, count: Int) -> Int {
  get_first_digits_loop(get_digits(x), count, 0)
}

fn get_first_digits_loop(digits: List(Int), count: Int, acc: Int) -> Int {
  case count {
    count if count < 0 -> panic
    0 -> acc
    count ->
      case digits {
        [x, ..rest] -> get_first_digits_loop(rest, count - 1, acc * 10 + x)
        [] -> panic
      }
  }
}

fn get_digits(x: Int) -> List(Int) {
  get_digits_loop(x, [])
}

fn get_digits_loop(x: Int, acc: List(Int)) -> List(Int) {
  case int.absolute_value(x) < 10 {
    True -> [x, ..acc]
    False -> get_digits_loop(x / 10, [x % 10, ..acc])
  }
}
