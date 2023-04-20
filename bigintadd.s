//--------------------------------------------------------------------
// bigintadd.s                                                             
// Author: Kok Wei Pua and Cherie Jiraphanphong                       
//--------------------------------------------------------------------
    .equ FALSE, 0
    .equ TRUE, 1

//--------------------------------------------------------------------

    .section .rodata

//--------------------------------------------------------------------

    .section .data

//--------------------------------------------------------------------

    .section .bss

//--------------------------------------------------------------------
    
    .section .text
     
    //----------------------------------------------------------------
    // Return the larger of lLength1 and lLength2. 
    //----------------------------------------------------------------

    // Must be a multiple of 16
    .equ    BIGINT_LARGER_STACK_BYTECOUNT, 32

    // Local variable stack offsets:
    .equ    LLARGER, 8

    // Parameter stack offsets: 
    .equ LLENGTH1, 16
    .equ LLLENGTH2, 24

BigInt_larger:
    
    // Prolog
    sub     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
    str     x30, [sp]
    str     x0, [sp, LLENGTH1]
    str     x1, [sp, LLENGTH2]

    // long lLarger
    
    // if (lLength1 <= lLength2) goto else1;
    ldr     x0, [sp, LLENGTH1]
    ldr     x1, [sp, LLENGTH2]
    cmp     x0, x1
    ble     else1

    // lLarger = lLength1;
    ldr     x0, [sp, LLARGER]
    str     x0, [sp, LLENGTH1]

    // goto endif1;
    b       endif1

else1:

    // lLarger = lLength2;
    ldr     x0, [sp, LLARGER]
    str     x0, [sp, LLENGTH2]

endif1:

    // Epilog and return lLarger;
    ldr     x0, [sp, LLARGER]
    ldr     x30, [sp]
    add     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
    ret 

    .size BigInt_larger, (. - BigInt_larger)

    
    //----------------------------------------------------------------
    // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
    // distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
    // overflow occurred, and 1 (TRUE) otherwise. 
    //----------------------------------------------------------------

    // Must be a multiple of 16
    .equ    BIGINT_ADD_STACK_BYTECOUNT, 64

    // Local variable stack offsets:
    .equ    ULCARRY, 8
    .equ    ULSUM, 16
    .equ    LINDEX, 24
    .equ    LSUMLENGTH, 32

    // Parameter stack offsets: 
    .equ OADDEND1, 40
    .equ OADDEND2, 48
    .equ OSUM, 56

BigInt_add: 

    // Prolog
    sub     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str     x30, [sp]
    str     x0, [sp, OADDEND1]
    str     x1, [sp, OADDEND2]
    str     x2, [sp, OSUM]

    // Determine the larger length.
    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [sp, OADDEND1->LLENGTH]
    ldr     x1, [sp, OADDEND2->LLENGTH]
    bl      BigInt_add
    str     x0, [sp, LSUMLENGTH] 


