use std::{
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    // Part 1
    println!("Part 1");
    let score = input
        .lines()
        .map(|line| {
            Rucksack::new(line)
                .find_match_in_compartments()
                .expect("Every line has a match")
                .priority()
        })
        .sum::<u64>();
    println!("Sum of priorities of matches: {score}");
    println!();

    // Part 2
    println!("Part 2");
    let mut score = 0;
    let mut rucksacks = input.lines().map(Rucksack::new);
    while let (Some(fst), Some(snd), Some(trd)) =
        (rucksacks.next(), rucksacks.next(), rucksacks.next())
    {
        score += Rucksack::find_match_in_group(&fst, &snd, &trd)
            .expect("Every group has a common item")
            .priority();
    }
    println!("Sum of priorities of group badges: {score}");
    println!();

    Ok(())
}

trait Item {
    fn priority(&self) -> u64;
    fn from_priority(priority: u64) -> Self;
}

impl Item for char {
    fn priority(&self) -> u64 {
        match self {
            x if x.is_ascii_lowercase() => *x as u8 - 'a' as u8 + 1,
            x if x.is_ascii_uppercase() => *x as u8 - 'A' as u8 + 27,
            x => panic!("Invalid item: {x}"),
        }
        .into()
    }

    fn from_priority(priority: u64) -> Self {
        match priority {
            0 => panic!("Priority out of range: {priority}"),
            1..=26 => ('a' as u64 + priority - 1) as u8 as char,
            27..=52 => ('A' as u64 + priority - 27) as u8 as char,
            _ => panic!("Priority out of range: {priority}"),
        }
    }
}

struct Compartment {
    pub items: [bool; 52],
}

impl Compartment {
    pub fn new() -> Self {
        Self { items: [false; 52] }
    }

    pub fn put(&mut self, item: char) {
        self.items[item.priority() as usize - 1] = true;
    }

    pub fn check(&self, item: char) -> bool {
        self.items[item.priority() as usize - 1]
    }
}

#[derive(Debug)]
struct Rucksack<'a> {
    items: &'a str,
}

impl<'a> Rucksack<'a> {
    pub fn new(items: &'a str) -> Self {
        assert!(items.is_ascii());
        assert!(items.len() % 2 == 0);
        Self { items }
    }

    pub fn find_match_in_compartments(&self) -> Option<char> {
        let half = self.items.len() / 2;
        let left = self.items.chars().take(half);
        let right = self.items.chars().skip(half);
        let mut left_compartment = Compartment::new();
        for item in left {
            left_compartment.put(item);
        }
        for item in right {
            if left_compartment.check(item) {
                return Some(item);
            }
        }
        None
    }

    pub fn find_match_in_group(fst: &Self, snd: &Self, trd: &Self) -> Option<char> {
        let mut matches = [0; 52];
        {
            let mut compartment = Compartment::new();
            for item in fst.items.chars() {
                compartment.put(item);
            }
            for c in 'a'..='z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
            for c in 'A'..='Z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
        }
        {
            let mut compartment = Compartment::new();
            for item in snd.items.chars() {
                compartment.put(item);
            }
            for c in 'a'..='z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
            for c in 'A'..='Z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
        }
        {
            let mut compartment = Compartment::new();
            for item in trd.items.chars() {
                compartment.put(item);
            }
            for c in 'a'..='z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
            for c in 'A'..='Z' {
                if compartment.check(c) {
                    matches[c.priority() as usize - 1] += 1;
                }
            }
        }
        for i in 0..matches.len() {
            if matches[i] == 3 {
                return Some(char::from_priority(i as u64 + 1));
            }
        }
        None
    }
}

#[cfg(test)]
mod test {
    use crate::{Item, Rucksack};

    #[test]
    fn test_priority() {
        assert!('p'.priority() == 16);
        assert!('L'.priority() == 38);
        assert!('P'.priority() == 42);
        assert!('v'.priority() == 22);
        assert!('t'.priority() == 20);
        assert!('s'.priority() == 19);
        assert!('Z'.priority() == 52);
    }

    #[test]
    fn test_from_priority() {
        assert!(char::from_priority(16) == 'p');
        assert!(char::from_priority(38) == 'L');
        assert!(char::from_priority(42) == 'P');
        assert!(char::from_priority(22) == 'v');
        assert!(char::from_priority(20) == 't');
        assert!(char::from_priority(19) == 's');
        assert!(char::from_priority(52) == 'Z');
    }

    #[test]
    fn test_find_match_in_group() {
        let fst = Rucksack::new("qpwerq");
        let snd = Rucksack::new("aspdfa");
        let trd = Rucksack::new("zxcpvz");
        let m = Rucksack::find_match_in_group(&fst, &snd, &trd);
        assert_eq!(m, Some('p'));

        let fst = Rucksack::new("qZwerq");
        let snd = Rucksack::new("asZdfa");
        let trd = Rucksack::new("zxcZvz");
        let m = Rucksack::find_match_in_group(&fst, &snd, &trd);
        assert_eq!(m, Some('Z'));
    }
}
