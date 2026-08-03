# CI checks: clippy, audit, nextest, coverage
{ inputs, ... }:
{
  perSystem =
    {
      craneLib,
      craneLibNightly,
      commonArgs,
      cargoArtifacts,
      config,
      ...
    }:
    let
      # Clippy check with strict warnings
      clippy = craneLib.cargoClippy (
        commonArgs
        // {
          inherit cargoArtifacts;
          pname = "rrrr-clippy";
          cargoClippyExtraArgs = "--all-targets --all-features -- -D warnings -D clippy::all -D clippy::pedantic";
        }
      );

      # Cargo audit using advisory-db
      audit = craneLib.cargoAudit {
        inherit (commonArgs) src;
        inherit (inputs) advisory-db;
      };

      # Cargo deny for license and dependency checks
      deny = craneLib.cargoDeny { inherit (commonArgs) src; };

      # Run tests with nextest
      nextest = craneLib.cargoNextest (
        commonArgs
        // {
          inherit cargoArtifacts;
          pname = "rrrr-nextest";
          partitions = 1;
          partitionType = "count";
          cargoNextestExtraArgs = "--all-targets";
        }
      );

      # LLVM coverage report (requires nightly)
      coverage = craneLibNightly.cargoLlvmCov (
        commonArgs
        // {
          pname = "rrrr-coverage";
          cargoArtifacts = craneLibNightly.buildDepsOnly commonArgs;
          cargoLlvmCovExtraArgs = "--all-features --workspace --html";
        }
      );

      # Check formatting (via treefmt)
      formatting = config.treefmt.build.check inputs.self;

    in
    {
      checks = {
        inherit
          clippy
          audit
          deny
          nextest
          coverage
          formatting
          ;

        # Also check the main package builds
        build = config.packages.default;
      };
    };
}
