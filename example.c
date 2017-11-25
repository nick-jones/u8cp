#include <stdio.h>
#include "codepoint.h"

int main() {
    // UTF-8
    unsigned long codepoint = utf8_to_codepoint("\xE2\x98\x83\x00");
    char character[5];
    codepoint_to_utf8(codepoint, character);
    printf("%s -- U+%lX\n", character, codepoint); // ☃ -- U+2603
    // UTF-16BE
    codepoint = utf16be_to_codepoint("\xD8\x01\xDC\x37");
    codepoint_to_utf8(codepoint, character);
    printf("%s -- U+%lX\n", character, codepoint); // 𐐷 -- U+10437
    return 0;
}
