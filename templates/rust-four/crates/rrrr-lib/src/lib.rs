//! # rrrr-lib
//!
//! Core library for the rrrr CLI application.
//!
//! This crate provides the fundamental functionality used by the rrrr binary.
//!
//! ## Example
//!
//! ```rust
//! use rrrr_lib::{add, greet};
//!
//! let sum = add(2, 3);
//! assert_eq!(sum, 5);
//!
//! let greeting = greet("World");
//! assert_eq!(greeting, "Hello, World!");
//! ```

use serde::{Deserialize, Serialize};
use thiserror::Error;
use tracing::instrument;

/// Errors that can occur in rrrr-lib
#[derive(Error, Debug)]
pub enum RrrrError {
    /// An invalid input was provided
    #[error("invalid input: {0}")]
    InvalidInput(String),

    /// A computation failed
    #[error("computation failed: {0}")]
    ComputationFailed(String),

    /// JSON serialization/deserialization error
    #[error("json error: {0}")]
    Json(#[from] serde_json::Error),
}

/// Result type for rrrr-lib operations
pub type Result<T> = std::result::Result<T, RrrrError>;

/// Configuration for the library
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    /// Name for greetings
    pub name: String,
    /// Enable verbose output
    pub verbose: bool,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            name: String::from("World"),
            verbose: false,
        }
    }
}

/// Add two numbers together.
///
/// # Examples
///
/// ```rust
/// use rrrr_lib::add;
///
/// assert_eq!(add(2, 3), 5);
/// assert_eq!(add(-1, 1), 0);
/// ```
#[instrument]
#[must_use]
pub fn add(left: i64, right: i64) -> i64 {
    tracing::debug!(left, right, "Adding numbers");
    left + right
}

/// Generate a greeting for the given name.
///
/// # Examples
///
/// ```rust
/// use rrrr_lib::greet;
///
/// assert_eq!(greet("Alice"), "Hello, Alice!");
/// assert_eq!(greet("World"), "Hello, World!");
/// ```
#[instrument]
#[must_use]
pub fn greet(name: &str) -> String {
    tracing::debug!(name, "Generating greeting");
    format!("Hello, {name}!")
}

/// Process data with the given configuration.
///
/// # Errors
///
/// Returns an error if the name is empty.
#[instrument(skip(config))]
pub fn process(config: &Config) -> Result<String> {
    if config.name.is_empty() {
        return Err(RrrrError::InvalidInput("name cannot be empty".into()));
    }

    let greeting = greet(&config.name);

    if config.verbose {
        tracing::info!("Processed greeting: {}", greeting);
    }

    Ok(greeting)
}

/// Serialize a value to JSON.
///
/// # Errors
///
/// Returns an error if serialization fails.
pub fn to_json<T: Serialize>(value: &T) -> Result<String> {
    serde_json::to_string_pretty(value).map_err(RrrrError::from)
}

/// Deserialize a value from JSON.
///
/// # Errors
///
/// Returns an error if deserialization fails.
pub fn from_json<'a, T: Deserialize<'a>>(json: &'a str) -> Result<T> {
    serde_json::from_str(json).map_err(RrrrError::from)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
        assert_eq!(add(0, 0), 0);
        assert_eq!(add(i64::MAX, 0), i64::MAX);
    }

    #[test]
    fn test_greet() {
        assert_eq!(greet("World"), "Hello, World!");
        assert_eq!(greet("Rust"), "Hello, Rust!");
        assert_eq!(greet(""), "Hello, !");
    }

    #[test]
    fn test_config_default() {
        let config = Config::default();
        assert_eq!(config.name, "World");
        assert!(!config.verbose);
    }

    #[test]
    fn test_process_success() {
        let config = Config {
            name: "Test".into(),
            verbose: false,
        };
        let result = process(&config);
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "Hello, Test!");
    }

    #[test]
    fn test_process_empty_name() {
        let config = Config {
            name: String::new(),
            verbose: false,
        };
        let result = process(&config);
        assert!(result.is_err());
    }

    #[test]
    fn test_json_roundtrip() {
        let config = Config {
            name: "Test".into(),
            verbose: true,
        };

        let json = to_json(&config).unwrap();
        let parsed: Config = from_json(&json).unwrap();

        assert_eq!(parsed.name, config.name);
        assert_eq!(parsed.verbose, config.verbose);
    }
}

#[cfg(test)]
mod proptests {
    use super::*;
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_add_commutative(a: i32, b: i32) {
            let a = i64::from(a);
            let b = i64::from(b);
            prop_assert_eq!(add(a, b), add(b, a));
        }

        #[test]
        fn test_add_associative(a: i16, b: i16, c: i16) {
            let a = i64::from(a);
            let b = i64::from(b);
            let c = i64::from(c);
            prop_assert_eq!(add(add(a, b), c), add(a, add(b, c)));
        }

        #[test]
        fn test_greet_contains_name(name in "[a-zA-Z]{1,20}") {
            let greeting = greet(&name);
            prop_assert!(greeting.contains(&name));
            prop_assert!(greeting.starts_with("Hello, "));
            prop_assert!(greeting.ends_with('!'));
        }
    }
}

