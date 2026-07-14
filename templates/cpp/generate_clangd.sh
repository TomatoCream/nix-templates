#!/usr/bin/env bash

# Generate .clangd to help LSPs find Nix store paths
echo "CompileFlags:" >.clangd
echo "  Add:" >>.clangd

# Extract include paths from clang++ and filter out GCC
paths=$(clang++ -E -x c++ - -v </dev/null 2>&1 | sed -n '/#include <...> search starts here:/,/End of search list./p' | grep '^ ' | grep -v "gcc" | sed 's/^ *//')

for line in $paths; do
  if [ -n "$line" ]; then
    echo "    - -isystem" >>.clangd
    echo "    - $line" >>.clangd
    # If this is a libcxx path, add the c++/v1 subpath which clangd needs explicitly
    if [ -d "$line/c++/v1" ]; then
      echo "    - -isystem" >>.clangd
      echo "    - $line/c++/v1" >>.clangd
    fi
  fi
done

echo "Generated .clangd with $(grep -c "isystem" .clangd) include paths."
