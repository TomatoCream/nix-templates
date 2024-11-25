{
  description = "Python development environment";

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
        myPython = pkgs.python312;
        myPythonPackages = (p:
          with p; [
            venvShellHook

            pydantic-settings
            pymupdf
            pdftotext
            click
            tqdm
            tabulate
            pydantic
            dateparser
            strenum
            ocrmypdf
          ])
        myPython.pkgs;
      in {
        devShells.default = pkgs.mkShell {
          name = "impurePythonEnv";
          venvDir = "./.venv";

          buildInputs = with pkgs;
            myPythonPackages
            ++ [
              # System dependencies
              taglib
              openssl
              git
              libxml2
              libxslt
              libzip
              zlib
            ];

          # Run after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          # Commands to run after entering the shell
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
          '';
        };
      }
    );
}
