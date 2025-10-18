{
  description = "Rust project with rust-overlay and crane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, crane, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        # Stable Rust toolchain with rust-src and rust-analyzer
        toolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Crane library configured with our toolchain
        craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

        # Source filtering for cleaner builds
        src = craneLib.cleanCargoSource ./.;

        # Common arguments for crane builds
        commonArgs = {
          inherit src;
          strictDeps = true;
        };

        # Build dependencies only (for caching)
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        # Build the actual package
        my-project = craneLib.buildPackage (commonArgs // {
          inherit cargoArtifacts;
        });

      in
      {
        # Default package output
        packages = {
          default = my-project;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Rust toolchain (includes rustc, cargo, clippy, rustfmt, rust-analyzer)
            toolchain

            # Cargo productivity tools
            pkgs.cargo-watch    # Auto-rebuild on file changes
            pkgs.cargo-expand   # Expand macros
            pkgs.cargo-edit     # cargo add/rm/upgrade commands
            pkgs.cargo-udeps    # Find unused dependencies
          ];

          # Environment variables
          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

          # Optional: Pretty shell prompt showing we're in nix shell
          shellHook = ''
            echo "🦀 Rust development environment loaded"
            echo "Rust version: $(rustc --version)"
            echo "Cargo version: $(cargo --version)"
          '';
        };

        # CI check
        checks = {
          default = my-project;
        };

        # nix run support
        apps.default = flake-utils.lib.mkApp {
          drv = my-project;
        };
      }
    );
}
