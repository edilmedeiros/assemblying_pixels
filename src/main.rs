fn main() {
    println!("Hello, world!");

    let vector:Vec<u32> = vec![1,2,3,4,5];
    println!("Vector: {:?}", vector);

    let vector_slice = vector.as_slice().chunks(2);
    println!("Vector slice: {:?}", vector_slice);

    for i in vector_slice {
        println!("{:?}", i);
    }

}
