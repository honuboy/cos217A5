#include <stdio.h>
#include <stdlib.h>
#include <time.h>

long bytes = 1024; /* Default number of bytes to generate */

int is_valid_char(int val) {
    /* Check if character is in allowed range */
    return (val == 0x09) ||  /* Horizontal tab */
           (val == 0x0A) ||  /* Line feed */
           (val >= 0x20 && val <= 0x7E);
}

int main(argc, argv)
    int argc;
    char *argv[];
{
    long i;

    /* Seed random number generator */
    srand((unsigned int)time(NULL));

    /* Check for user-specified byte count */
    if (argc > 1) {
        bytes = atol(argv[1]);
    }

    /* Generate random characters */
    for (i = 0; i < bytes; i++) {
        int random_val = rand() % 0x7F;

        /* Output only valid characters */
        if (is_valid_char(random_val)) {
            putchar(random_val);
        } else {
            /* Regenerate character if invalid */
            i--;
        }
    }

    return 0;
}