# Shared Rust build environment: toolchain, craneLib, source filtering,
# and cached dependency artifacts. Consumed by both the package build
# (nix/package.nix, implicit below) and the dev shell (nix/devshell.nix)
# so the two stay close to identical.
{
  inputs,
  pkgs,
  system,
  lib,
}:
let
  fenixPkgs = inputs.fenix.packages.${system};

  rustToolchain = fenixPkgs.stable.withComponents [
    "cargo"
    "clippy"
    "llvm-tools"
    "rust-analyzer"
    "rust-src"
    "rustc"
    "rustfmt"
  ];

  craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (_: rustToolchain);

  src = craneLib.cleanCargoSource ./..;

  commonArgs = {
    inherit src;
    strictDeps = true;

    nativeBuildInputs = [
      pkgs.pkg-config
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      pkgs.clang
      pkgs.mold
    ];

    buildInputs = lib.optionals pkgs.stdenv.isDarwin [
      pkgs.libiconv
      pkgs.darwin.apple_sdk.frameworks.Security
      pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    ];
  };

  # Built once, reused by the package build, clippy, doc, and nextest —
  # this is what makes incremental rebuilds fast under crane.
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  package = craneLib.buildPackage (
    commonArgs
    // {
      inherit cargoArtifacts;
      pname = "rust_template";
      doCheck = false; # exercised separately via checks.nextest
    }
  );

  checks = {
    clippy = craneLib.cargoClippy (
      commonArgs
      // {
        inherit cargoArtifacts;
        cargoClippyExtraArgs = "--all-targets -- --deny warnings";
      }
    );

    doc = craneLib.cargoDoc (
      commonArgs
      // {
        inherit cargoArtifacts;
        env.RUSTDOCFLAGS = "--deny warnings";
      }
    );

    fmt = craneLib.cargoFmt { inherit src; };

    audit = craneLib.cargoAudit {
      inherit src;
      inherit (inputs) advisory-db;
    };

    nextest = craneLib.cargoNextest (
      commonArgs
      // {
        inherit cargoArtifacts;
        partitions = 1;
        partitionType = "count";
      }
    );
  };
in
{
  inherit
    craneLib
    commonArgs
    cargoArtifacts
    package
    checks
    rustToolchain
    ;
}
