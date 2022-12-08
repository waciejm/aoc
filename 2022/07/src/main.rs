use std::{
    collections::HashMap,
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;
    let commands = parse_commands(&input);
    let tree = discover_file_tree(&commands);

    let sizes = tree.get_dir_sizes();
    let total = *sizes.last().unwrap();

    // Part 1
    let sum = sizes.iter().filter(|x| **x <= 100000).sum::<u64>();
    println!("Sum of dirs less than 100000: {sum}");

    // Part 2
    let missing =
        u64::try_from((total as i64) - 40000000).expect("Used space is greater than 40000000");
    let big_enough = sizes.iter().filter(|x| **x >= missing).min();
    println!("Smallest dir to get enough space: {}", big_enough.unwrap());

    Ok(())
}

#[derive(Debug)]
struct Tree {
    pub root: Node,
}

impl Tree {
    pub fn new() -> Self {
        Self {
            root: Node::empty_dir(),
        }
    }

    pub fn get(&mut self, path: &AbsolutePath) -> &mut Node {
        let mut current = &mut self.root;
        for component in &path.components {
            if let Node::Dir(dir) = current {
                current = dir.get_mut(component).expect("Node exist in dir");
            } else {
                panic!("Tried to use file as part of path")
            }
        }
        current
    }

    pub fn get_dir_sizes(&self) -> Vec<u64> {
        let mut result = Vec::new();
        self.root.get_dir_sizes(&mut result);
        result
    }
}

#[derive(Debug)]
enum Node {
    File(u64),
    Dir(HashMap<String, Node>),
}

impl Node {
    pub fn empty_dir() -> Self {
        Self::Dir(HashMap::new())
    }

    pub fn mkdir(&mut self, name: String) {
        match self {
            Self::File(_) => panic!("Can't mkdir on file"),
            Self::Dir(dir) => {
                dir.entry(name).or_insert(Self::empty_dir());
            }
        }
    }

    pub fn touch(&mut self, name: String, size: u64) {
        match self {
            Self::File(_) => panic!("Can't mkdir on file"),
            Self::Dir(dir) => {
                dir.insert(name, Self::File(size));
            }
        }
    }

    pub fn get_dir_sizes(&self, result: &mut Vec<u64>) -> u64 {
        match self {
            Self::File(_) => panic!("Can't get dir sizes on file"),
            Self::Dir(dir) => {
                let mut size = 0;
                dir.values().for_each(|c| match c {
                    Node::File(s) => {
                        size += s;
                    }
                    Node::Dir(_) => {
                        let s = c.get_dir_sizes(result);
                        size += s;
                    }
                });
                result.push(size);
                size
            }
        }
    }
}

#[derive(Debug)]
struct AbsolutePath {
    pub components: Vec<String>,
}

impl AbsolutePath {
    pub fn new() -> Self {
        Self {
            components: Vec::new(),
        }
    }

    pub fn cd(&mut self, cd: &CD) {
        match cd {
            CD::Root => {
                self.components.clear();
            }
            CD::Back => {
                self.components.pop();
            }
            CD::Forward(x) => {
                self.components.push(x.clone());
            }
        }
    }
}

#[derive(Debug)]
enum Command {
    CD(CD),
    LS(Vec<Entry>),
}

#[derive(Debug)]
enum CD {
    Root,
    Back,
    Forward(String),
}

#[derive(Debug)]
enum Entry {
    File { name: String, size: u64 },
    Dir { name: String },
}

fn parse_commands(str: &str) -> Vec<Command> {
    let mut commands = Vec::new();
    let mut lines = str.lines().peekable();
    while let Some(command) = lines.next() {
        commands.push(match &command[0..4] {
            "$ cd" => match &command[5..] {
                "/" => Command::CD(CD::Root),
                ".." => Command::CD(CD::Back),
                component => Command::CD(CD::Forward(component.into())),
            },
            "$ ls" => {
                let mut entries = Vec::new();
                while lines.peek().is_some() && !lines.peek().unwrap().starts_with('$') {
                    let mut words = lines.next().unwrap().split_ascii_whitespace();
                    match (words.next(), words.next()) {
                        (Some("dir"), Some(name)) => {
                            entries.push(Entry::Dir { name: name.into() });
                        }
                        (Some(size), Some(name)) => {
                            entries.push(Entry::File {
                                name: name.into(),
                                size: size.parse().expect("Size of file"),
                            });
                        }
                        _ => panic!("Unexpected ls command line"),
                    }
                }
                Command::LS(entries)
            }
            _ => panic!("Unexpected command"),
        });
    }
    commands
}

fn discover_file_tree(commands: &[Command]) -> Tree {
    let mut tree = Tree::new();
    let mut path = AbsolutePath::new();
    for command in commands {
        match command {
            Command::CD(cd) => {
                path.cd(cd);
            }
            Command::LS(entries) => {
                let mut node = tree.get(&path);
                for entry in entries {
                    match entry {
                        Entry::File { name, size } => node.touch(name.into(), *size),
                        Entry::Dir { name } => node.mkdir(name.into()),
                    }
                }
            }
        }
    }
    tree
}
