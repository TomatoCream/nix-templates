cmake_minimum_required(VERSION 3.10)
project(cpp-reference)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Option to switch between libc++ (default) and libstdc++
option(USE_LIBCXX "Use LLVM libc++ instead of GNU libstdc++" ON)

if(USE_LIBCXX)
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-stdlib=libc++)
    add_link_options(-stdlib=libc++)
    message(STATUS "Using LLVM libc++")
  else()
    message(FATAL_ERROR "libc++ is only supported with Clang")
  endif()
endif()

# CRITICAL for clangd LSP: This generates compile_commands.json in the build
# directory.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Use mold as the linker if available
# This can also be done via -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=mold"
option(USE_MOLD "Use mold linker" ON)
if(USE_MOLD)
  add_link_options("-fuse-ld=mold")
endif()

# Find Boost components (example: headers only)
find_package(Boost REQUIRED)

add_executable(app src/main.cpp)

# Explicitly add Boost include directories for LSP support in Nix environment.
# While the compiler wrapper usually handles this, making it explicit here
# ensures it appears in compile_commands.json for the LSP.
target_include_directories(app PRIVATE ${Boost_INCLUDE_DIRS})

# Link Boost (even if headers only, this sets up include paths)
target_link_libraries(app PRIVATE Boost::boost)

# --- INSTALLATION ---
# This is required for 'nix build' to work correctly. It tells CMake where to
# put the binary when 'make install' is called.
install(TARGETS app DESTINATION bin)
