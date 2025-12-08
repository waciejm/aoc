import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() -> Nil {
  let board = parse_input("../input")
  io.println("part one: " <> int.to_string(part_one(board)))
  io.println("part two: " <> int.to_string(part_two(board)))
}

type Board {
  Board(start: Int, splitters: List(Set(Int)))
}

fn parse_input(input_path: String) -> Board {
  let assert Ok(input) = simplifile.read(input_path)
  let assert [start_row, ..splitter_rows] =
    input
    |> string.trim
    |> string.split("\n")
  let start = parse_start_row(start_row)
  let splitters =
    splitter_rows
    |> list.map(parse_splitter_row)
  Board(start:, splitters:)
}

fn parse_start_row(row: String) -> Int {
  let assert Ok(start) =
    row
    |> string.to_graphemes
    |> list.index_map(fn(char, index) { #(char, index) })
    |> list.find(fn(x) { x.0 == "S" })
  start.1
}

fn parse_splitter_row(row: String) -> Set(Int) {
  row
  |> string.to_graphemes
  |> list.index_map(fn(char, index) { #(char, index) })
  |> list.filter(fn(x) { x.0 == "^" })
  |> list.map(fn(x) { x.1 })
  |> set.from_list
}

fn part_one(board: Board) -> Int {
  board.splitters
  |> list.fold(#(set.new() |> set.insert(board.start), 0), step_with_splits)
  |> fn(x) { x.1 }
}

fn step_with_splits(
  input_beams_with_split_count: #(Set(Int), Int),
  splitters: Set(Int),
) -> #(Set(Int), Int) {
  let #(input_beams, split_count) = input_beams_with_split_count
  input_beams
  |> set.fold(#(set.new(), split_count), fn(acc, i) {
    case splitters |> set.contains(i) {
      True -> #(acc.0 |> set.insert(i - 1) |> set.insert(i + 1), acc.1 + 1)
      False -> #(acc.0 |> set.insert(i), acc.1)
    }
  })
}

fn part_two(board: Board) -> Int {
  board.splitters
  |> list.fold(dict.new() |> dict.insert(board.start, 1), quantum_step)
  |> dict.fold(0, fn(acc, _, timelines) { acc + timelines })
}

fn quantum_step(
  input_beams: Dict(Int, Int),
  splitters: Set(Int),
) -> Dict(Int, Int) {
  input_beams
  |> dict.fold(dict.new(), fn(acc, i, timelines) {
    case splitters |> set.contains(i) {
      True ->
        acc
        |> upsert_quantum_beam(i - 1, timelines)
        |> upsert_quantum_beam(i + 1, timelines)
      False -> acc |> upsert_quantum_beam(i, timelines)
    }
  })
}

fn upsert_quantum_beam(
  beams: Dict(Int, Int),
  position: Int,
  timelines: Int,
) -> Dict(Int, Int) {
  beams
  |> dict.upsert(position, fn(old) {
    case old {
      option.None -> timelines
      option.Some(old_timelines) -> old_timelines + timelines
    }
  })
}
