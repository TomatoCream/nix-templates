{
  description = "rust_template — Rust project built with crane + fenix, formatted with treefmt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    crane.url = "github:ipetkov/crane";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        ./nix/treefmt.nix
      ];

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        let
          rust = import ./nix/rust.nix {
            inherit
              inputs
              pkgs
              system
              lib
              ;
          };
        in
        {
          packages.default = rust.package;

          checks = rust.checks // {
            rust_template = rust.package;
          };

          apps.default = {
            type = "app";
            program = "${rust.package}/bin/rust_template";
          };

          devShells.default = import ./nix/devshell.nix { inherit pkgs lib rust; };
        };

      flake.templates.default = {
        path = ./.;
        description = "Rust CLI + lib template with crane, fenix, and treefmt-nix";
      };
    };
}
