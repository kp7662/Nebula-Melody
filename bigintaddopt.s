//--------------------------------------------------------------------
// bigintadd.s                                                             
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
    // Return the larger of lLength1 and lLength2. 
    //----------------------------------------------------------------

    // Must be a multiple of 16
    .equ    BIGINT_LARGER_STACK_BYTECOUNT, 32

    // Local variable registers:
    lLarger     .req    x21 // Callee-saved

    // Parameter registers: 
    lLength1    .req    x19 // Callee-saved
    lLength2    .req    x20 // callee-saved

BigInt_larger:
    
    // Prolog
    sub     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
    str     x30, [sp]
    str     x19, [sp, 8]
    str     x20, [sp, 16]
    str     x21, [sp, 24]

    // store parameters in registers
    mov     lLength1, x19
    mov     lLength2, x20
    
    // long lLarger
    
    // if (lLength1 <= lLength2) goto else1;
    cmp     x0, x1
    ble     else1

    // lLarger = lLength1;
    mov     lLarger, lLength1

    // goto endif1;
    b       endif1

else1:

    // lLarger = lLength2;
    mov     lLarger, lLarger2

endif1:

    // Epilog and return lLarger;
    mov     x0, lLarger
    ldr     x30, [sp]
    ldr     x19, [sp, 8]
    ldr     x20, [sp, 16]
    ldr     x21, [sp, 24]
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

    // Local variable registers:
    // Can we reuse register from the other function
    ulCarry     .req    x25 // Callee-saved
    ulSum       .req    x26 // Callee-saved
    lIndex      .req    x27 // Callee-saved
    lSumLength  .req    x28 // Callee-saved

    // Parameter stack registers: 
    oAddend1    .req    x22 // Callee-saved
    oAddend2    .req    x23 // Callee-saved
    oSum        .req    x24 // Callee-saved

    .global BigInt_add

BigInt_add: 

    // Prolog
    sub     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str     x30, [sp]
    str     x22, [sp, 8]
    str     x23, [sp, 16]
    str     x24, [sp, 24]
    str     x25, [sp, 32]
    str     x26, [sp, 40]
    str     x27, [sp, 48]
    str     x28, [sp, 56]

    // Store parameters in registers 
    mov     oAddend1, x0
    mov     oAddend2, x1
    mov     oSum, x2

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [x0]
    ldr     x1, [x1]
    bl      BigInt_larger
    mov     lSumLength, x0

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr     x2, [x2]
    mov     x3, lSumLength
    cmp     x2, x3
    ble     endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    mov     x2, oSum
    add     x2, x2, ARRAY_OFFSET
    mov     x3, 0
    mov     x4, MAX_DIGITS
    mov     x5, SIZE_UNSIGNED_LONG
    mul     x4, x4, x5
    bl      memset // How does memset know which register to use?

endif2: 
    // ulCarry = 0;
    mov     ulCarry, 0

    // lIndex = 0;
    mov     lIndex, 0

addLoop:

    // if (lIndex >= lSumLength) goto addLoopEnd;
    // Can we override the value of the register set for the parameters
    mov     x3, lIndex
    mov     x4, lSumLength
    cmp     x3, x4
    bge     addLoopEnd

    // ulSum = ulCarry;
    mov     ulSum, ulCarry

    // ulCarry = 0;
    mov     ulCarry, 0

    // Need to check
    // ulSum += oAddend1->aulDigits[lIndex];
    mov     x3, ulSum
    add     x0, x0, ARRAY_OFFSET
    mov     x4, lIndex
    ldr     x0, [x0, x4, lsl 3]
    add     x3, x3, x0
    mov     ulSum, x3
 

    //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    cmp     x3, x0
    bhs     endif3

    //ulCarry = 1;
    mov     ulCarry, 1

endif3:
    // ulSum += oAddend2->aulDigits[lIndex];
    mov     x3, ulSum
    add     x1, x1, ARRAY_OFFSET
    mov     x4, lIndex
    ldr     x1, [x1, x4, lsl 3]
    add     x3, x3, x1
    mov     ulSum, x3
 

    //if(ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;
    cmp     x3, x1
    bhs     endif3

    //ulCarry = 1;
    mov     ulCarry, 1

endif4:

    // oSum->aulDigits[lIndex] = ulSum;
    ldr     x0, [sp, oSum]
    add     x0, x0, ARRAY_OFFSET
    ldr     x1, [sp, lIndex]
    ldr     x2, [sp, ulSum]
    str     x2, [x0, x1, lsl 3]

    //lIndex++;
    ldr     x0, [sp, lIndex]
    add     x0, x0, 1
    str     x0, [sp, lIndex]

    //goto addLoop;
    b       addLoop

addLoopEnd:

    // if (ulCarry != 1) goto endif5;
    ldr     x0, [sp, ulCarry]
    cmp     x0, 1
    bne     endif5

    // if (lSumLength != MAX_DIGITS) goto endif6;
    ldr     x0, [sp, lSumLength]
    cmp     x0, MAX_DIGITS
    bne     endif6
 
    // return FALSE;
    mov     w0, FALSE
    b      epilog

endif6:

   // oSum->aulDigits[lSumLength] = 1;
   ldr      x0, [sp, oSum]
   add      x0, x0, 8
   ldr      x1, [sp, lSumLength]
   mov      x2, 1
   str      x2, [x0, x1, lsl 3]

   // lSumLength++;
    ldr     x0, [sp, lSumLength]
    add     x0, x0, 1
    str     x0, [sp, lSumLength]

endif5:

    // oSum->lLength = lSumLength;
    ldr     x0, [sp, oSum]
    ldr     x1, [sp, lSumLength]
    str     x1, [x0]

    
    //return TRUE;
    mov     w0, TRUE

epilog:
    ldr     x30, [sp]
    add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    ret 

    .size BigInt_add, (. - BigInt_add)
