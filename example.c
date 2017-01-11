#include <stdio.h>
#include "codepoint.h"

int main() {
    char input[] = "\xE2\x98\x83\x00";
    unsigned long codepoint = utf8_to_codepoint(input);
    char character[5];
    int result = codepoint_to_utf8(codepoint, character);
    printf("%s ~ %d -- U+%lX\n", character, result, codepoint); // ☃ -- U+2603
    return 0;
}
