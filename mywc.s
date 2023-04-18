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
    str     x0, [x1]

    // if((iChar = getchar()) == EOF) goto countLoopEnd;
    adr     x0, iChar
    ldr     w0, [x0]
    cmp     w0, EOF
    beq     countLoopEnd

    // lCharCount++;
    adr     x0, lCharCount
    ldr     x0, [x0]
    add     x0, x0, 1
    str     x0, [x0]

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
    ldr     x0, [x0]
    add     x0, x0, 1
    str     x0, [x0]

    // iInWord = FALSE;
    adr     x0, iInWord
    ldr     w0, [x0]
    str     FALSE, [x0]

    // goto endif2;
    b       endif2

else1:
    // if(iInWord) goto endif2;



countLoopEnd:





