.intel_syntax noprefix
.text
.globl _utf8_to_codepoint

_utf8_to_codepoint:
  mov dl, [rdi]               /* rdi contains argument #1 (pointer to char, 8 bits required after dereference) */
  mov al, dl                  /* copy char into rax (al for 8 bits) */
  and al, 0xF0                /* 1111xxxx indicating 4 byte length */
  cmp al, 0xF0                /* if the length prefix survived then we have 4 bytes */
  jne b3                      /* else try 3 (b3 label) */
  xor dl, 0xF0                /* remove the length prefix */
  movzx eax, dl               /* use 32 bits since we'll be returning a long, zeroing */
  sal eax, 16                 /* << 16 */
  movzx edx, byte ptr [rdi+1] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  sal edx, 12                 /* << 12 */
  add eax, edx                /* add to codepoint */
  movzx edx, byte ptr [rdi+2] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  sal edx, 6                  /* << 6 */
  add eax, edx                /* add to codepoint */
  movzx edx, byte ptr [rdi+3] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  add eax, edx                /* add to codepoint */
  ret
b3:
  and al, 0xE0                /* 111xxxxx indicating 3 bytes */
  cmp al, 0xE0                /* if the length prefix survived the "and", then we have 3 bytes */
  jne b2                      /* else try 2 (b2 label) */
  xor dl, 0xE0                /* remove the length prefix */
  movzx eax, dl               /* use 32 bits since we'll be returning a long */
  sal eax, 12                 /* << 12 */
  movzx edx, byte ptr [rdi+1] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  sal edx, 6                  /* << 6 */
  add eax, edx                /* add to codepoint */
  movzx edx, byte ptr [rdi+2] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  add eax, edx                /* add to codepoint */
  ret
b2:
  and al, 0xC0                /* 11xxxxxx indicating 2 bytes */
  cmp al, 0xC0                /* if the length prefix survived the "and", then we have 2 bytes */
  jne b1                      /* else 1 (b1 label) */
  xor dl, 0xC0                /* remove the length prefix */
  movzx eax, dl               /* use 32 bits since we'll be returning a long */
  sal eax, 6                  /* << 6 */
  movzx edx, byte ptr [rdi+1] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  add eax, edx                /* add to codepoint */
  ret
b1:
  movzx eax, dl               /* otherwise we're just a single byte, nothing to remove */
  ret
