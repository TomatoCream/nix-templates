{
  description = "Comprehensive Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
          targets = [ "x86_64-unknown-linux-gnu" ];
        };

        nativeBuildInputs = with pkgs; [
          rustToolchain
          lldb
          gdb
          valgrind
          llvm
          clang
          cmake
          pkg-config
          cargo-asm
          cargo-expand
          cargo-llvm-cov
          cargo-watch
          rust-analyzer
        ];

        # Define the Rust package build
        rustPkg = pkgs.rustPlatform.buildRustPackage {
          pname = "rust-project";
          version = "0.1.0";

          src = ./.; # Use the current directory as source

          cargoLock = {
            lockFile = ./Cargo.lock;
            allowBuiltinFetchGit = true;
          };

          buildInputs = with pkgs; [
            # Add any runtime dependencies here
          ];

          nativeBuildInputs = with pkgs; [
            rustToolchain
            pkg-config
          ];

          # Enable debug symbols and other build flags
          RUSTFLAGS = "-C target-cpu=native";

          # Optional: add checkInputs for testing dependencies
          checkInputs = with pkgs; [
            # Add any test-only dependencies here
          ];
        };

      in
      {
        # Development shell environment
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs;

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = 1;
          RUST_LOG = "debug";
          RUSTFLAGS = "-C target-cpu=native";
        };

        # Package output
        packages = {
          default = rustPkg;
          rust-project = rustPkg;
        };
      }
    );
}
