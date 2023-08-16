
//use wasm_bindgen::prelude::*;

pub type Coordinate = (f64, f64);
pub type Flow = fn(pos: &Point) -> Point;


pub enum Rotation {
    Clockwise,
    CounterClockwise,
}


#[derive(Debug, Clone, Copy)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

impl Point {
    pub fn default() -> Point {
        Point{x: 0.0, y: 0.5}
    }

    pub fn rotate(p: &Point, angle: f64, direction: Rotation) -> Point {
        let x = p.x * angle.cos() - p.y * angle.sin();
        let y = p.x * angle.sin() + p.y * angle.cos();
        match direction {
            Rotation::Clockwise => Point {x, y: -y},
            Rotation::CounterClockwise => Point {x, y},
        }
    }
}

#[derive(Debug)]
pub struct Particle {
    pub pos: Point,
    pub lifetime: usize,
    pub flow: Flow,
}

impl Particle {
    pub fn new(pos: Point,
               lifetime: usize,
               flow: Flow) -> Particle {
        Particle{pos, lifetime, flow}
    }
}

impl Iterator for Particle {
    type Item = Point;

    fn next(&mut self) -> Option<Self::Item> {
        if self.lifetime == 0 {
            None
        } else {
            let Point{x: delta_x, y: delta_y} = (self.flow)(&self.pos);
            self.pos = Point {x: self.pos.x + 0.1*delta_x,
                              y: self.pos.y + 0.1*delta_y,};
            self.lifetime -= 1;
            Some(self.pos)
        }
    }
}


pub fn simulation(_n: usize, flow: Flow) -> Vec<Vec<Point>> {
    let particle = Particle::new(Point{x: 0.5, y: 0.1}, 10, flow);
    vec![particle.collect()]

    // Initialize particles
    // Iterate each
}
