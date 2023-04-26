//--------------------------------------------------------------------
// bigintaddoptopt.s                                                             
// Author: Kok Wei Pua and Cherie Jiraphanphong                       
//--------------------------------------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1
    .equ ARRAY_OFFSET, 8
    .equ SIZE_UNSIGNED_LONG, 8
    .equ MAX_DIGITS, 32768

//--------------------------------------------------------------------

    .section .rodata

//--------------------------------------------------------------------

    .section .data

//--------------------------------------------------------------------

    .section .bss

//--------------------------------------------------------------------
    
    .section .text
    
    //----------------------------------------------------------------
    // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
    // distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
    // overflow occurred, and 1 (TRUE) otherwise. 
    //----------------------------------------------------------------

    // Must be a multiple of 16
    .equ    BIGINT_ADD_STACK_BYTECOUNT, 64

    // Local variable registers:
    ulCarry     .req    x22 // Callee-saved
    ulSum       .req    x23 // Callee-saved
    lIndex      .req    x24 // Callee-saved
    lSumLength  .req    x25 // Callee-saved
    lLarger     .req    x26 // Callee-saved

    // Parameter stack registers: 
    oAddend1    .req    x19 // Callee-saved
    oAddend2    .req    x20 // Callee-saved
    oSum        .req    x21 // Callee-saved

    .global BigInt_add

BigInt_add: 

    // Prolog
    sub     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str     x30, [sp]
    str     x19, [sp, 8]
    str     x20, [sp, 16]
    str     x21, [sp, 24]
    str     x22, [sp, 32]
    str     x23, [sp, 40]
    str     x24, [sp, 48]
    str     x25, [sp, 56]
    str     x26, [sp, 64]

    // Store parameters in registers 
    mov     oAddend1, x0
    mov     oAddend2, x1
    mov     oSum, x2

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [oAddend1] 
    ldr     x1, [oAddend2] 

    // if (lLength1 <= lLength2) goto else1;
    cmp     x0, x1
    ble     else1

    // lLarger = lLength1;
    mov     lLarger, x0
    b       endif1

else1:
    // lLarger = lLength2;
    mov     lLarger, x1

endif1:

    // return lLarger to lSumLength
    mov     lSumLength, lLarger

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr     x2, [oSum]
    cmp     x2, lSumLength
    ble     endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long)); 
    mov     x0, oSum
    add     x0, x0, ARRAY_OFFSET
    mov     x1, 0
    mov     x2, MAX_DIGITS
    mov     x3, SIZE_UNSIGNED_LONG
    mul     x2, x2, x3
    bl      memset


endif2: 
    // ulCarry = 0;
    mov     ulCarry, 0

    // lIndex = 0;
    mov     lIndex, 0


addLoop: 
     
     // ulSum = ulCarry;
    mov     ulSum, ulCarry

    // ulCarry = 0;
    mov     ulCarry, 0

    // ulSum += oAddend1->aulDigits[lIndex];
    add     x0, oAddend1, ARRAY_OFFSET
    ldr     x0, [x0, lIndex, lsl 3]
    add     ulSum, ulSum, x0

    //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    cmp     ulSum, x0
    bhs     endif3

    //ulCarry = 1;
    mov     ulCarry, 1

endif3:
    // ulSum += oAddend2->aulDigits[lIndex];
    add     x0, oAddend2, ARRAY_OFFSET
    ldr     x0, [x0, lIndex, lsl 3]
    add     ulSum, ulSum, x0
 
    //if(ulSum >= oAddend2->aulDigits[lIndex]) goto endif4;  
    cmp     ulSum, x0
    bhs     endif4

    //ulCarry = 1;
    mov     ulCarry, 1

endif4:

    // oSum->aulDigits[lIndex] = ulSum;
    add     x0, oSum, ARRAY_OFFSET
    str     ulSum, [x0, lIndex, lsl 3]

    //lIndex++;
    add     lIndex, lIndex, 1   

    // if (lIndex < lSumLength) goto addLoop 
    cmp     lIndex, lSumLength
    blt     addLoop

addLoopEnd:

    // if (ulCarry != 1) goto endif5;
    cmp     ulCarry, 1
    bne     endif5

    // if (lSumLength != MAX_DIGITS) goto endif6;
    cmp     lSumLength, MAX_DIGITS
    bne     endif6
 
    // return FALSE;
    mov     w0, FALSE
    b       epilog

endif6:

   // oSum->aulDigits[lSumLength] = 1;
    add      x0, oSum, ARRAY_OFFSET 
    mov      x1, 1 
    str      x1, [x0, lSumLength, lsl 3]

   // lSumLength++;
    add     lSumLength, lSumLength, 1

endif5:

    // oSum->lLength = lSumLength;
    str     lSumLength, [oSum]

    
    //return TRUE;
    mov     w0, TRUE

epilog:
    ldr     x30, [sp]
    ldr     x19, [sp, 8]
    ldr     x20, [sp, 16]
    ldr     x21, [sp, 24]
    ldr     x22, [sp, 32]
    ldr     x23, [sp, 40]
    ldr     x24, [sp, 48]
    ldr     x25, [sp, 56]
    ldr     x26, [sp, 64]
    add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    ret 

    .size BigInt_add, (. - BigInt_add)
