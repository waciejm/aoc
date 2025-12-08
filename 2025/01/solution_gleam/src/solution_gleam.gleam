import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{type FileError}

pub type AOCResult {
  AOCResult(part_one: Int, part_two: Int)
}

pub fn main() -> Nil {
  let result =
    "../input"
    |> parse_input
    |> result.map(fn(actions) {
      let initial_state = RotateState(position: 50, clicks: 0)
      AOCResult(
        part_one: list.fold(actions, initial_state, step_part_one).clicks,
        part_two: list.fold(actions, initial_state, step_part_two).clicks,
      )
    })
  case result {
    Ok(success) -> {
      io.println("part one: " <> int.to_string(success.part_one))
      io.println("part two: " <> int.to_string(success.part_two))
    }
    Error(failure) -> {
      echo failure
      Nil
    }
  }
}

fn parse_input(input_path: String) -> Result(List(Int), FileError) {
  input_path
  |> simplifile.read
  |> result.map(fn(input) {
    input
    |> string.split("\n")
    |> list.filter_map(parse_action)
  })
}

fn parse_action(action: String) -> Result(Int, Nil) {
  use first <- result.try(string.first(action))
  case first {
    "L" -> {
      action
      |> string.drop_start(1)
      |> int.parse
      |> result.map(int.negate)
    }
    "R" -> {
      action
      |> string.drop_start(1)
      |> int.parse
    }
    _ -> {
      panic as { "unexpected action: " <> action }
    }
  }
}

type RotateState {
  RotateState(position: Int, clicks: Int)
}

fn step_part_one(state: RotateState, move: Int) -> RotateState {
  let assert Ok(position) = int.modulo(state.position + move, 100)
  RotateState(position:, clicks: case position {
    0 -> state.clicks + 1
    _ -> state.clicks
  })
}

fn step_part_two(state: RotateState, move: Int) -> RotateState {
  let full_spins = int.absolute_value(move) / 100
  let rem_spins = case move % 100 {
    rem if state.position > 0 && state.position + rem <= 0 -> 1
    rem if state.position + rem >= 100 -> 1
    _ -> 0
  }
  let assert Ok(position) = int.modulo(state.position + move, 100)
  RotateState(position:, clicks: state.clicks + full_spins + rem_spins)
}
