{
  description = "Development environment templates";

  outputs = {self}: {
    templates = {
      cpp = {
        path = ./templates/cpp;
        description = "C++ development environment with configurable compiler";
      };
      c_playground = {
        path = ./templates/c/c_playground;
        description = "simple C playground";
      };
      rust = {
        path = ./templates/rust;
        description = "rust";
      };
      rust-crane = {
        path = ./templates/rust-crane;
        description = "Rust project with rust-overlay and crane for fast incremental builds";
      };
      rust-four = {
        path = ./templates/rust-four;
        description = "Rust project with flake-parts, fenix, crane, treefmt, pre-commit";
      };
      zig = {
        path = ./templates/zig;
        description = "zig";
      };
      haskell = {
        path = ./templates/haskell;
        description = "haskell";
      };
      python = {
        path = ./templates/python;
        description = "python";
      };

      default = self.templates.cpp;
    };
  };
}
