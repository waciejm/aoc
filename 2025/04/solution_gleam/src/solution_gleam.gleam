import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let board = parse_input("../input")
  io.println("part one: " <> int.to_string(part_one(board)))
  io.println("part two: " <> int.to_string(part_two(board)))
}

// parsed board has an empty row and column added on every side
fn parse_input(input_path: String) -> List(List(Bool)) {
  let assert Ok(input) = simplifile.read(input_path)
  let real_rows =
    input
    |> string.split("\n")
    |> list.filter(fn(x) { !string.is_empty(x) })
    |> list.map(parse_row)
  let assert [first_row, ..] = real_rows
  let row_len = list.length(first_row)
  let empty_row = list.repeat(False, row_len)
  real_rows
  |> list.append([empty_row])
  |> list.prepend(empty_row)
}

// parsed row has an empty field added at start and end
fn parse_row(row: String) -> List(Bool) {
  string.to_graphemes(row)
  |> list.map(fn(c) {
    case c {
      "." -> False
      "@" -> True
      _ -> panic as { "invalid field in input: " <> c }
    }
  })
  |> list.append([False])
  |> list.prepend(False)
}

fn part_one(board: List(List(Bool))) -> Int {
  let simple = count_accessible_on_board(board)
  let reuse_part_two =
    find_accessible_on_board(board)
    |> count_removable_mask
  assert simple == reuse_part_two
  simple
}

// assumes first and last rows are empty
fn count_accessible_on_board(board: List(List(Bool))) -> Int {
  assert list.length(board) >= 2
  count_accessible_on_board_loop(board, 0)
}

fn count_accessible_on_board_loop(rest: List(List(Bool)), acc: Int) -> Int {
  case rest {
    [prev, current, next, ..] -> {
      let assert [_, ..next_rest] = rest
      count_accessible_on_board_loop(
        next_rest,
        acc + count_accessible_in_row(prev, current, next),
      )
    }
    [_, _] -> acc
    _ -> panic as "unreachable"
  }
}

// assumes current row has empty fields at start and end
fn count_accessible_in_row(
  prev: List(Bool),
  current: List(Bool),
  next: List(Bool),
) -> Int {
  assert list.length(prev) >= 2
  assert list.length(prev) == list.length(current)
  assert list.length(prev) == list.length(next)
  count_accessible_in_row_loop(prev, current, next, 0)
}

fn count_accessible_in_row_loop(
  prev: List(Bool),
  current: List(Bool),
  next: List(Bool),
  acc: Int,
) -> Int {
  case prev, current, next {
    [p1, p2, p3, ..], [c1, c2, c3, ..], [n1, n2, n3, ..] -> {
      let accessible =
        c2
        && {
          let neighbors =
            [p1, p2, p3, c1, c3, n1, n2, n3]
            |> list.fold(0, fn(sum, b) {
              case b {
                True -> sum + 1
                False -> sum
              }
            })
          neighbors < 4
        }
      let assert [_, ..next_prev] = prev
      let assert [_, ..next_current] = current
      let assert [_, ..next_next] = next
      count_accessible_in_row_loop(
        next_prev,
        next_current,
        next_next,
        case accessible {
          True -> acc + 1
          False -> acc
        },
      )
    }
    [_, _], [_, _], [_, _] -> acc
    _, _, _ -> panic as "unreachable"
  }
}

fn part_two(board: List(List(Bool))) -> Int {
  part_two_loop(board, 0)
}

fn part_two_loop(board: List(List(Bool)), removed: Int) -> Int {
  let removable = find_accessible_on_board(board)
  let removable_count = count_removable_mask(removable)
  assert removable_count >= 0
  case removable_count {
    0 -> removed
    _ -> {
      let new_board = apply_removable_mask(board, removable)
      part_two_loop(new_board, removed + removable_count)
    }
  }
}

// assumes first and last rows are empty
fn find_accessible_on_board(board: List(List(Bool))) -> List(List(Bool)) {
  assert list.length(board) >= 2
  let removable_rows = find_accessible_on_board_loop(board, [])
  let assert [first_row, ..] = board
  let row_size = list.length(first_row)
  [
    list.repeat(False, row_size),
    ..list.reverse([list.repeat(False, row_size), ..removable_rows])
  ]
}

fn find_accessible_on_board_loop(
  rest: List(List(Bool)),
  acc: List(List(Bool)),
) -> List(List(Bool)) {
  case rest {
    [prev, current, next, ..] -> {
      let assert [_, ..next_rest] = rest
      find_accessible_on_board_loop(next_rest, [
        find_accessible_in_row(prev, current, next),
        ..acc
      ])
    }
    [_, _] -> acc
    _ -> panic as "unreachable"
  }
}

// assumes current row has empty fields at start and end
fn find_accessible_in_row(
  prev: List(Bool),
  current: List(Bool),
  next: List(Bool),
) -> List(Bool) {
  assert list.length(prev) >= 2
  assert list.length(prev) == list.length(current)
  assert list.length(prev) == list.length(next)
  let removable = find_accessible_in_row_loop(prev, current, next, [])
  [False, ..list.reverse([False, ..removable])]
}

fn find_accessible_in_row_loop(
  prev: List(Bool),
  current: List(Bool),
  next: List(Bool),
  acc: List(Bool),
) -> List(Bool) {
  case prev, current, next {
    [p1, p2, p3, ..], [c1, c2, c3, ..], [n1, n2, n3, ..] -> {
      let accessible =
        c2
        && {
          let neighbors =
            [p1, p2, p3, c1, c3, n1, n2, n3]
            |> list.map(fn(b) {
              case b {
                True -> 1
                False -> 0
              }
            })
            |> int.sum
          neighbors < 4
        }
      let assert [_, ..next_prev] = prev
      let assert [_, ..next_current] = current
      let assert [_, ..next_next] = next
      find_accessible_in_row_loop(next_prev, next_current, next_next, [
        accessible,
        ..acc
      ])
    }
    [_, _], [_, _], [_, _] -> acc
    _, _, _ -> panic as "unreachable"
  }
}

fn count_removable_mask(mask: List(List(Bool))) -> Int {
  list.fold(mask, 0, fn(acc, row) {
    list.fold(row, acc, fn(row_acc, field) {
      case field {
        True -> row_acc + 1
        False -> row_acc
      }
    })
  })
}

fn apply_removable_mask(
  board: List(List(Bool)),
  mask: List(List(Bool)),
) -> List(List(Bool)) {
  list.map2(board, mask, fn(br, mr) {
    list.map2(br, mr, fn(b, m) { b && { !m } })
  })
}
