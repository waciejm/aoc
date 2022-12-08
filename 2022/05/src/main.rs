use std::{
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    let stacks_info = input
        .lines()
        .take_while(|l| !l.is_empty())
        .collect::<Vec<_>>();

    let columns = count_columns(stacks_info.last().unwrap());

    let mut stacks = Stacks::new(columns);
    for i in (0..stacks_info.len() - 1).rev() {
        stacks.push_row(stacks_info[i]);
    }

    let moves = input
        .lines()
        .skip_while(|l| !l.starts_with("m"))
        .map(Movement::from_line);

    let mut s = stacks.clone();

    for m in moves {
        s.movement(&m);
    }

    println!("Part 1");
    print!("Stack tops: ");
    s.print_top();
    println!();

    let moves = input
        .lines()
        .skip_while(|l| !l.starts_with("m"))
        .map(Movement::from_line);

    for m in moves {
        stacks.movement_9001(&m);
    }

    println!("Part 2");
    print!("Stack tops: ");
    stacks.print_top();
    println!();

    Ok(())
}

fn count_columns(line: &str) -> usize {
    let len = line.len();
    ((len - 3) / 4) + 1
}

#[derive(Clone)]
struct Stacks {
    pub stacks: Vec<Vec<char>>,
    pub buffer: Vec<char>,
}

impl Stacks {
    pub fn new(size: usize) -> Self {
        let mut stacks = Vec::new();
        for _ in 0..size {
            stacks.push(Vec::new());
        }
        Self {
            stacks,
            buffer: Vec::new(),
        }
    }

    pub fn push_row(&mut self, row: &str) {
        for (c, index) in row.chars().skip(1).step_by(4).zip(0..) {
            match c {
                'A'..='Z' => self.stacks[index].push(c),
                _ => (),
            }
        }
    }

    pub fn movement(&mut self, movement: &Movement) {
        for _ in 0..movement.repeats {
            if let Some(x) = self.stacks[movement.from - 1].pop() {
                self.stacks[movement.to - 1].push(x);
            }
        }
    }

    pub fn movement_9001(&mut self, movement: &Movement) {
        for _ in 0..movement.repeats {
            if let Some(x) = self.stacks[movement.from - 1].pop() {
                self.buffer.push(x);
            }
        }
        for _ in 0..movement.repeats {
            if let Some(x) = self.buffer.pop() {
                self.stacks[movement.to - 1].push(x);
            }
        }
    }

    pub fn print_top(&self) {
        for stack in &self.stacks {
            print!("{}", stack.last().unwrap_or(&' '));
        }
    }
}

struct Movement {
    pub repeats: usize,
    pub from: usize,
    pub to: usize,
}

impl Movement {
    pub fn from_line(line: &str) -> Self {
        let mut words = line.split(' ');
        words.next();
        let repeats = words.next().unwrap().parse::<usize>().unwrap();
        words.next();
        let from = words.next().unwrap().parse::<usize>().unwrap();
        words.next();
        let to = words.next().unwrap().parse::<usize>().unwrap();
        Self { repeats, from, to }
    }
}
