use std::{collections::HashMap, path::Path, rc::Rc};

fn main() {
    let boxes = parse_input("../input".as_ref());
    println!("part one: {}", part_one(&boxes));
    println!("part two: {}", part_two(&boxes));
}

fn parse_input(input_path: &Path) -> Vec<JunctionBox> {
    std::fs::read_to_string(input_path)
        .unwrap()
        .lines()
        .map(|line| {
            let mut coords = line.split(',');
            let x = coords.next().unwrap().parse().unwrap();
            let y = coords.next().unwrap().parse().unwrap();
            let z = coords.next().unwrap().parse().unwrap();
            JunctionBox { x, y, z }
        })
        .collect()
}

fn part_one(boxes: &[JunctionBox]) -> usize {
    let mut circuit_map = CircuitMap::new(boxes);

    let shortest_1000_connections = {
        let mut connections = circuit_map.all_possible_connections();
        connections.sort_unstable_by(|l, r| f64::total_cmp(&l.1, &r.1));
        connections.into_iter().map(|x| x.0).take(1000)
    };

    for c in shortest_1000_connections {
        circuit_map.connect(c);
    }

    let largest_3_circuits = {
        let mut uniq_circuit_sizes = {
            let mut hm = HashMap::<*const [usize], usize>::new();
            for c in circuit_map.circuits() {
                hm.insert(Rc::as_ptr(c), c.len());
            }
            hm.into_values().collect::<Vec<_>>()
        };
        uniq_circuit_sizes.sort_unstable();
        uniq_circuit_sizes.into_iter().rev().take(3)
    };

    largest_3_circuits.into_iter().product()
}

fn part_two(boxes: &[JunctionBox]) -> f64 {
    let mut circuit_map = CircuitMap::new(boxes);

    let mut sorted_connections = {
        let mut connections = circuit_map.all_possible_connections();
        connections.sort_unstable_by(|l, r| f64::total_cmp(&l.1, &r.1));
        connections.into_iter().map(|x| x.0)
    };

    loop {
        let connection = sorted_connections.next().unwrap();
        circuit_map.connect(connection);
        if circuit_map.is_complete() {
            let boxes = circuit_map.boxes(connection);
            return boxes.0.x * boxes.1.x;
        }
    }
}

#[derive(Debug, Clone)]
struct JunctionBox {
    x: f64,
    y: f64,
    z: f64,
}

impl JunctionBox {
    pub fn distance_squared(&self, other: &Self) -> f64 {
        let dx = self.x - other.x;
        let dy = self.y - other.y;
        let dz = self.z - other.z;
        dx * dx + dy * dy + dz * dz
    }
}

type Circuit = Rc<[usize]>;

type Connection = (usize, usize);

#[derive(Debug)]
struct CircuitMap<'a> {
    boxes: &'a [JunctionBox],
    circuits: Box<[Circuit]>,
}

impl<'a> CircuitMap<'a> {
    pub fn new(boxes: &'a [JunctionBox]) -> Self {
        let circuits = (0..boxes.len())
            .map(|i| Rc::from(Box::from([i])))
            .collect::<Vec<_>>();
        Self {
            boxes,
            circuits: circuits.into(),
        }
    }

    pub fn all_possible_connections(&self) -> Vec<(Connection, f64)> {
        RangeCombinationPairs::new(0, self.boxes.len())
            .map(|c| (c, self.connection_distance_squared(c)))
            .collect()
    }

    pub fn connection_distance_squared(&self, connection: Connection) -> f64 {
        self.boxes[connection.0].distance_squared(&self.boxes[connection.1])
    }

    pub fn connect(&mut self, connection: Connection) {
        let left_circuit = &self.circuits[connection.0];
        let right_circuit = &self.circuits[connection.1];
        if !Rc::ptr_eq(left_circuit, right_circuit) {
            let new_circuit = Rc::<[usize]>::from({
                let mut boxes = Vec::new();
                boxes.extend_from_slice(left_circuit);
                boxes.extend_from_slice(right_circuit);
                boxes
            });
            for i in new_circuit.iter() {
                self.circuits[*i] = Rc::clone(&new_circuit);
            }
        }
    }

    pub fn is_complete(&self) -> bool {
        if !self.boxes.is_empty() {
            self.circuits[0].len() == self.boxes.len()
        } else {
            true
        }
    }

    pub fn circuits(&self) -> &[Circuit] {
        &self.circuits
    }

    pub fn boxes(&self, connection: Connection) -> (&JunctionBox, &JunctionBox) {
        (&self.boxes[connection.0], &self.boxes[connection.1])
    }
}

struct RangeCombinationPairs {
    next_left: usize,
    next_right: usize,
    end: usize,
}

impl RangeCombinationPairs {
    pub fn new(start: usize, end: usize) -> Self {
        Self {
            next_left: start,
            next_right: start + 1,
            end,
        }
    }
}

impl Iterator for RangeCombinationPairs {
    type Item = (usize, usize);

    fn next(&mut self) -> Option<Self::Item> {
        let left = self.next_left;
        let right = self.next_right;
        if self.next_right + 1 < self.end {
            self.next_right += 1;
            Some((left, right))
        } else if self.next_left + 1 < self.end {
            self.next_left += 1;
            self.next_right = self.next_left + 1;
            Some((left, right))
        } else {
            None
        }
    }
}
