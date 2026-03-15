{pkgs, ...}: {
  # Configure treefmt for project-wide formatting
  projectRootFile = "flake.nix";
  package = pkgs.treefmt;
  programs = {
    alejandra.enable = true; # Nix formatter
    clang-format.enable = true; # C++ formatter (requires .clang-format)
    cmake-format.enable = false; # Disabled to ignore CMake files
  };
}
