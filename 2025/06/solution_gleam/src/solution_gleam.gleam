import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/string
import simplifile

pub fn main() -> Nil {
  io.println(
    "part one: " <> parse_input_part_one("../input") |> solve |> int.to_string,
  )
  io.println(
    "part one: " <> parse_input_part_two("../input") |> solve |> int.to_string,
  )
}

type Operation {
  Add
  Multiply
}

type Problem {
  Problem(numbers: List(Int), operation: Operation)
}

fn solve(problems: List(Problem)) -> Int {
  problems
  |> list.map(solve_problem)
  |> int.sum
}

fn solve_problem(problem: Problem) -> Int {
  case problem.operation {
    Add -> int.sum(problem.numbers)
    Multiply -> int.product(problem.numbers)
  }
}

fn parse_input_part_one(input_path: String) -> List(Problem) {
  let rows = read_rows(input_path)
  let rows_count = list.length(rows)
  let numbers =
    rows |> list.take(rows_count - 1) |> list.map(parse_numbers_row_part_one)
  let assert Ok(operations_row) = list.last(rows)
  let operations = parse_operations_row_part_one(operations_row)
  list.zip(list.transpose(numbers), operations)
  |> list.map(fn(x) { Problem(numbers: x.0, operation: x.1) })
}

fn parse_numbers_row_part_one(row: String) -> List(Int) {
  row
  |> string.split(" ")
  |> list.filter(fn(str) { !string.is_empty(str) })
  |> list.map(fn(str) {
    let assert Ok(number) = int.parse(str)
    number
  })
}

fn parse_operations_row_part_one(row: String) -> List(Operation) {
  row
  |> string.split(" ")
  |> list.filter(fn(str) { !string.is_empty(str) })
  |> list.map(fn(str) {
    case str {
      "+" -> Add
      "*" -> Multiply
      _ -> panic as { "unexpected operation: " <> str }
    }
  })
}

fn parse_input_part_two(input_path: String) -> List(Problem) {
  let rows = read_rows(input_path)
  let assert Ok(operations_row) = list.last(rows)
  let operations_and_digits = parse_operations_row_part_two(operations_row)
  let operations = list.map(operations_and_digits, fn(x) { x.0 })
  let digits_per_column = list.map(operations_and_digits, fn(x) { x.1 })
  let rows_count = list.length(rows)
  let numbers =
    rows
    |> list.take(rows_count - 1)
    |> list.map(parse_numbers_row_part_two(_, digits_per_column))
    |> list.map(fn(x) {
      assert list.length(x) == list.length(operations_and_digits)
      x
    })
    |> list.transpose
    |> list.map(fn(column) {
      column
      |> list.transpose
      |> list.reverse
      |> list.map(fn(digits) {
        list.fold(digits, 0, fn(acc, digit) {
          case digit {
            option.None -> acc
            option.Some(digit) -> acc * 10 + digit
          }
        })
      })
    })
  assert list.length(operations) == list.length(numbers)
  list.zip(numbers, operations)
  |> list.map(fn(x) { Problem(numbers: x.0, operation: x.1) })
}

fn parse_operations_row_part_two(row: String) -> List(#(Operation, Int)) {
  parse_operations_row_part_two_loop(row, [])
}

fn parse_operations_row_part_two_loop(
  rest: String,
  acc: List(#(Operation, Int)),
) -> List(#(Operation, Int)) {
  case rest {
    "" -> list.reverse(acc)
    _ -> {
      let #(operation, digits, new_rest) = parse_operation_part_two(rest)
      parse_operations_row_part_two_loop(new_rest, [#(operation, digits), ..acc])
    }
  }
}

fn parse_operation_part_two(row: String) -> #(Operation, Int, String) {
  let assert Ok(char) = string.first(row)
  let operation = case char {
    "+" -> Add
    "*" -> Multiply
    _ -> panic as { "unexpected operation: " <> char }
  }
  let loop_result = parse_operation_part_two_loop(string.drop_start(row, 1), 0)
  #(operation, loop_result.0, loop_result.1)
}

fn parse_operation_part_two_loop(
  rest: String,
  blanks_consumed: Int,
) -> #(Int, String) {
  case string.first(rest) {
    Ok(char) ->
      case char {
        "+" | "*" -> #(blanks_consumed, rest)
        " " ->
          parse_operation_part_two_loop(
            string.drop_start(rest, 1),
            blanks_consumed + 1,
          )
        _ -> panic as { "unexpected operation row char: " <> char }
      }
    Error(Nil) -> {
      #(blanks_consumed + 1, "")
    }
  }
}

fn parse_numbers_row_part_two(
  row: String,
  digits_per_column: List(Int),
) -> List(List(Option(Int))) {
  parse_numbers_row_part_two_loop(row, digits_per_column, [])
}

fn parse_numbers_row_part_two_loop(
  rest: String,
  digits_per_column_left: List(Int),
  acc: List(List(Option(Int))),
) -> List(List(Option(Int))) {
  case digits_per_column_left {
    [] -> list.reverse(acc)
    [digits, ..digits_rest] -> {
      parse_numbers_row_part_two_loop(
        string.drop_start(rest, digits + 1),
        digits_rest,
        [parse_digits_in_row_part_two(rest, digits), ..acc],
      )
    }
  }
}

fn parse_digits_in_row_part_two(row: String, digits: Int) -> List(Option(Int)) {
  parse_digits_in_row_part_two_loop(row, digits, [])
}

fn parse_digits_in_row_part_two_loop(
  rest: String,
  digits_left: Int,
  acc: List(Option(Int)),
) -> List(Option(Int)) {
  case digits_left {
    x if x < 0 -> panic as "unreachable"
    0 -> list.reverse(acc)
    _ ->
      parse_digits_in_row_part_two_loop(
        string.drop_start(rest, 1),
        digits_left - 1,
        [read_digit_or_space(rest), ..acc],
      )
  }
}

fn read_digit_or_space(str: String) -> Option(Int) {
  let assert Ok(char) = string.first(str)
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> {
      let assert Ok(digit) = int.parse(char)
      option.Some(digit)
    }
    " " -> option.None
    _ -> panic as { "unexpected digit: " <> char }
  }
}

fn read_rows(input_path: String) -> List(String) {
  let assert Ok(input) = simplifile.read(input_path)
  input
  |> string.split("\n")
  |> list.filter(fn(str) { !string.is_empty(str) })
}
