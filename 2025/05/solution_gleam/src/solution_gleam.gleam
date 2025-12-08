import gleam/int
import gleam/io
import gleam/list
import gleam/string
import range.{type Range}
import range_set.{type RangeSet}
import simplifile

pub fn main() -> Nil {
  let #(ranges, ids) = parse_input("../input")
  let range_set = list.fold(ranges, range_set.new(), range_set.add)
  io.println("part one: " <> int.to_string(part_one(range_set, ids)))
  io.println("part two: " <> int.to_string(part_two(range_set)))
}

fn parse_input(input_path: String) -> #(List(Range), List(Int)) {
  let assert Ok(input) = simplifile.read(input_path)
  let assert [range_rows, id_rows] = string.split(input, "\n\n")
  let ranges =
    range_rows
    |> string.split("\n")
    |> list.filter(fn(x) { !string.is_empty(x) })
    |> list.map(parse_range_row)
  let ids =
    id_rows
    |> string.split("\n")
    |> list.filter(fn(x) { !string.is_empty(x) })
    |> list.map(parse_id_row)
  #(ranges, ids)
}

fn parse_range_row(row: String) -> Range {
  let assert [left, right] = string.split(row, "-")
  let assert Ok(start) = int.parse(left)
  let assert Ok(end_inclusive) = int.parse(right)
  range.new(start:, end_exclusive: end_inclusive + 1)
}

fn parse_id_row(row: String) -> Int {
  let assert Ok(id) = int.parse(row)
  id
}

fn part_one(range_set: RangeSet, ids: List(Int)) -> Int {
  ids
  |> list.filter(range_set.contains(range_set, _))
  |> list.length
}

fn part_two(range_set: RangeSet) -> Int {
  range_set.size(range_set)
}
