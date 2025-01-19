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
            "lldb"
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

      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs;

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          RUST_BACKTRACE = 1;
          RUST_LOG = "debug";
          RUSTFLAGS = "-C target-cpu=native";
        };
      }
    );
}
