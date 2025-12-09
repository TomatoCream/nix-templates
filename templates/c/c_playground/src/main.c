#include <stdio.h>

int main(void) {
    printf("Hello, C!\n");
    char buf[32];
    printf("Address of buf: %p\n", (void*)buf);
    
    // WRONG: buf[0] is a char value, not an address!
    // printf("Address of buf: %p\n", (void*)buf[0]);  // This casts the char value, not the address!
    
    // CORRECT: If you want to use a pointer variable:
    char *ptr = buf;  // ptr points to the first element of buf
    printf("Address via pointer: %p\n", (void*)ptr);
    
    // Also correct: address of the first element explicitly
    printf("Address of buf[0]: %p\n", (void*)&buf[0]);
    return 0;
}

