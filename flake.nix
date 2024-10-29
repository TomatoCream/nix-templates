{
  description = "Development environment templates";

  outputs = {self}: {
    templates = {
      cpp = {
        path = ./templates/cpp;
        description = "C++ development environment with configurable compiler";
      };
      haskell = {
        path = ./templates/haskell;
        description = "haskell";
      };

      default = self.templates.cpp;
    };
  };
}
