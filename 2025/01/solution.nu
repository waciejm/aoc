#!/usr/bin/env nu

def main [input: path] {
  let moves = parse_moves $input
  {
    "part one": ( $moves | count_clicks_part_one )
    "part two": ( $moves | count_clicks_part_two )
  }
}

def parse_moves [input: path]: nothing -> list<int> {
  open $input
    | split row "\n"
    | where { $in != "" }
    | each {{
      left: ( $in | parse "L{left}" | $in.left?.0? )
      right: ( $in | parse "R{right}" | $in.right?.0? )
    }}
    | each { if $in.left? != null { -( $in.left ) } else { $in.right } }
    | each { into int }
}

def count_clicks_part_one []: list<int> -> int {
  reduce --fold { pos: 50 clicks: 0 } { |move, acc|
    let new_pos = ( $acc.pos + $move ) mod 100
    let clicked = $new_pos == 0
    let new_clicks = $acc.clicks + ( if $clicked { 1 } else { 0 } )
    {
      pos: $new_pos
      clicks: $new_clicks
    }
  }
    | get clicks
}

def count_clicks_part_two []: list<int> -> int {
  reduce --fold { pos: 50 clicks: 0 } { |move, acc|
    let hundo_clicks = $move | math abs | $in // 100;
    let rem_move = if $move < 0 { $move mod -100 } else { $move mod 100 };
    let rem_clicked = ( $acc.pos > 0 and $acc.pos + $rem_move <= 0 ) or ( $acc.pos + $rem_move >= 100 );
    {
      pos: ( ( $acc.pos + $move ) mod 100 )
      clicks: ( $acc.clicks + $hundo_clicks + ( if $rem_clicked { 1 } else { 0 } ) )
    }
  }
    | get clicks
}
