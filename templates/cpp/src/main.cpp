#include <iostream>
#include <boost/algorithm/string.hpp>

int add(int a, int b) {
    return a + b;
}

int main() {
    std::string msg = "hello, world";
    boost::to_upper(msg);
    std::cout << msg << std::endl;
    return 0;
}
