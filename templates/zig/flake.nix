{
  config,
  lib,
  pkgs,
  ...
}:
{
  description = "Zig development environment";

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

        # Use latest stable Zig version
        zigPkg = pkgs.zig-0_11_0;

        # Development shell configuration
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Zig compiler and tools
            zigPkg

            # Build essentials
            gcc
            cmake
            gnumake

            # Development tools
            gdb
            lldb
            valgrind

            # Code analysis and formatting
            zls # Zig Language Server
            clang-tools # For clang-format

            # Version control
            git

            # Documentation
            man
            man-pages

            # Additional useful tools
            pkg-config
            ccls # C/C++ language server (for C interop)
            bear # For generating compilation database
          ];

          # Shell environment variables
          shellHook = ''
            export ZIG_PATH="${zigPkg}/lib/zig"
            export PATH="$PATH:$ZIG_PATH"

            # Set up temporary directory for Zig cache
            export ZIG_GLOBAL_CACHE_DIR="$PWD/.cache/zig"
            mkdir -p $ZIG_GLOBAL_CACHE_DIR

            # Configure editor integration
            export ZLS_PATH="${pkgs.zls}/bin/zls"

            # Print environment info
            echo "Zig development environment loaded!"
            echo "Zig version: $(zig version)"
            echo "ZLS version: $(zls --version)"
          '';
        };

      in
      {
        # Default development shell
        devShells.default = devShell;

        # For backwards compatibility
        devShell = devShell;
      }
    );
}
