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
              # Generate .clangd configuration
              cat > .clangd << EOF
              CompileFlags:
                Add: [
                  -std=c++17,
                  -Wall,
                  -Wextra,
                  -Wpedantic,
                  -Wshadow,
                  -Wformat=2,
                  -Wconversion,
                  -D_GLIBCXX_DEBUG
                ]
                Remove: [-W*pragma-once]

              Diagnostics:
                ClangTidy:
                  Add: [
                    performance-*,
                    bugprone-*,
                    modernize-*,
                    cppcoreguidelines-*,
                    readability-*
                  ]
                  Remove: [
                    modernize-use-trailing-return-type,
                    readability-braces-around-statements
                  ]
                  CheckOptions:
                    readability-identifier-naming.VariableCase: camelBack
                    readability-identifier-naming.FunctionCase: camelBack
                    readability-identifier-naming.ClassCase: CamelCase

              Index:
                Background: Build

              InlayHints:
                Enabled: Yes
                ParameterNames: Yes
                DeducedTypes: Yes

              Hover:
                ShowAKA: Yes
              EOF

              # Generate initial compile_commands.json if it doesn't exist
              if [ ! -f compile_commands.json ]; then
                echo "Generating initial compile_commands.json..."
                cmake -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
                ln -sf build/compile_commands.json .
              fi

              # Generate .clang-tidy configuration
              cat > .clang-tidy << EOF
              ---
              Checks: >
                *,
                -fuchsia-*,
                -google-*,
                -zircon-*,
                -abseil-*,
                -modernize-use-trailing-return-type,
                -llvm-*,
                -llvmlibc-*
              WarningsAsErrors: \'\'
              HeaderFilterRegex: '.*'
              AnalyzeTemporaryDtors: false
              FormatStyle: none
              CheckOptions:
                - key: readability-identifier-naming.VariableCase
                  value: camelBack
                - key: readability-identifier-naming.FunctionCase
                  value: camelBack
                - key: readability-identifier-naming.ClassCase
                  value: CamelCase
              EOF

              # Generate .clang-format
              cat > .clang-format << EOF
              ---
              Language: Cpp
              BasedOnStyle: Mozilla
              IndentWidth: 2
              ColumnLimit: 100
              ---
              EOF
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
              cmake -B build -G Ninja \
                ''${cmakeFlags[@]} \
                -DCMAKE_CXX_FLAGS="$CXXFLAGS"
            '';

            buildPhase = ''
              cmake --build build
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp build/benchmarks $out/bin/benchmarks
              cp build/main $out/bin/${projectName}
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
