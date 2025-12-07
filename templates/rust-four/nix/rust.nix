# Rust toolchain configuration using fenix
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # Stable toolchain for general development and builds
      stableToolchain = pkgs.fenix.stable.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
        "rust-analyzer"
      ];

      # Nightly toolchain specifically for llvm-cov (requires nightly)
      nightlyToolchain = pkgs.fenix.complete.withComponents [
        "cargo"
        "llvm-tools-preview"
        "rustc"
      ];

      # Combined toolchain for coverage (nightly with llvm-tools)
      coverageToolchain = pkgs.fenix.combine [
        nightlyToolchain
      ];

      # Crane library configured with stable toolchain
      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain stableToolchain;

      # Crane library configured for coverage (nightly)
      craneLibNightly = (inputs.crane.mkLib pkgs).overrideToolchain coverageToolchain;

      # Common source filtering (use flake's self reference)
      src = craneLib.cleanCargoSource inputs.self;

      # Common arguments for all crate builds
      commonArgs = {
        inherit src;
        strictDeps = true;

        buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.libiconv
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];
      };

      # Build only the cargo dependencies for caching
      cargoArtifacts = craneLib.buildDepsOnly commonArgs;

    in
    {
      _module.args = {
        inherit
          stableToolchain
          nightlyToolchain
          coverageToolchain
          craneLib
          craneLibNightly
          commonArgs
          cargoArtifacts
          ;
      };
    };
}
