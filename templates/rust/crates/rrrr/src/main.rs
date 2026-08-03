//! rrrr - A blazing fast CLI application

use anyhow::Result;
use clap::Parser;
use tracing::info;

/// rrrr - A blazing fast CLI application
#[derive(Parser, Debug)]
#[command(name = "rrrr", version, about, long_about = None)]
struct Cli {
    /// Enable verbose logging
    #[arg(short, long, action = clap::ArgAction::Count)]
    verbose: u8,

    /// Enable tokio-console for async debugging
    #[arg(long)]
    console: bool,

    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(clap::Subcommand, Debug)]
enum Commands {
    /// Greet someone
    Greet {
        /// Name to greet
        #[arg(short, long, default_value = "World")]
        name: String,
    },
    /// Run a demo of the library
    Demo,
}

fn setup_tracing(verbose: u8, console: bool) {
    use tracing_subscriber::{fmt, prelude::*, EnvFilter};

    let filter = match verbose {
        0 => "info",
        1 => "debug",
        _ => "trace",
    };

    let filter_layer = EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new(filter));

    if console {
        // Enable tokio-console alongside fmt subscriber
        let console_layer = console_subscriber::spawn();
        tracing_subscriber::registry()
            .with(console_layer)
            .with(filter_layer)
            .with(fmt::layer())
            .init();
    } else {
        tracing_subscriber::fmt()
            .with_env_filter(filter_layer)
            .with_target(true)
            .with_thread_ids(true)
            .with_file(true)
            .with_line_number(true)
            .init();
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    setup_tracing(cli.verbose, cli.console);

    info!("Starting rrrr");

    match cli.command {
        Some(Commands::Greet { name }) => {
            let greeting = rrrr_lib::greet(&name);
            println!("{greeting}");
        }
        Some(Commands::Demo) => {
            info!("Running demo...");
            let result = rrrr_lib::add(2, 3);
            println!("2 + 3 = {result}");

            let greeting = rrrr_lib::greet("Rustacean");
            println!("{greeting}");
        }
        None => {
            println!("Welcome to rrrr! Use --help for available commands.");
        }
    }

    info!("Done!");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cli_parse() {
        let cli = Cli::try_parse_from(["rrrr", "-v"]).unwrap();
        assert_eq!(cli.verbose, 1);
    }

    #[test]
    fn test_greet_command() {
        let cli = Cli::try_parse_from(["rrrr", "greet", "--name", "Test"]).unwrap();
        match cli.command {
            Some(Commands::Greet { name }) => assert_eq!(name, "Test"),
            _ => panic!("Expected Greet command"),
        }
    }
}

