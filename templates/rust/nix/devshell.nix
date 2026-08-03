# Development shell with all tools
{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      stableToolchain,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "rrrr-dev";

        # Include pre-commit hooks
        shellHook = ''
          ${config.pre-commit.installationScript}
          echo "🦀 rrrr development environment"
          echo ""
          echo "Available commands:"
          echo "  cargo build    - Build the project"
          echo "  cargo test     - Run tests"
          echo "  cargo nextest  - Run tests with nextest"
          echo "  bacon          - Background code checker"
          echo "  cargo audit    - Security audit"
          echo "  cargo llvm-cov - Code coverage"
          echo "  cargo flamegraph - Generate flame graph"
          echo "  evcxr          - Rust REPL"
          echo "  tokio-console  - Async debugger"
          echo "  treefmt        - Format all code"
          echo ""
        '';

        nativeBuildInputs = with pkgs; [
          # Rust toolchain (stable with rust-analyzer)
          stableToolchain

          # Build essentials
          pkg-config
          openssl

          # Cargo extensions - Testing
          cargo-nextest # Fast test runner
          cargo-llvm-cov # Code coverage

          # Cargo extensions - Development
          cargo-watch # Watch for changes
          cargo-expand # Macro expansion
          cargo-edit # Add/remove deps
          cargo-outdated # Check for outdated deps
          cargo-bloat # Binary size analysis
          cargo-udeps # Find unused deps

          # Cargo extensions - Quality
          cargo-audit # Security audit
          cargo-deny # Dependency checks
          cargo-machete # Find unused deps (fast)

          # Cargo extensions - Profiling
          cargo-flamegraph # Flame graphs
          cargo-criterion # Benchmarking

          # Background checker
          bacon

          # Async debugging
          tokio-console

          # Rust REPL
          evcxr

          # Formatting (provided by treefmt)
          config.treefmt.build.wrapper
          taplo # TOML formatter/LSP

          # Misc tools
          just # Command runner
          hyperfine # Benchmarking CLI
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          # Linux-specific profiling tools
          linuxPackages.perf
          strace
          valgrind
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.libiconv
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
        ];

        # Environment variables
        RUST_BACKTRACE = "1";
        RUST_LOG = "info";

        # For tokio-console
        RUSTFLAGS = "--cfg tokio_unstable";
      };
    };
}

