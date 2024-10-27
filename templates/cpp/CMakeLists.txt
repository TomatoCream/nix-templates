# CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(cpp_project VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Boost REQUIRED)
find_package(Catch2 3 REQUIRED)

# Main executable
add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE Boost::boost)

# Tests
add_executable(tests test/test_main.cpp src/main.cpp)
target_link_libraries(tests PRIVATE Catch2::Catch2)

enable_testing()
add_test(NAME unit_tests COMMAND tests)
