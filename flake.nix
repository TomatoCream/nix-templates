{
  description = "Development environment templates";

  outputs =
    { self }:
    {
      templates = {
        cpp = {
          path = ./templates/cpp;
          description = "C++ development environment with configurable compiler";
        };
        rust = {
          path = ./templates/rust;
          description = "rust";
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
