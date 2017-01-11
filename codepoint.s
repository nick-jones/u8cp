.intel_syntax noprefix
.text
.globl _utf8_to_codepoint
.globl _codepoint_to_utf8

_utf8_to_codepoint:
  mov dl, [rdi]               /* rdi contains argument #1 (pointer to char, 8 bits required after dereference) */
  mov al, dl                  /* copy char into rax (al for 8 bits) */
  and al, 0xF0                /* 1111xxxx indicating 4 byte length */
  cmp al, 0xF0                /* if the length prefix survived then we have 4 bytes */
  jne cb3                     /* else try 3 (cb3 label) */
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
cb3:
  and al, 0xE0                /* 111xxxxx indicating 3 bytes */
  cmp al, 0xE0                /* if the length prefix survived the "and", then we have 3 bytes */
  jne cb2                     /* else try 2 (cb2 label) */
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
cb2:
  and al, 0xC0                /* 11xxxxxx indicating 2 bytes */
  cmp al, 0xC0                /* if the length prefix survived the "and", then we have 2 bytes */
  jne cb1                     /* else 1 (cb1 label) */
  xor dl, 0xC0                /* remove the length prefix */
  movzx eax, dl               /* use 32 bits since we'll be returning a long */
  sal eax, 6                  /* << 6 */
  movzx edx, byte ptr [rdi+1] /* next char */
  xor edx, 0x80               /* remove the continuation prefix */
  add eax, edx                /* add to codepoint */
  ret
cb1:
  movzx eax, dl               /* otherwise we're just a single byte, nothing to remove */
  ret

_codepoint_to_utf8:
  cmp edi, 0x7F               /* maximum value for one byte */
  jg ub2                      /* if > 0x7F, try 2 bytes */
  mov byte ptr [rsi+1], 0     /* set NULL for string termination */
  mov edx, edi                /* move into edx so we can use the 8 bit register */
  mov byte ptr [rsi], dl      /* set 0th byte to codepoint value */
  mov eax, 0                  /* return successfully */
  ret
ub2:
  cmp edi, 0x7FF              /* maximum value for two bytes */
  jg ub3                      /* if > 0x7FF, try 3 bytes */
  mov byte ptr [rsi+2], 0     /* set NULL for string termination */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x600              /* extraction values, len=6, start=0 */
  bextr eax, eax, edx         /* perform extraction */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+1], al    /* set to 1st byte */
  mov edx, 0x606              /* extraction values, len=6, start=6 */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0xC0                /* indicate # bytes = 2 using length prefix */
  mov byte ptr [rsi], al      /* set to 0th byte */
  mov eax, 0                  /* return successfully */
  ret
ub3:
  cmp edi, 0xFFFF             /* maximum value for three bytes */
  jg ub4                      /* if > 0xFFFF, try 4 bytes */
  mov byte ptr [rsi+3], 0     /* set NULL for string termination */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x600              /* extraction values, len=6, start=0 */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+2], al    /* set to 2nd byte */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x606              /* extraction values, len=6, start=6 */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+1], al    /* set to 1st byte */
  mov edx, 0x60C              /* extraction values, len=6, start=12 */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0xE0                /* indicate # bytes = 3 using length prefix */
  mov byte ptr [rsi], al      /* set to 0th byte */
  mov eax, 0                  /* return successfully */
  ret
ub4:
  cmp edi, 0x10FFFF           /* maximum for a 4 byte sequence */
  jg err                      /* > 0x10FFFF, error */
  mov byte ptr [rsi+4], 0     /* set NULL for string termination */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x600              /* extraction values, len=6, start=0 */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+3], al    /* set to 3rd byte */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x606              /* extraction values, len=6, start=6 */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+2], al    /* set to 2nd byte */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x60C              /* extraction values, len=6, start=12 */
  bextr eax, eax, edx         /* perform extraction  */
  or eax, 0x80                /* add continuation prefix */
  mov byte ptr [rsi+1], al    /* set to 1st byte */
  mov eax, edi                /* edi contains (unsigned long) codepoint */
  mov edx, 0x612              /* extraction values, len=6, start=18 */
  bextr eax, eax, edx         /* perform extraction  */
  or  eax, 0xF0               /* indicate # bytes = 4 using length prefix */
  mov byte ptr [rsi], al      /* set to 0th byte */
  mov eax, 0                  /* return successfully */
  ret
err:
  mov eax, 1                  /* return failure */
  ret
