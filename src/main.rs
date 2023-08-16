pub mod flow;
use flow::*;

fn field(p@Point{x, y}: &Point) -> Point {
    let angle = y * std::f64::consts::PI;
    Point::rotate(p, angle, Rotation::CounterClockwise)
}

fn main() {

    let v = simulation(1, field);

    println!("Particle: {v:?}");


}
