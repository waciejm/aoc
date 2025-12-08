#!/usr/bin/env nu

def main [input: path]: nothing -> record<"part one": int> {
  let ranges = parse_input $input
  {
    "part one": ( $ranges | count_invalid_part_one )
    "part two": ( $ranges | count_invalid_part_two )
  }
}

def count_invalid_part_one []: table<start: int, end: int> -> int {
  "\n--- part one ---\n" | print
  $in
    | reduce --fold 0 { |range, sum|
      let range_sum = ( $range.start )..( $range.end )
        | reduce --fold 0 { |id, range_sum|
          let id_str = $id | into string
          let id_len = $id_str | str length
          let id_invalid = if $id_len mod 2 == 1 {
            false
          } else {
            let left_half = $id_str | str substring 0..<( $id_len // 2 );
            let right_half = $id_str | str substring ( $id_len // 2 )..<( $id_len );
            if $left_half != $right_half {
              false
            } else {
              true
            }
          }
          if $id_invalid {
            $id | print
            $range_sum + $id
          } else {
            $range_sum
          }
        }
      $sum + $range_sum
    }
}

def count_invalid_part_two []: table<start: int, end: int> -> int {
  "\n--- part two ---\n" | print
  $in
    | reduce --fold 0 { |range, sum|
      let range_sum = ( $range.start )..( $range.end )
        | reduce --fold 0 { |id, range_sum|
          let id_str = $id | into string
          let id_len = $id_str | str length
          let id_invalid = $id_len > 1 and (
            1..( $id_len // 2 )
              | reduce --fold false { |rep_len, invalid|
                $invalid or (
                  if $id_len mod $rep_len != 0 {
                    false
                  } else {
                    let reps = $id_len // $rep_len
                    let first_rep = $id_str | str substring 0..<( $rep_len )
                    1..<( $reps )
                      | each { |rep_i|
                        $id_str | str substring ( $rep_len * $rep_i )..<( $rep_len * ( $rep_i + 1 ) )
                      }
                      | all { |other_rep| $other_rep == $first_rep }
                  }
                )
              }
            )
          if $id_invalid {
            $id | print
            $range_sum + $id
          } else {
            $range_sum
          }
        }
      $sum + $range_sum
    }
}

def parse_input [input: path]: nothing -> table<start: int, end: int> {
  open $input
    | split row ","
    | parse "{start}-{end}"
    | each {
      {
        start: ( $in.start | into int )
        end: ( $in.end | into int )
      }
    }
    | inspect
}
