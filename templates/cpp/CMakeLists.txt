# CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(${PROJECT_NAME} VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Enable maximum optimization for benchmarks
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -march=native -flto")

# Find required packages
find_package(Boost REQUIRED)
find_package(Catch2 3 REQUIRED)
find_package(benchmark REQUIRED)

# Main executable
add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE Boost::boost)

# Benchmarks
add_executable(benchmarks
  benchmark/main.cpp
  # Add more benchmark files here
)

target_link_libraries(benchmarks PRIVATE
  benchmark::benchmark
  benchmark::benchmark_main
  Boost::boost
)

# Custom target for running benchmarks
add_custom_target(run-benchmarks
  COMMAND benchmarks
    --benchmark_format=json
    --benchmark_out=benchmark_results.json
    --benchmark_out_format=json
    --benchmark_counters_tabular=true
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  DEPENDS benchmarks
)
