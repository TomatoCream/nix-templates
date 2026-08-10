use clap::Parser;
use rust_template::greet;

#[derive(Parser)]
#[command(version, about)]
struct Cli {
    /// Name to greet
    #[arg(default_value = "world")]
    name: String,
}

fn main() {
    let cli = Cli::parse();
    println!("{}", greet(&cli.name));
}
