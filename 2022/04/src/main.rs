use std::{
    error::Error,
    io::{stdin, Read},
    ops::RangeInclusive,
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    // Part 1
    println!("Part 1");
    let pairs = parse_assignments(&input)?;
    let count = pairs
        .iter()
        .filter(|pair| pair.left.contains(&pair.right) || pair.right.contains(&pair.left))
        .count();
    println!("Number of assignment pairs containing one in other: {count}");
    println!();

    // Part 2
    println!("Part 2");
    let pairs = parse_assignments(&input)?;
    let count = pairs
        .iter()
        .filter(|pair| pair.left.overlaps(&pair.right))
        .count();
    println!("Number of assignment pairs containing one in other: {count}");
    println!();

    Ok(())
}

#[derive(Debug, PartialEq, Eq)]
struct Assignment {
    pub range: RangeInclusive<usize>,
}

impl Assignment {
    pub fn contains(&self, other: &Self) -> bool {
        self.range.start() <= other.range.start() && self.range.end() >= other.range.end()
    }
    pub fn overlaps(&self, other: &Self) -> bool {
        self.contains(other)
            || other.contains(self)
            || (self.range.start() <= other.range.start()
                && self.range.end() >= other.range.start())
            || (self.range.start() <= other.range.end() && self.range.end() >= other.range.end())
    }
}

#[derive(Debug, PartialEq, Eq)]
struct Pair {
    pub left: Assignment,
    pub right: Assignment,
}

fn parse_assignments(input: &str) -> Result<Vec<Pair>, Box<dyn Error>> {
    let mut pairs = Vec::new();
    for line in input.lines() {
        let mut first = None;
        let mut second = None;
        for assignment in line.split(',') {
            let mut parts = assignment.split('-');
            let left = parts.next().expect("Left part of x-x assignment").parse()?;
            let right = parts
                .next()
                .expect("Right part of x-x assignment")
                .parse()?;
            if first.is_none() {
                first = Some(Assignment {
                    range: left..=right,
                });
            } else {
                second = Some(Assignment {
                    range: left..=right,
                });
            }
        }
        match (first, second) {
            (Some(left), Some(right)) => {
                pairs.push(Pair { left, right });
            }
            _ => panic!("Expected left and right assignments"),
        }
    }
    Ok(pairs)
}
