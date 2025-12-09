import gleam/int

pub type Tile {
  Tile(x: Int, y: Int)
}

pub fn area(tile: Tile, opposite_corner: Tile) -> Int {
  { int.absolute_value(tile.x - opposite_corner.x) + 1 }
  * { int.absolute_value(tile.y - opposite_corner.y) + 1 }
}
