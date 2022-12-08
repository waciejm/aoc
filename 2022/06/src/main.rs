use std::{
    collections::BTreeSet,
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    // Part 1
    let start_packet = find_sequence_of_length(&input, 4).map(|x| x + 4);
    if let Some(start) = start_packet {
        println!("Start of packet at: {start}");
    } else {
        println!("Start of packet not found!");
    }

    // Part 2
    let start_message = find_sequence_of_length(&input, 14).map(|x| x + 14);
    if let Some(start) = start_message {
        println!("Start of message at: {start}");
    } else {
        println!("Start of message not found!");
    }

    Ok(())
}

fn find_sequence_of_length(input: &str, len: usize) -> Option<usize> {
    for index in 0..=input.len() - len {
        let slice = &input[index..index + len];
        if has_unique_chars(slice) {
            return Some(index);
        }
    }
    None
}

fn has_unique_chars(slice: &str) -> bool {
    let mut set = BTreeSet::new();
    for char in slice.chars() {
        if !set.insert(char) {
            return false;
        }
    }
    true
}
