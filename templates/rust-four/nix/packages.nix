# Package derivations using crane
{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      craneLib,
      commonArgs,
      cargoArtifacts,
      ...
    }:
    let
      # Build the main binary
      rrrr = craneLib.buildPackage (
        commonArgs
        // {
          inherit cargoArtifacts;
          pname = "rrrr";
          cargoExtraArgs = "--package rrrr";

          meta = {
            description = "rrrr - A Rust CLI application";
            homepage = "https://github.com/yourusername/rrrr";
            license = pkgs.lib.licenses.mit;
            maintainers = [ ];
          };
        }
      );

      # Build the library crate
      rrrr-lib = craneLib.buildPackage (
        commonArgs
        // {
          inherit cargoArtifacts;
          pname = "rrrr-lib";
          cargoExtraArgs = "--package rrrr-lib";

          meta = {
            description = "rrrr-lib - Core library for rrrr";
            homepage = "https://github.com/yourusername/rrrr";
            license = pkgs.lib.licenses.mit;
            maintainers = [ ];
          };
        }
      );

      # Build documentation
      doc = craneLib.cargoDoc (
        commonArgs
        // {
          inherit cargoArtifacts;
          pname = "rrrr-doc";
          cargoDocExtraArgs = "--no-deps --document-private-items";
          RUSTDOCFLAGS = "-D warnings";
        }
      );

    in
    {
      packages = {
        inherit rrrr rrrr-lib doc;
        default = rrrr;
      };
    };
}

