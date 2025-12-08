import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let boxes = parse_input("../input")
  io.println("part one: " <> int.to_string(part_one(boxes)))
  io.println("part two: " <> int.to_string(part_two(boxes)))
}

type JunctionBox {
  JunctionBox(x: Int, y: Int, z: Int)
}

type Circuit {
  Circuit(id: Int, boxes: List(JunctionBox), size: Int)
}

type Connection =
  #(JunctionBox, JunctionBox)

fn parse_input(input_path: String) -> List(JunctionBox) {
  let assert Ok(input) = simplifile.read(input_path)
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_input_row)
}

fn parse_input_row(row: String) -> JunctionBox {
  let assert [xstr, ystr, zstr] =
    row
    |> string.split(",")
    as { "unexpected input row: " <> row }
  let assert Ok(x) = int.parse(xstr) as { "invalid xstr: " <> xstr }
  let assert Ok(y) = int.parse(ystr) as { "invalid ystr: " <> ystr }
  let assert Ok(z) = int.parse(zstr) as { "invalid zstr: " <> zstr }
  JunctionBox(x:, y:, z:)
}

fn part_one(boxes: List(JunctionBox)) -> Int {
  let shortest_1000_connections =
    get_sorted_connections(boxes)
    |> list.take(1000)

  let box_to_circuit_init = create_box_to_circuit_map(boxes)

  let circuits_after_shortest_1000 =
    shortest_1000_connections
    |> list.fold(box_to_circuit_init, fn(box_to_circuit, connection) {
      case connect(box_to_circuit, connection) {
        Error(Nil) -> box_to_circuit
        Ok(new_circuit) -> update_box_to_circuit(box_to_circuit, new_circuit)
      }
    })

  circuits_after_shortest_1000
  |> dict.values
  |> list.map(fn(c) { #(c.id, c.size) })
  |> list.unique
  |> list.sort(fn(l, r) { int.compare(l.1, r.1) })
  |> list.reverse
  |> list.take(3)
  |> list.map(fn(c) { c.1 })
  |> int.product
}

fn part_two(boxes: List(JunctionBox)) {
  let sorted_connections = get_sorted_connections(boxes)
  let last_connection = connect_until_complete(boxes, sorted_connections)
  { last_connection.0 }.x * { last_connection.1 }.x
}

fn connect_until_complete(
  boxes: List(JunctionBox),
  connections: List(Connection),
) -> Connection {
  let box_to_circuit_init = create_box_to_circuit_map(boxes)
  connect_until_complete_loop(box_to_circuit_init, connections)
}

fn connect_until_complete_loop(
  box_to_circuit: dict.Dict(JunctionBox, Circuit),
  connections_left: List(Connection),
) -> Connection {
  case connections_left {
    [] -> panic as "ran out of connections before completing circuit"
    [connection, ..connections_rest] -> {
      case connect(box_to_circuit, connection) {
        Error(Nil) ->
          connect_until_complete_loop(box_to_circuit, connections_rest)
        Ok(new_circuit) ->
          case new_circuit.size == dict.size(box_to_circuit) {
            True -> connection
            False ->
              connect_until_complete_loop(
                update_box_to_circuit(box_to_circuit, new_circuit),
                connections_rest,
              )
          }
      }
    }
  }
}

fn get_sorted_connections(boxes: List(JunctionBox)) -> List(Connection) {
  boxes
  |> list.combination_pairs
  |> list.map(fn(p) { #(p, distance(p.0, p.1)) })
  |> list.sort(by: fn(l, r) { float.compare(l.1, r.1) })
  |> list.map(fn(pd) { pd.0 })
}

fn create_box_to_circuit_map(
  boxes: List(JunctionBox),
) -> dict.Dict(JunctionBox, Circuit) {
  boxes
  |> list.index_map(fn(box, index) {
    #(box, Circuit(id: index, boxes: [box], size: 1))
  })
  |> dict.from_list
}

fn connect(
  box_to_circuit: dict.Dict(JunctionBox, Circuit),
  connection: Connection,
) -> Result(Circuit, Nil) {
  let assert Ok(left_circuit) = dict.get(box_to_circuit, connection.0)
  let assert Ok(right_circuit) = dict.get(box_to_circuit, connection.1)
  case left_circuit.id == right_circuit.id {
    True -> Error(Nil)
    False -> {
      let joined_boxes = list.append(left_circuit.boxes, right_circuit.boxes)
      Ok(Circuit(
        id: left_circuit.id,
        boxes: joined_boxes,
        size: left_circuit.size + right_circuit.size,
      ))
    }
  }
}

fn update_box_to_circuit(
  box_to_circuit: dict.Dict(JunctionBox, Circuit),
  new_circuit: Circuit,
) -> dict.Dict(JunctionBox, Circuit) {
  new_circuit.boxes
  |> list.fold(box_to_circuit, fn(btc, box) {
    dict.insert(btc, box, new_circuit)
  })
}

fn distance(left: JunctionBox, right: JunctionBox) -> Float {
  let dx = int.to_float(left.x - right.x)
  let dy = int.to_float(left.y - right.y)
  let dz = int.to_float(left.z - right.z)
  let assert Ok(distance) =
    { dx *. dx } +. { dy *. dy } +. { dz *. dz }
    |> float.square_root
  distance
}
