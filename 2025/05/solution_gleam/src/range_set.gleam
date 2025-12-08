import range.{type Range}

pub opaque type RangeSet {
  Node(range: Range, left: RangeSet, right: RangeSet, size: Int)
  Empty
}

pub fn new() -> RangeSet {
  Empty
}

pub fn add(set: RangeSet, range: Range) -> RangeSet {
  case set {
    Empty -> Node(range:, left: Empty, right: Empty, size: range.size(range))
    Node(..) as node -> {
      let #(new_range, new_left, new_right) = case
        range.merge(range, node.range)
      {
        Ok(merged) -> #(
          merged,
          trim_max_end(node.left, range.start_of(merged)),
          trim_min_start(node.right, range.end_of(merged)),
        )
        Error(range.LeftOfRange) -> #(
          node.range,
          case node.left {
            Empty ->
              Node(range:, left: Empty, right: Empty, size: range.size(range))
            Node(..) as left -> add(left, range)
          },
          node.right,
        )
        Error(range.RightOfRange) -> #(node.range, node.left, case node.right {
          Empty ->
            Node(range:, left: Empty, right: Empty, size: range.size(range))
          Node(..) as right -> add(right, range)
        })
      }
      Node(
        range: new_range,
        left: new_left,
        right: new_right,
        size: range.size(new_range) + size(new_left) + size(new_right),
      )
    }
  }
}

fn trim_max_end(set: RangeSet, max_end: Int) -> RangeSet {
  case set {
    Empty -> Empty
    Node(..) as node -> {
      let eliminated = max_end <= range.start_of(node.range)
      let split = max_end < range.end_of(node.range)
      case Nil {
        _ if eliminated -> {
          trim_max_end(node.left, max_end)
        }
        _ if split -> {
          let new_range = range.new(range.start_of(node.range), max_end)
          Node(
            range: new_range,
            left: node.left,
            right: Empty,
            size: range.size(new_range) + size(node.left),
          )
        }
        _ -> {
          let new_right = trim_max_end(node.right, max_end)
          Node(
            range: node.range,
            left: node.left,
            right: new_right,
            size: range.size(node.range) + size(node.left) + size(new_right),
          )
        }
      }
    }
  }
}

fn trim_min_start(set: RangeSet, min_start: Int) -> RangeSet {
  case set {
    Empty -> Empty
    Node(..) as node -> {
      let eliminated = range.end_of(node.range) <= min_start
      let split = range.start_of(node.range) < min_start
      case Nil {
        _ if eliminated -> {
          trim_min_start(node.right, min_start)
        }
        _ if split -> {
          let new_range = range.new(min_start, range.end_of(node.range))
          Node(
            range: new_range,
            left: Empty,
            right: node.right,
            size: range.size(new_range) + size(node.right),
          )
        }
        _ -> {
          let new_left = trim_min_start(node.left, min_start)
          Node(
            range: node.range,
            left: new_left,
            right: node.right,
            size: range.size(node.range) + size(new_left) + size(node.right),
          )
        }
      }
    }
  }
}

pub fn contains(set: RangeSet, value: Int) -> Bool {
  case set {
    Empty -> False
    Node(..) as node -> {
      case range.contains(set.range, value) {
        Ok(Nil) -> True
        Error(range.LeftOfRange) ->
          case node.left {
            Node(..) as left -> contains(left, value)
            Empty -> False
          }
        Error(range.RightOfRange) ->
          case node.right {
            Node(..) as right -> contains(right, value)
            Empty -> False
          }
      }
    }
  }
}

pub fn size(set: RangeSet) -> Int {
  case set {
    Empty -> 0
    Node(..) as node -> node.size
  }
}
