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

        projectName = "cpp-project";
        buildDir = "build"; # Define build directory variable

        # Use LLVM's recursive set
        llvmSet = pkgs.llvmPackages_latest;
        defaultCompiler = llvmSet.clangUseLLVM;

        # Optimization flags for different levels
        optimizationFlags = {
          performance = [
            "-O3"
            "-flto"
            "-march=native"
            "-ffast-math"
            "-funroll-loops"
            "-fomit-frame-pointer"
          ];

          balanced = [
            "-O2"
            # "-flto=thin" # check optimization options later
            "-march=native"
          ];

          debug = [
            "-O1"
            "-fno-omit-frame-pointer"
            "-fno-inline"
            "-g3"
            "-DDEBUG"
          ];

          size = [
            "-Oz"
            "-flto=thin"
            "-ffunction-sections"
            "-fdata-sections"
          ];
        };

        commonBuildInputs = with pkgs; [
          boost
          catch2_3
          gbenchmark
        ];

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
                llvmSet.lldb
                perf-tools
                linuxPackages.perf
                hotspot
                valgrind
                hyperfine # For command-line benchmarking
                kcachegrind # For callgrind visualization
                flamegraph # For flame graph generation
                tracy # For real-time profiling
                gperftools # For CPU and heap profiling
              ]);

            nativeBuildInputs =
              commonNativeBuildInputs
              ++ (with pkgs; [
                llvmSet.libllvm
                llvmSet.clang-tools # Provides clangd and clang-tidy

                # Additional tools for development
                bear # For generating compile_commands.json
                ccache # For faster rebuilds
                clang-analyzer # Static analyzer

                # LSP and formatting tools
                clang-tools # Provides clang-format
                nodePackages.bash-language-server
                cmake-language-server
              ]);

            # Configure clangd
            shellHook = ''
              # Generate initial compile_commands.json if it doesn't exist
              if [ ! -f compile_commands.json ]; then
                echo "Generating initial compile_commands.json..."
                cmake -B ${buildDir} -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DPROJECT_NAME=${projectName}
                ln -sf ${buildDir}/compile_commands.json .
              fi
            '';
          };

        # Rest of the mkPackage and other definitions remain the same...
        mkPackage = compiler: optimizationLevel:
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

            cmakeFlags = [
              "-DCMAKE_BUILD_TYPE=Release"
              "-DPROJECT_NAME=${projectName}"
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
            ];

            CXXFLAGS = builtins.concatStringsSep " " (optimizationFlags.${optimizationLevel});

            configurePhase = ''
              cmake -B ${buildDir} -G Ninja \
                ''${cmakeFlags[@]} \
                -DCMAKE_CXX_FLAGS="$CXXFLAGS"
            '';

            # dontStrip = true;

            buildPhase = ''
              cmake --build ${buildDir}
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp ${buildDir}/benchmarks $out/bin/benchmarks
              cp ${buildDir}/main $out/bin/${projectName}
            '';

            meta = with pkgs.lib; {
              description = "A C++ project with optimized builds";
              platforms = platforms.unix;
            };
          };
      in {
        packages = {
          default = mkPackage defaultCompiler "balanced";
          performance = mkPackage defaultCompiler "performance";
          balanced = mkPackage defaultCompiler "balanced";
          debug = mkPackage defaultCompiler "debug";
          size = mkPackage defaultCompiler "size";
          gcc = mkPackage pkgs.gcc "balanced";
          clang = mkPackage defaultCompiler "balanced";
        };

        devShells = {
          default = mkDevShell defaultCompiler;
          gcc = mkDevShell pkgs.gcc;
          clang = mkDevShell defaultCompiler;
        };
      }
    );
}
