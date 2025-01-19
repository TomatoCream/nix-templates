{
  description = "Zig project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ zig-overlay.overlays.default ];
        };

        zigPkg = pkgs.zig;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            zigPkg
            gcc
            cmake
            gnumake
            gdb
            lldb
            valgrind
            zls
            clang-tools
            git
            man
            man-pages
            pkg-config
            ccls
            bear
          ];

          shellHook = ''
            export ZIG_PATH="${zigPkg}/lib/zig"
            export PATH="$PATH:$ZIG_PATH"
            export ZIG_GLOBAL_CACHE_DIR="$PWD/.cache/zig"
            mkdir -p $ZIG_GLOBAL_CACHE_DIR
            export ZLS_PATH="${pkgs.zls}/bin/zls"

            echo "Zig development environment loaded!"
            echo "Zig version: $(zig version)"
            echo "ZLS version: $(zls --version)"
          '';
        };
      in
      {
        devShells.default = devShell;
        devShell = devShell;

        # Add package definition
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zig-project";
          version = "0.1.0";
          src = ./template;

          nativeBuildInputs = [ zigPkg ];

          buildPhase = ''
            zig build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/* $out/bin/
          '';
        };
      }
    );
}
