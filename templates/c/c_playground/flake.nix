{
  description = "C playground - learning environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];

      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, config, ... }:
        let
          llvm = pkgs.llvmPackages_21;
        in
        {
          # Treefmt configuration
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              clang-format.enable = true;
              nixfmt.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = [
              # Compilers
              llvm.clang
              pkgs.gcc

              # Clang tools
              llvm.clang-tools    # clangd, clang-tidy, clang-format

              # Build tools
              pkgs.gnumake
              pkgs.bear           # generates compile_commands.json for LSP

              # Linker
              pkgs.mold

              # Debugging
              pkgs.gdb
              pkgs.valgrind

              # Utilities
              pkgs.fd
              pkgs.entr

              # Formatting (via treefmt)
              config.treefmt.build.wrapper
            ];

            shellHook = ''
              echo "🔧 C Playground"
              echo ""
              echo "Compilers:"
              echo "  clang: $(clang --version | head -1)"
              echo "  gcc:   $(gcc --version | head -1)"
              echo ""
              echo "Build:"
              echo "  make              # build with clang"
              echo "  make CC=gcc       # build with gcc"
              echo "  make run          # build and run"
              echo "  make watch        # auto rebuild on changes"
              echo "  make bear         # generate compile_commands.json"
              echo ""
              echo "Format & Lint:"
              echo "  treefmt           # format all (C + Nix)"
              echo "  clang-tidy src/main.c"
              echo ""
            '';
          };
        };
    };
}
