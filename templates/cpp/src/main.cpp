#include <iostream>
#include <print>
#include <string>
#include <vector>

// Using Boost for a simple string transformation
#include <boost/algorithm/string.hpp>

int main() {
    std::string message = "hello boost and nix!";

    // Transform string to upper case using Boost
    boost::to_upper(message);

    std::vector<std::string> greetings = {"Hello", "from", "Clang", "Nix", "and", "Boost!"};
    for (const auto &word : greetings) {
        std::print("{} ", word);
    }
    std::println("\nBoost says: {}", message);

    return 0;
}
