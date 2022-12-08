use std::{
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let elves = Elf::from_stdin_supply_list()?;

    // part 1
    println!("Part 1");
    let chosen = elves.iter().max_by_key(|elf| elf.supplies);
    if let Some(chosen) = chosen {
        println!("Elf with most supplies: {}", chosen.supplies);
    } else {
        println!("No elves!");
    }
    println!();

    // part 2
    println!("Part 2");
    let mut top_elves = elves.clone();
    top_elves.sort_by_key(|elf| elf.supplies);
    if top_elves.len() >= 3 {
        let top3 = top_elves
            .iter()
            .rev()
            .take(3)
            .fold(0, |acc, elf| acc + elf.supplies);
        println!("3 elves with most supplies: {}", top3);
    } else {
        println!("Not enough elves!");
    }
    println!();

    Ok(())
}

#[derive(Debug, Clone)]
struct Elf {
    pub supplies: i64,
}

impl Elf {
    pub fn from_stdin_supply_list() -> Result<Vec<Elf>, Box<dyn Error>> {
        let mut elves = Vec::new();

        let mut input = String::new();
        stdin().read_to_string(&mut input)?;

        let mut lines = input.lines().peekable();

        loop {
            let mut supplies = None;
            loop {
                match lines.next() {
                    Some(s) if !s.is_empty() => {
                        let number = s.parse()?;
                        supplies = match supplies {
                            None => Some(number),
                            Some(x) => Some(x + number),
                        };
                    }
                    _ => break,
                };
            }
            if let Some(supplies) = supplies {
                elves.push(Elf { supplies });
            }
            if let None = lines.peek() {
                break;
            }
        }

        Ok(elves)
    }
}
