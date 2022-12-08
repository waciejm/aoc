#![feature(is_some_and)]

use std::{
    error::Error,
    io::{stdin, Read},
};

fn main() -> Result<(), Box<dyn Error>> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    let forest = Forest::from_input(&input)?;

    // Part 1
    let visible = forest.trees.iter().filter(|t| t.visible).count();
    println!("Visible from outside: {visible}");

    // Part 2
    let best = forest
        .trees
        .iter()
        .map(|t| t.scenic_score)
        .max()
        .expect("Forest is not empty");
    println!("Best scenic score: {best}");

    Ok(())
}

#[derive(Debug)]
struct Forest {
    pub trees: Vec<Tree>,
    pub size_x: usize,
    pub size_y: usize,
}

impl Forest {
    pub fn from_input(str: &str) -> Result<Self, Box<dyn Error>> {
        let size_x = str.lines().next().unwrap_or("").len();
        let size_y = str.lines().count();
        let mut trees = Vec::new();
        for char in str.chars().filter(|c| c.is_ascii_digit()) {
            let height = char.to_digit(10).ok_or(Box::<dyn Error>::from(format!(
                "Invalid digit in tree: {char}"
            )))?;
            trees.push(Tree::new(height));
        }
        let mut forest = Self {
            trees,
            size_x,
            size_y,
        };
        forest.fill_neighbours();
        forest.calculate_visibilities();
        forest.calculate_scenic_scores();
        Ok(forest)
    }

    fn fill_neighbours(&mut self) {
        // left
        for y in 0..self.size_y {
            let mut max = None;
            for x in 0..self.size_x {
                let tree = self.get(x, y);
                tree.max_left = max;
                if let Some(x) = max {
                    max = Some(u32::max(tree.height, x));
                } else {
                    max = Some(tree.height);
                }
            }
        }
        // right
        for y in 0..self.size_y {
            let mut max = None;
            for x in (0..self.size_x).rev() {
                let tree = self.get(x, y);
                tree.max_right = max;
                if let Some(x) = max {
                    max = Some(u32::max(tree.height, x));
                } else {
                    max = Some(tree.height);
                }
            }
        }
        // up
        for x in 0..self.size_x {
            let mut max = None;
            for y in 0..self.size_y {
                let tree = self.get(x, y);
                tree.max_up = max;
                if let Some(x) = max {
                    max = Some(u32::max(tree.height, x));
                } else {
                    max = Some(tree.height);
                }
            }
        }
        // down
        for x in 0..self.size_x {
            let mut max = None;
            for y in (0..self.size_y).rev() {
                let tree = self.get(x, y);
                tree.max_down = max;
                if let Some(x) = max {
                    max = Some(u32::max(tree.height, x));
                } else {
                    max = Some(tree.height);
                }
            }
        }
    }

    fn calculate_visibilities(&mut self) {
        self.trees.iter_mut().for_each(|t| t.calc_is_visible());
    }

    fn calculate_scenic_scores(&mut self) {
        for x in 0..self.size_x {
            for y in 0..self.size_y {
                self.calculate_scenic_score(x, y);
            }
        }
    }

    fn calculate_scenic_score(&mut self, x: usize, y: usize) {
        let height = self.get(x, y).height;
        let left = {
            let mut score = 0;
            for x in (0..x).rev() {
                score += 1;
                if self.get(x, y).height >= height {
                    break;
                }
            }
            score
        };
        let right = {
            let mut score = 0;
            for x in x + 1..self.size_x {
                score += 1;
                if self.get(x, y).height >= height {
                    break;
                }
            }
            score
        };
        let up = {
            let mut score = 0;
            for y in (0..y).rev() {
                score += 1;
                if self.get(x, y).height >= height {
                    break;
                }
            }
            score
        };
        let down = {
            let mut score = 0;
            for y in y + 1..self.size_y {
                score += 1;
                if self.get(x, y).height >= height {
                    break;
                }
            }
            score
        };
        self.get(x, y).scenic_score = left * right * up * down;
    }

    fn get(&mut self, x: usize, y: usize) -> &mut Tree {
        &mut self.trees[x + y * self.size_y]
    }
}

#[derive(Debug)]
struct Tree {
    pub height: u32,
    pub max_right: Option<u32>,
    pub max_left: Option<u32>,
    pub max_up: Option<u32>,
    pub max_down: Option<u32>,
    pub visible: bool,
    pub scenic_score: u32,
}

impl Tree {
    pub fn new(height: u32) -> Self {
        Self {
            height,
            max_right: None,
            max_left: None,
            max_up: None,
            max_down: None,
            visible: false,
            scenic_score: 0,
        }
    }

    pub fn calc_is_visible(&mut self) {
        self.visible = !self.max_right.is_some_and(|t| t >= self.height)
            || !self.max_left.is_some_and(|t| t >= self.height)
            || !self.max_up.is_some_and(|t| t >= self.height)
            || !self.max_down.is_some_and(|t| t >= self.height);
    }
}
