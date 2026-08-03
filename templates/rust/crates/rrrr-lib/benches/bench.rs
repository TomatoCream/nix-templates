//! Benchmarks for rrrr-lib using criterion

use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};
use rrrr_lib::{add, greet, process, Config};

fn bench_add(c: &mut Criterion) {
    let mut group = c.benchmark_group("add");

    group.bench_function("simple", |b| {
        b.iter(|| add(black_box(42), black_box(58)));
    });

    // Benchmark with different input sizes
    for size in [10, 100, 1000, 10000].iter() {
        group.bench_with_input(BenchmarkId::from_parameter(size), size, |b, &size| {
            b.iter(|| {
                let mut sum = 0i64;
                for i in 0..size {
                    sum = add(sum, black_box(i));
                }
                sum
            });
        });
    }

    group.finish();
}

fn bench_greet(c: &mut Criterion) {
    let mut group = c.benchmark_group("greet");

    // Benchmark with different name lengths
    let names = ["A", "Alice", "Alexander Hamilton", "A very long name indeed"];

    for name in names {
        group.throughput(Throughput::Bytes(name.len() as u64));
        group.bench_with_input(BenchmarkId::from_parameter(name.len()), name, |b, name| {
            b.iter(|| greet(black_box(name)));
        });
    }

    group.finish();
}

fn bench_process(c: &mut Criterion) {
    let mut group = c.benchmark_group("process");

    let configs = [
        ("short_name", Config {
            name: "Hi".into(),
            verbose: false,
        }),
        ("medium_name", Config {
            name: "Hello World".into(),
            verbose: false,
        }),
        ("long_name", Config {
            name: "A very long name for testing purposes".into(),
            verbose: false,
        }),
    ];

    for (id, config) in configs {
        group.bench_with_input(BenchmarkId::new("name_length", id), &config, |b, config| {
            b.iter(|| process(black_box(config)));
        });
    }

    group.finish();
}

fn bench_json_serialization(c: &mut Criterion) {
    let mut group = c.benchmark_group("json");

    let config = Config {
        name: "Benchmark User".into(),
        verbose: true,
    };

    group.bench_function("serialize", |b| {
        b.iter(|| rrrr_lib::to_json(black_box(&config)));
    });

    let json = rrrr_lib::to_json(&config).unwrap();
    group.bench_function("deserialize", |b| {
        b.iter(|| rrrr_lib::from_json::<Config>(black_box(&json)));
    });

    group.bench_function("roundtrip", |b| {
        b.iter(|| {
            let json = rrrr_lib::to_json(black_box(&config)).unwrap();
            rrrr_lib::from_json::<Config>(&json).unwrap()
        });
    });

    group.finish();
}

criterion_group!(
    benches,
    bench_add,
    bench_greet,
    bench_process,
    bench_json_serialization,
);

criterion_main!(benches);

