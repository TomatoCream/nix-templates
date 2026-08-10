# treefmt-nix module: wires up `nix fmt` and the `formatting` check.
_: {
  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";

      # Edition must match Cargo.toml's `edition = "2024"` — otherwise
      # treefmt's rustfmt (from nixpkgs) and `cargo fmt`'s rustfmt (from the
      # fenix toolchain, which reads the edition from Cargo.toml) disagree
      # on import ordering/grouping and fight each other.
      programs.rustfmt.enable = true;
      programs.rustfmt.edition = "2024";
      programs.nixfmt.enable = true;
      programs.deadnix.enable = true;
      programs.statix.enable = true;
      programs.taplo.enable = true;
    };
  };
}
