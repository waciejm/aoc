import gleam/int

pub opaque type Range {
  // start <= end, end is exclusive
  Range(start: Int, end: Int)
}

pub type RangeDirection {
  LeftOfRange
  RightOfRange
}

pub fn new(start start: Int, end_exclusive end: Int) -> Range {
  // no empty ranges !!1
  assert start < end
  Range(start:, end:)
}

pub fn start_of(range: Range) -> Int {
  range.start
}

pub fn end_of(range: Range) -> Int {
  range.end
}

pub fn is_empty(range: Range) -> Bool {
  range.start == range.end
}

pub fn contains(range: Range, value: Int) -> Result(Nil, RangeDirection) {
  case range.start <= value && value < range.end {
    True -> Ok(Nil)
    False if value < range.start -> Error(LeftOfRange)
    False -> Error(RightOfRange)
  }
}

pub fn size(range: Range) -> Int {
  range.end - range.start
}

pub fn merge(range: Range, with other: Range) -> Result(Range, RangeDirection) {
  case
    range.start <= other.start && range.end < other.start,
    other.start < range.start && other.end < range.start
  {
    True, False -> Error(LeftOfRange)
    False, True -> Error(RightOfRange)
    False, False ->
      Ok(Range(
        start: int.min(range.start, other.start),
        end: int.max(range.end, other.end),
      ))
    True, True -> panic as "unreachable"
  }
}
