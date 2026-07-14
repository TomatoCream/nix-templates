cmake_minimum_required(VERSION 3.20)
project(
  CppProjectTemplate
  VERSION 0.1.0
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use LLVM's libc++ instead of GNU's libstdc++
add_compile_options(-stdlib=libc++)
add_link_options(-stdlib=libc++)

# Export compile commands for LSP support by default
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(main src/main.cpp)

# Minimal install target
install(TARGETS main DESTINATION bin)
