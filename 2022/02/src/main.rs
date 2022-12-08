use std::{
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;
    // part 1
    println!("Part 1");
    let rounds = load_rounds_from_str(&input, interpret_oponent_you)?;
    let score = rounds.iter().fold(0, |acc, round| acc + round.score());
    println!("Score: {score}");
    println!();

    // part 2
    println!("Part 2");
    let rounds = load_rounds_from_str(&input, interpret_oponent_outcome)?;
    let score = rounds.iter().fold(0, |acc, round| acc + round.score());
    println!("Score: {score}");
    println!();

    Ok(())
}

#[derive(Debug, PartialEq, Eq)]
pub enum Play {
    Rock,
    Paper,
    Scissors,
}

impl Play {
    pub fn value(&self) -> u64 {
        match self {
            Self::Rock => 1,
            Self::Paper => 2,
            Self::Scissors => 3,
        }
    }
}

impl TryFrom<&str> for Play {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "A" | "X" => Ok(Self::Rock),
            "B" | "Y" => Ok(Self::Paper),
            "C" | "Z" => Ok(Self::Scissors),
            _ => Err(format!("Invalid play: {value}")),
        }
    }
}

pub enum Outcome {
    Victory,
    Draw,
    Defeat,
}

impl Outcome {
    pub fn value(&self) -> u64 {
        match self {
            Self::Victory => 6,
            Self::Draw => 3,
            Self::Defeat => 0,
        }
    }
}

impl TryFrom<&str> for Outcome {
    type Error = String;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "X" => Ok(Self::Defeat),
            "Y" => Ok(Self::Draw),
            "Z" => Ok(Self::Victory),
            _ => Err(format!("Invalid outcome: {value}")),
        }
    }
}

impl From<&Round> for Outcome {
    fn from(value: &Round) -> Self {
        match (&value.oponent, &value.you) {
            (Play::Rock, Play::Scissors)
            | (Play::Paper, Play::Rock)
            | (Play::Scissors, Play::Paper) => Self::Defeat,
            (Play::Rock, Play::Rock)
            | (Play::Paper, Play::Paper)
            | (Play::Scissors, Play::Scissors) => Self::Draw,
            (Play::Rock, Play::Paper)
            | (Play::Paper, Play::Scissors)
            | (Play::Scissors, Play::Rock) => Self::Victory,
        }
    }
}

pub struct Round {
    pub oponent: Play,
    pub you: Play,
}

impl Round {
    pub fn score(&self) -> u64 {
        let pick = self.you.value();
        let outcome = Outcome::from(self).value();
        pick + outcome
    }
}

fn load_rounds_from_str(
    input: &str,
    interpret_fn: impl Fn(&str, &str) -> Result<Round, Box<dyn Error>>,
) -> Result<Vec<Round>, Box<dyn Error>> {
    let mut rounds = Vec::new();

    for line in input.lines() {
        let mut words = line.split_ascii_whitespace();
        let round = match (words.next(), words.next()) {
            (Some(a), Some(b)) => interpret_fn(a, b),
            _ => Err(String::from("Found less than 2 words on each line").into()),
        }?;
        rounds.push(round);
    }

    Ok(rounds)
}

fn interpret_oponent_you(a: &str, b: &str) -> Result<Round, Box<dyn Error>> {
    Ok(Round {
        oponent: a.try_into()?,
        you: b.try_into()?,
    })
}

fn interpret_oponent_outcome(a: &str, b: &str) -> Result<Round, Box<dyn Error>> {
    let oponent = Play::try_from(a)?;
    let outcome = Outcome::try_from(b)?;
    let you = match (&oponent, &outcome) {
        (Play::Rock, Outcome::Victory)
        | (Play::Paper, Outcome::Draw)
        | (Play::Scissors, Outcome::Defeat) => Play::Paper,
        (Play::Paper, Outcome::Victory)
        | (Play::Scissors, Outcome::Draw)
        | (Play::Rock, Outcome::Defeat) => Play::Scissors,
        (Play::Scissors, Outcome::Victory)
        | (Play::Rock, Outcome::Draw)
        | (Play::Paper, Outcome::Defeat) => Play::Rock,
    };
    Ok(Round { oponent, you })
}
