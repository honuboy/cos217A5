#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TOTAL_CHARS 30000  // Target total number of characters
#define MAX_LINES 1000     // Target number of lines
#define MIN_LINE_LEN 1     // Minimum number of characters per line
#define MAX_LINE_LEN 50    // Maximum number of characters per line

// Function to generate a random valid ASCII character
char generate_random_char() {
    int rand_num;
    do {
        rand_num = rand() % 0x7F; // Generate number in range 0 to 0x7E
    } while (rand_num != 0x09 && rand_num != 0x0A &&
             (rand_num < 0x20 || rand_num > 0x7E)); // Filter invalid chars
    return (char)rand_num;
}

int main() {
    int remaining_chars, lines, line_length, i;
    srand((unsigned int)time(NULL)); // Seed the random number generator

    remaining_chars = TOTAL_CHARS;
    lines = 0;

    while (lines < MAX_LINES && remaining_chars > 0) {
        // Determine the number of characters for this line
        line_length = rand() % (MAX_LINE_LEN - MIN_LINE_LEN + 1) + MIN_LINE_LEN;
        if (line_length > remaining_chars) {
            line_length = remaining_chars; // Adjust for remaining character budget
        }

        // Generate and print the line
        for (i = 0; i < line_length; i++) {
            putchar(generate_random_char());
        }
        putchar('\n'); // Line break
        remaining_chars -= line_length;
        lines++;
    }

    return 0;
}
