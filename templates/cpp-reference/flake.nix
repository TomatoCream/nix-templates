{
  description = "A C++ development environment with Boost and Clang/LLVM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        # Helper function to create a build environment for either libc++ (default) or libstdc++
        mkApp = {
          name,
          stdenv,
          useLibcxx ? true,
        }:
          stdenv.mkDerivation {
            pname = "cpp-reference-${name}";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = with pkgs; [cmake ninja];
            buildInputs = with pkgs; [boost];

            cmakeFlags =
              ["-GNinja"]
              ++ (
                if useLibcxx
                then ["-DUSE_LIBCXX=ON"]
                else ["-DUSE_LIBCXX=OFF"]
              );
          };

        # Helper function to create a devShell
        mkShell = {
          name,
          package,
          stdenv,
        }:
          pkgs.mkShell.override {inherit stdenv;} {
            name = "cpp-dev-shell-${name}";
            inputsFrom = [package];

            packages = with pkgs; [
              just
              clang-tools # Includes clangd (LSP) and clang-format
              lldb
              nil
              nixpkgs-fmt
              mold        # High-performance linker
              llvm        # Includes llvm-dis, llvm-nm, llvm-readelf, etc.
              elfutils    # For readelf and other ELF utilities
            ];

            shellHook = ''
              echo "Entering ${name} environment..."
              echo "------------------------------------------------"
              echo "Compiler: $(cc --version | head -n 1)"
              echo "LSP:      $(clangd --version)"
              echo "Standard Library: ${
                if name == "libstdcxx"
                then "GNU libstdc++"
                else "LLVM libc++"
              }"
              echo "------------------------------------------------"
              echo "Tip: Run 'just setup' to generate the LSP database."
            '';
          };

        # Environments
        gccEnv = pkgs.clangStdenv;
        llvmEnv = pkgs.libcxxStdenv;
      in {
        # Modular treefmt config
        treefmt.config = import ./nix/treefmt.nix {inherit pkgs;};

        # --- PACKAGES ---
        packages = {
          # Default is now LLVM libc++
          default = mkApp {
            name = "libcxx";
            stdenv = llvmEnv;
            useLibcxx = true;
          };
          libstdcxx = mkApp {
            name = "libstdcxx";
            stdenv = gccEnv;
            useLibcxx = false;
          };
        };

        # --- DEVELOPMENT SHELLS ---
        devShells = {
          # Default is now LLVM libc++
          default = mkShell {
            name = "libcxx";
            package = self'.packages.default;
            stdenv = llvmEnv;
          };
          libstdcxx = mkShell {
            name = "libstdcxx";
            package = self'.packages.libstdcxx;
            stdenv = gccEnv;
          };
        };
      };
    };
}
