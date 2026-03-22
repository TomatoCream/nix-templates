{
  description = "scratch - A Haskell project template";

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    allow-import-from-derivation = "true";
  };

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          haskellNix.overlay
          (final: _prev: {
            # This overlay adds our project to pkgs
            scratchProject =
              final.haskell-nix.project' {
                # --- Project Base Configuration ---
                src = final.haskell-nix.haskellLib.cleanSourceWith {
                  name = "scratch-source";
                  src = ./.;
                };

                # The GHC version to use
                compiler-nix-name = "ghc910";
                index-state = "2026-03-20T23:52:16Z";
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.scratchProject.flake { };

        # --- Fully Kitted Out Shell ---
        devShell = pkgs.scratchProject.shellFor {
          # 1. Custom name for the shell derivation
          name = "fully-kitted-haskell-env";

          # 2. Select which local packages to include (defaults to all local packages)
          packages = ps: builtins.attrValues (pkgs.haskell-nix.haskellLib.selectLocalPackages ps);

          # 3. Fine-grained component selection
          # Usable if you want to work on a subset, but we don't need it yet.
          # components = ps: lib.concatMap (p: [ p.components.library ]) (config.packages ps);

          # 4. Additional Haskell packages (from Hackage) for the shell only
          # Usable for GHCi debugging, but commented out as we don't need them yet and to avoid eval errors.
          /*
          additional = ps: [
            ps.lens
            ps.text-icu
            ps.aeson
            ps.pretty-simple
          ];
          */

          # 5. Integrated Development Tools
          tools = {
            cabal = "latest";
            hlint = "latest";
            haskell-language-server = "latest";
            ghcid = "latest";
            fourmolu = "latest";
            doctest = "latest";
            weeder = "latest";
          };

          # 6. Documentation & Search
          withHoogle = true; # Generates a local Hoogle database
          withHaddock = true; # Includes Haddock documentation

          # 7. System dependencies (C libraries)
          buildInputs = with pkgs; [
            zlib
            openssl
            xz # Correct Nixpkgs name for lzma
            icu
            nixpkgs-fmt
            # postgresql # Usable if you need a local database client, but we don't need it yet
          ];

          # 8. Build-time tools (non-Haskell)
          nativeBuildInputs = with pkgs; [
            pkg-config
            git
            jq
            # nodejs # Usable for frontend work, but we don't need it yet
          ];

          # 9. Shell Environment Setup
          shellHook = ''
            echo "--- Haskell Development Environment (scratch) ---"
            echo "GHC: $(ghc --version)"
            echo "Cabal: $(cabal --version)"
            echo "Hoogle: use 'hoogle server --local' to search docs"
            echo "-----------------------------------------------"
            
            # Set custom environment variables
            export MY_PROJECT_ENV="development"
            # export DATABASE_URL="postgres://localhost/mydb" # Usable but not needed yet
            
            # Add convenience aliases
            alias g="ghcid -c 'cabal repl'"
            alias b="cabal bench"
          '';

          # 10. Advanced Nix/GHC Settings
          exactDeps = true; # Forces Cabal to use the exact package versions provided by Nix
          enableDWARF = false; # Usable for deep debugging (GHC 9.2+), but not needed yet

          # 11. Cross-Compilation (Optional)
          # crossPlatforms = p: [ p.ghcjs ]; # Usable for other platforms, but not needed yet

          # 12. Inherit from other shells
          # inputsFrom = [ someOtherPackage ]; # Usable to merge environments, but not needed yet
        };
      in
      flake // {
        # Built by `nix build .`
        packages.default = flake.packages."scratch:exe:scratch";

        # Use our fully kitted out dev shell
        devShells.default = devShell;
      }
    );
}