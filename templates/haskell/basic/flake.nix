{
  # This is a template created by `hix init`
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    haskellNix,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in
    flake-utils.lib.eachSystem supportedSystems (
      system: let
        overlays = [
          haskellNix.overlay
          (final: prev: {
            hixProject = final.haskell-nix.project' rec {
              src = ./.;
              evalSystem = "x86_64-linux";
              compiler-nix-name = "ghc966"; # Updated GHC version to match example

              # Shell configuration with comprehensive development tools
              shell = let
                lib = final.lib;
                config = {
                  packages = ps: builtins.attrValues (final.haskell-nix.haskellLib.selectLocalPackages ps);
                  withHoogle = true;
                  withHaddock = true;
                  exactDeps = false;
                };
              in {
                # Packa
                packages = ps: builtins.attrValues (final.haskell-nix.haskellLib.selectLocalPackages ps);

                # Components to include in the shell environment
                components = ps: lib.concatMap final.haskell-nix.haskellLib.getAllComponents (config.packages ps);

                # Additional packages to include in the shell
                additional = ps: [];

                # Haskell development tools
                tools = {
                  cabal = {}; # Haskell build tool
                  hlint = {}; # Haskell linter
                  haskell-language-server = {}; # LSP server for Haskell
                  ghcid = {}; # GHC-based development tool with continuous type checking
                  hoogle = {}; # Haskell API search engine
                  ormolu = {}; # Haskell code formatter
                  # stack = {}; # Alternative build tool
                  ghc-prof-flamegraph = {}; # Profiling visualization
                };

                # Enable Hoogle documentation
                withHoogle = true;

                # Enable Haddock documentation
                withHaddock = true;

                # Include setup dependencies for packages
                packageSetupDeps = true;

                # Enable DWARF debugging information
                enableDWARF = false;

                # Cross-platform build support
                # Uses project-level configuration by default
                crossPlatforms = p: [];

                # Enable exact dependencies mode
                exactDeps = false;

                # Include all tool dependencies
                allToolDeps = true;

                # Additional shell hook for environment setup
                shellHook = ''
                  echo "Haskell Development Environment"
                  echo "GHC Version: ${compiler-nix-name}"

                  # Set up local project environment
                  export PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo $PWD)
                  export PATH="$PROJECT_ROOT/scripts:$PATH"
                '';

                # Derivations to include in the shell environment
                inputsFrom = [];

                # Non-Haskell development tools
                buildInputs = with final; [
                  # System Tools
                  uutils-coreutils-noprefix
                ];

                # Additional native build inputs
                nativeBuildInputs = with final; [
                  pkg-config
                  zlib # Common compression library
                ];

                # Additional attributes to pass through
                passthru = {
                  # Add any custom attributes here
                };
              };
            };
          })
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };
        flake = pkgs.hixProject.flake {};
      in
        flake
        // {
          legacyPackages = pkgs;

          packages =
            flake.packages
            // {
              default = flake.packages."project:exe:project";
            };
        }
    );

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
  };
}
