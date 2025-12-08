import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let banks = parse_input("../input")
  io.println("part one: " <> int.to_string(part_one(banks)))
  io.println("part two: " <> int.to_string(part_two(banks)))
}

fn parse_input(input_path: String) -> List(List(Int)) {
  let assert Ok(input) = simplifile.read(input_path)
  input
  |> string.split("\n")
  |> list.filter(fn(x) { !string.is_empty(x) })
  |> list.map(parse_bank)
}

fn parse_bank(bank: String) -> List(Int) {
  string.to_graphemes(bank)
  |> list.map(fn(c) {
    let assert Ok(c) = int.parse(c)
    c
  })
}

fn part_one(banks: List(List(Int))) -> Int {
  banks
  |> list.map(max_two_digit_bank_joltage)
  |> int.sum
}

fn max_two_digit_bank_joltage(bank: List(Int)) -> Int {
  let assert [current_major, ..bank_minus_one] = bank
  let assert [current_minor, ..bank_minus_two] = bank_minus_one
  max_two_digit_bank_joltage_loop(
    current_major,
    current_minor,
    current_minor,
    bank_minus_two,
  )
}

fn max_two_digit_bank_joltage_loop(
  current_major: Int,
  current_minor: Int,
  major_candidate: Int,
  rest: List(Int),
) -> Int {
  case rest {
    [] -> current_major * 10 + current_minor
    [minor_candidate, ..next_rest] -> {
      case Nil {
        _ if major_candidate > current_major -> {
          max_two_digit_bank_joltage_loop(
            major_candidate,
            minor_candidate,
            minor_candidate,
            next_rest,
          )
        }
        _ if minor_candidate > current_minor -> {
          max_two_digit_bank_joltage_loop(
            current_major,
            minor_candidate,
            minor_candidate,
            next_rest,
          )
        }
        _ -> {
          max_two_digit_bank_joltage_loop(
            current_major,
            current_minor,
            minor_candidate,
            next_rest,
          )
        }
      }
    }
  }
}

fn part_two(banks: List(List(Int))) -> Int {
  banks
  |> list.map(max_var_digit_bank_joltage(_, 12))
  |> int.sum
}

fn max_var_digit_bank_joltage(bank: List(Int), digits: Int) -> Int {
  assert list.length(bank) >= digits
  let starting_digits = list.take(bank, digits)
  let assert [_, ..rest] = bank
  max_var_digit_bank_joltage_loop(digits, starting_digits, rest)
}

fn max_var_digit_bank_joltage_loop(
  digits: Int,
  current_digits: List(Int),
  rest_digits: List(Int),
) -> Int {
  let candidates = list.take(rest_digits, digits)
  case list.length(candidates) {
    len if len < digits -> digit_list_to_value(current_digits)
    _ -> {
      let new_digits = produce_new_bank_shift_max(current_digits, candidates)
      let assert [_, ..new_rest] = rest_digits
      max_var_digit_bank_joltage_loop(digits, new_digits, new_rest)
    }
  }
}

fn produce_new_bank_shift_max(
  current: List(Int),
  candidates: List(Int),
) -> List(Int) {
  case current, candidates {
    [curr_left, ..curr_rest], [cand_left, ..cand_rest] -> {
      case curr_left < cand_left {
        True -> candidates
        False -> [curr_left, ..produce_new_bank_shift_max(curr_rest, cand_rest)]
      }
    }
    _, _ -> []
  }
}

fn digit_list_to_value(digits: List(Int)) -> Int {
  list.fold(digits, 0, fn(acc, digit) { acc * 10 + digit })
}
