#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[]) {
    // Seed the random number generator with current time
    srand(time(NULL));

    // Determine number of bytes to generate (default 1024 if not specified)
    long bytes = 1024;
    if (argc > 1) {
        bytes = atol(argv[1]);
    }

    // Generate random characters
    for (long i = 0; i < bytes; i++) {
        // Generate a random number and mod by 0x7F
        int random_val = rand() % 0x7F;

        // Check if the value is in the allowed range
        if ((random_val == 0x09) ||  // Horizontal tab
            (random_val == 0x0A) ||  // Line feed
            (random_val >= 0x20 && random_val <= 0x7E)) {
            
            // Write the character to stdout
            putchar(random_val);
        } else {
            // If the random value is not in the allowed range, 
            // decrement the counter to generate another character
            i--;
        }
    }

    return 0;
}