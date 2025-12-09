import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile
import tile.{type Tile}

pub fn main() -> Nil {
  let tiles = parse_input("../input")
  io.println("part one: " <> int.to_string(part_one(tiles)))
  io.println("part two: " <> int.to_string(part_two(tiles)))
}

fn parse_input(input_path: String) -> List(Tile) {
  let assert Ok(input) = simplifile.read(input_path)
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(row) {
    let assert [xstr, ystr] = string.split(row, ",")
    let assert Ok(x) = int.parse(xstr)
    let assert Ok(y) = int.parse(ystr)
    tile.Tile(x:, y:)
  })
}

fn part_one(tiles: List(Tile)) -> Int {
  let assert Ok(max) =
    tiles
    |> list.combination_pairs
    |> list.map(fn(tiles) { tile.area(tiles.0, tiles.1) })
    |> list.max(int.compare)
  max
}

fn part_two(tiles: List(Tile)) -> Int {
  todo
}
