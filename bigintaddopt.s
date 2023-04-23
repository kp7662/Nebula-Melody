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

    // Local variable stack offsets:
    .equ    lLarger, 8

    // Parameter stack offsets: 
    .equ lLength1, 16
    .equ lLength2, 24

BigInt_larger:
    
    // Prolog
    sub     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
    str     x30, [sp]
    str     x0, [sp, lLength1]
    str     x1, [sp, lLength2]

    // long lLarger
    
    // if (lLength1 <= lLength2) goto else1;
    cmp     x0, x1
    ble     else1

    // lLarger = lLength1;
    ldr     x0, [sp, lLength1]
    str     x0, [sp, lLarger]

    // goto endif1;
    b       endif1

else1:

    // lLarger = lLength2;
    ldr     x0, [sp, lLength2]
    str     x0, [sp, lLarger]

endif1:

    // Epilog and return lLarger;
    ldr     x0, [sp, lLarger]
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
    .equ    ulCarry, 8
    .equ    ulSum, 16
    .equ    lIndex, 24
    .equ    lSumLength, 32

    // Parameter stack offsets: 
    .equ oAddend1, 40
    .equ oAddend2, 48
    .equ oSum, 56

    .global BigInt_add

BigInt_add: 

    // Prolog
    sub     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    str     x30, [sp]
    str     x0, [sp, oAddend1]
    str     x1, [sp, oAddend2]
    str     x2, [sp, oSum]

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [sp, oAddend1]
    ldr     x0, [x0]
    ldr     x1, [sp, oAddend2]
    ldr     x1, [x1]
    bl      BigInt_larger
    str     x0, [sp, lSumLength] 

    // if (oSum->lLength <= lSumLength) goto endif2;
    ldr     x0, [sp, oSum]
    ldr     x0, [x0]
    ldr     x1, [sp, lSumLength]
    cmp     x0, x1
    ble     endif2

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr     x0, [sp, oSum]
    add     x0, x0, ARRAY_OFFSET //arrayoffset later
    mov     x1, 0
    mov     x2, MAX_DIGITS
    mov     x3, SIZE_UNSIGNED_LONG
    mul     x2, x2, x3 
    bl      memset 

endif2: 
    // ulCarry = 0;
    mov     x0, 0
    str     x0, [sp, ulCarry]

    // lIndex = 0;
    str     x0, [sp, lIndex]

addLoop:

    // if (lIndex >= lSumLength) goto addLoopEnd;
    ldr     x0, [sp, lIndex]
    ldr     x1, [sp, lSumLength]
    cmp     x0, x1
    bge     addLoopEnd

    // ulSum = ulCarry;
    ldr     x0, [sp, ulCarry]
    str     x0, [sp, ulSum]

    // ulCarry = 0;
    mov     x0, 0
    str     x0, [sp, ulCarry]

    // Need to double check
    // ulSum += oAddend1->aulDigits[lIndex];
    ldr     x0, [sp, ulSum]     // put ulSum pointer into x0
    ldr     x1, [sp, oAddend1]  // put oAddend1 pointer into x1
    add     x1, x1, ARRAY_OFFSET   // add array offset (maybe .equ Arrayoffset 8)
    ldr     x2, [sp, lIndex]    // put lIndex pointer into x2
    ldr     x1, [x1, x2, lsl 3] // put oAddend1->aulDigits[lIndex] into x1
    add     x0, x0, x1          // add oAddend1->aulDigits[lIndex] to ulSum
    str     x0, [sp, ulSum]     // store result into ulSum 

    //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    cmp     x0, x1
    bhs     endif3

    //ulCarry = 1;
    mov     x0, 1
    str     x0, [sp, ulCarry]

endif3:
    // pending confirmation from Line 152
    // ulSum += oAddend2->aulDigits[lIndex];
    ldr     x0, [sp, ulSum]     // put ulSum pointer into x0
    ldr     x1, [sp, oAddend2]  // put oAddend2 pointer into x1
    add     x1, x1, ARRAY_OFFSET  // add array offset (maybe .equ Arrayoffset 8)
    ldr     x2, [sp, lIndex]    // put lIndex pointer into x2
    ldr     x1, [x1, x2, lsl 3] // put oAddend1->aulDigits[lIndex] into x1
    add     x0, x0, x1          // add oAddend1->aulDigits[lIndex] to ulSum
    str     x0, [sp, ulSum] 

    // follow the one above
    // if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif4;
    cmp     x0, x1
    bhs     endif4

    //ulCarry = 1;
    mov     x0, 1
    str     x0, [sp, ulCarry]

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
