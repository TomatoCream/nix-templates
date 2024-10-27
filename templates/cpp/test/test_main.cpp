#define CATCH_CONFIG_MAIN
#include <catch2/catch_test_macros.hpp>

int add(int a, int b);  // Declaration of the function we're testing


TEST_CASE("Addition works", "[math]") {
    REQUIRE(add(2, 2) == 4);
    REQUIRE(add(0, 0) == 0);
    REQUIRE(add(-1, 1) == 0);
}
