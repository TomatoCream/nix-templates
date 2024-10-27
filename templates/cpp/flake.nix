# flake.nix
{
  description = "C++ project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        defaultCompiler = pkgs.llvmPackages_latest.clangUseLLVM;

        projectName = "cpp-project"; # Template variable to be replaced

        # Common build inputs for both development and package
        commonBuildInputs = with pkgs; [
          boost
          catch2_3
        ];

        # Common native build inputs
        commonNativeBuildInputs = with pkgs; [
          cmake
          ninja
        ];

        # Function to create a development shell with a specific compiler
        mkDevShell = compiler:
          pkgs.mkShell {
            buildInputs =
              commonBuildInputs
              ++ (with pkgs; [
                compiler
                gdb
              ]);

            nativeBuildInputs = commonNativeBuildInputs;
          };

        # Default package derivation
        mkPackage = compiler:
          pkgs.stdenv.mkDerivation {
            pname = projectName;
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs =
              commonNativeBuildInputs
              ++ [
                compiler
              ];

            buildInputs = commonBuildInputs;

            configurePhase = ''
              cmake -B build -G Ninja \
                -DCMAKE_BUILD_TYPE=Release \
                -DPROJECT_NAME=${projectName}
            '';

            buildPhase = ''
              cmake --build build
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp build/main $out/bin/${projectName}
            '';

            meta = with pkgs.lib; {
              description = "A C++ project generated from template";
              platforms = platforms.unix;
            };
          };
      in {
        packages = {
          default = mkPackage defaultCompiler;
          gcc = mkPackage pkgs.gcc;
          clang = mkPackage defaultCompiler;
        };

        devShells = {
          default = mkDevShell defaultCompiler;
          gcc = mkDevShell pkgs.gcc;
          clang = mkDevShell defaultCompiler;
        };

        # Template configuration
        templates.default = {
          path = ./.;
          description = "C++ development environment with configurable compiler";
          welcomeText = ''
            C++ development environment with Boost and Catch2 has been created!

            To get started:
            1. Enter development shell:
               nix develop

            2. Build the project:
               mkdir build && cd build
               cmake -G Ninja ..
               ninja

            3. Run tests:
               ninja test

            Available shells:
            - nix develop      (default, uses Clang)
            - nix develop .#gcc
            - nix develop .#clang

            To build the package:
            - nix build       (default, uses Clang)
            - nix build .#gcc
            - nix build .#clang
          '';
        };
      }
    );
}
