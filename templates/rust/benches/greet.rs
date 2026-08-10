use criterion::{Criterion, criterion_group, criterion_main};
use rust_template::greet;
use std::hint::black_box;

fn bench_greet(c: &mut Criterion) {
    c.bench_function("greet", |b| b.iter(|| greet(black_box("world"))));
}

criterion_group!(benches, bench_greet);
criterion_main!(benches);
