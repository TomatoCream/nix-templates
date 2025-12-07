{
  description = "rrrr - A Rust CLI application with comprehensive Nix tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs self; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks.flakeModule
        ./nix/rust.nix
        ./nix/packages.nix
        ./nix/checks.nix
        ./nix/devshell.nix
        ./nix/docker.nix
        ./nix/treefmt.nix
      ];

      perSystem =
        { system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.fenix.overlays.default ];
          };
        };

      # Flake templates
      flake.templates = {
        default = {
          path = ./.;
          description = "Comprehensive Nix Rust development environment with fenix, crane, and full tooling";
        };

        rust-nix = {
          path = ./.;
          description = "Rust + Nix template with flake-parts, fenix, crane, treefmt, pre-commit";
        };
      };
    };
}
