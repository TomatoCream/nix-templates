{
  description = "A best-in-class C++ development environment template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { config
        , self'
        , pkgs
        , ...
        }:
        let
          # --- Configuration ---
          # Available versions: llvmPackages_16, llvmPackages_17, llvmPackages_18, llvmPackages_19, etc.
          llvmVersion = "llvmPackages_21";
          llvmPkgs = pkgs.${llvmVersion};

          # Use the selected LLVM version's stdenv (explicitly libc++ version)
          stdenv = llvmPkgs.libcxxStdenv;

          # Build-time dependencies
          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
            mold
            llvmPkgs.libcxxClang
          ];

          # Run-time dependencies
          buildInputs = with pkgs; [
            # Add libraries here
            llvmPkgs.libcxx
          ];
        in
        {
          # Formatting configuration
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixpkgs-fmt.enable = true;
              clang-format.enable = true;
              cmake-format.enable = true;
            };
          };

          # Main package definition
          packages.default = stdenv.mkDerivation {
            pname = "cpp-project-template";
            version = "0.1.0";
            src = ./.;

            inherit nativeBuildInputs buildInputs;

            # Configure CMake to use Ninja and Mold
            cmakeFlags = [
              "-GNinja"
              "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
              "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
            ];
          };

          # Development shell
          devShells.default = pkgs.mkShell.override { inherit stdenv; } {
            inputsFrom = [ self'.packages.default ];

            packages = with pkgs; [
              # LSPs and tooling
              llvmPkgs.clang
              llvmPkgs.libcxxClang
              llvmPkgs.llvm
              llvmPkgs.clang-tools # Includes clangd matching our LLVM version
              cmake-language-server
              bear # For generating compile_commands.json if CMake fails to
              gdb
              lldb
              pahole
              valgrind
              just
            ];

            shellHook = ''
              echo "--- C++ Development Environment ---"
              echo "Compiler: $(clang --version | head -n1)"
              echo "Linker: $(mold --version | head -n1)"

              # Install pre-commit hook to run nix fmt
              mkdir -p .git/hooks
              cat <<EOF > .git/hooks/pre-commit
              #!/bin/sh
              nix fmt
              EOF
              chmod +x .git/hooks/pre-commit

              # Export flags for tools that don't pick up the stdenv automatically
              export CC=clang
              export CXX=clang++

              # Generate .clangd to help LSPs find Nix store paths
              ./generate_clangd.sh

              # Symlink compile_commands.json if it exists in build directory
              if [ -f build/compile_commands.json ] && [ ! -f compile_commands.json ]; then
                ln -s build/compile_commands.json .
              fi

              # Advice for LSP support
              if [ ! -f compile_commands.json ] && [ ! -d build ]; then
                echo "Tip: Run 'cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON' to generate LSP data."
              fi
            '';

            # Ensure mold is used in the shell environment
            LD_FLAGS = "-fuse-ld=mold";
          };

          # Check for CI
          checks = {
            formatting = config.treefmt.build.check self;
            build = self'.packages.default;
          };
        };
    };
}
