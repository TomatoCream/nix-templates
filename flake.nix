{
  description = "Development environment templates";

  outputs = {
    self,
  }: {
    templates = {
      cpp = {
        path = ./templates/cpp;
        description = "C++ development environment with configurable compiler";
      };

      default = self.templates.cpp;
    };
  };
}
