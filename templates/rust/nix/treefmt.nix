# Treefmt and pre-commit configuration
_: {
  perSystem = _: {
    # Treefmt configuration
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        # Rust formatting
        rustfmt = {
          enable = true;
          edition = "2021";
        };

        # Nix formatting (RFC style)
        nixfmt.enable = true;

        # TOML formatting
        taplo.enable = true;

        # Markdown formatting
        mdformat.enable = true;

        # Shell script formatting
        shfmt.enable = true;

        # YAML formatting
        yamlfmt.enable = true;
      };

      settings.global.excludes = [
        "*.lock"
        "target/*"
        "result"
        "result-*"
      ];
    };

    # Pre-commit hooks
    pre-commit = {
      check.enable = true;

      settings.hooks = {
        # Formatting via treefmt
        treefmt.enable = true;

        # Rust-specific hooks
        clippy = {
          enable = true;
          settings.allFeatures = true;
        };

        cargo-check.enable = true;

        # Nix hooks
        nil.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # General hooks
        check-merge-conflicts.enable = true;
        check-toml.enable = true;
        check-yaml.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;

        # Typos
        typos.enable = true;
      };
    };
  };
}
