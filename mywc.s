//--------------------------------------------------------------------
// mywc.s                                                             
// Author: Kok Wei Pua and Cherie Jiraphanphong                       
//--------------------------------------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1
    .equ EOF, -1

//--------------------------------------------------------------------

    .section .rodata

printfFormatStr:
    .string "%7ld %7ld %7ld\n"

//--------------------------------------------------------------------

    .section .data
lLineCount:
     .quad 0
lWordCount:
     .quad 0
lCharCount:
     .quad 0
iInWord:
     .word FALSE

//--------------------------------------------------------------------

    .section .bss

iChar:
    .skip 4

//--------------------------------------------------------------------
    //----------------------------------------------------------------
    // main comment (modify later)
    //----------------------------------------------------------------

    .section .text

    // Must be a multiple of 16
    .equ    MAIN_STACK_BYTECOUNT, 16

    .global main
    
main:

    // Prolog
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]
    
countLoop:
    // iChar = getchar()
    bl      getchar
    adr     x1, iChar
    str     w0, [x1]

    // if((iChar = getchar()) == EOF) goto countLoopEnd;
    adr     x0, iChar
    ldr     w0, [x0]
    cmp     w0, EOF
    beq     countLoopEnd

    // lCharCount++;
    adr     x0, lCharCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // if(!isspace(iChar)) goto else1;
    adr     x0, iChar
    ldr     w0, [x0]
    bl      isspace
    cmp     w0, FALSE
    beq     else1

    // if(!iInWord) goto endif2;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, FALSE
    beq     endif2

    // lWordCount++;
    adr     x0, lWordCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // iInWord = FALSE;
    adr     x0, iInWord
    mov     w1, FALSE
    str     w1, [x0] 

    // goto endif2;
    b       endif2

else1:
    // if(iInWord) goto endif2;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, TRUE
    beq     endif2

    // iInWord = TRUE;
    adr     x0, iInWord
    mov     w1, TRUE
    str     w1, [x0]

endif2:
    // if(iChar != '\n') goto endif3;
    adr     x0, iChar
    ldr     w0, [x0]
    cmp     w0, '\n'
    bne     endif3

    // lLineCount++;
    adr     x0, lLineCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

endif3:
    // goto countLoop;
    b   countLoop

countLoopEnd:
    // if (!iInWord) goto endif4;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, FALSE
    beq     endif4

    // lWordCount++;
    adr     x0, lWordCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

endif4: 
    // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    adr     x0, printfFormatStr
    adr     x1, lLineCount
    ldr     x1, [x1]
    adr     x2, lWordCount
    ldr     x2, [x2]
    adr     x3, lCharCount
    ldr     x3, [x3]
    bl      printf

    // Epilog and return 0
    mov     w0, 0
    ldr     x30, [sp]
    add     sp, sp, MAIN_STACK_BYTECOUNT
    ret
    
    .size main, (. - main)
    