#include <stdio.h>
#include "codepoint.h"

int main() {
    char character[] = "\xE2\x98\x83\x00";
    unsigned long codepoint = utf8_to_codepoint(character);
    printf("%s -- U+%lX\n", character, codepoint); // ☃ -- U+2603
    return 0;
}
