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
    ldr     x0, [sp, OADDEND1]
    ldr     x0, [x0]
    ldr     x1, [sp, OADDEND2]
    ldr     x1, [x1]
    bl      BigInt_add
    str     x0, [sp, LSUMLENGTH] 

    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

endif2:

    // ulCarry = 0;
    mov     x0, 0
    adr     x1, ULCARRY
    str     x0, [x1]

    // lIndex = 0;
    mov     x0, 0
    adr     x1, LINDEX
    str     x0, [x1]

addLoop:

    // if (lIndex >= lSumLength) goto addLoopEnd;
    adr     x0, LINDEX
    ldr     x0, [x0]
    adr     x1, LSUMLENGTH
    ldr     x1, [x1]
    cmp     x0, x1
    bge     addLoopEnd

    // ulSum = ulCarry;
    ldr     x0, [sp, ULCARRY]
    str     x0, [sp, ULSUM]

    // ulCarry = 0;
    mov     x0, 0
    adr     x1, ULCARRY
    str     x0, [x1]

    // ulSum += oAddend1->aulDigits[lIndex];
    ldr     x0, [sp, ULSUM]
    ldr     x0, [x0]
    ldr     x1, [sp, LINDEX]
    ldr     x1, [x1]
    ldr     x2, [sp, OADDEND1]
    add     x2, x2, 8
    str     x0, [x2, x2, lsl [x1]]

    //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif3;
    ldr     x0, [sp, ULSUM]
    ldr     x0, [x0]
    ldr     x1, [sp, LINDEX]
    ldr     x1, [x1]
    ldr     x2, [sp, OADDEND1]
    add     x2, x2, 8
    cmp     x0, [x2, x2, lsl [x1]]
    bge     endif3

    //ulCarry = 1;
    mov     x0, 1
    adr     x1, ULCARRY
    str     x0, [x1]

endif3:

    // ulSum += oAddend1->aulDigits[lIndex];
    ldr     x0, [sp, ULSUM]
    ldr     x0, [x0]
    ldr     x1, [sp, LINDEX]
    ldr     x1, [x1]
    ldr     x2, [sp, OADDEND1]
    add     x2, x2, 8
    str     x0, [x2, x2, lsl [x1]] 

    //if(ulSum >= oAddend1->aulDigits[lIndex]) goto endif4;
    ldr     x0, [sp, ULSUM]
    ldr     x0, [x0]
    ldr     x1, [sp, LINDEX]
    ldr     x1, [x1]
    ldr     x2, [sp, OADDEND1]
    add     x2, x2, 8
    cmp     x0, [x2, x2, lsl [x1]]
    bge     endif3

    //ulCarry = 1;
    mov     x0, 1
    adr     x1, ULCARRY
    str     x0, [x1]

endif4:

    // oSum->aulDigits[lIndex] = ulSum;
    ldr     x0, [sp, OSUM]
    add     x0, x0, 8
    ldr     x1, [sp, LINDEX]
    ldr     x0, [x0, x1, lsl [x1]]
    str     x0, [sp, ULSUM]

    //lIndex++;
    adr     x0, LINDEX
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    //goto addLoop;
    b       addLoop

addLoopEnd:

    // if (ulCarry != 1) goto endif5;
    ldr     x0, [sp, OSUM]
    cmp     x0, 1
    bne     endif5


    // if (lSumLength != MAX_DIGITS) goto endif6;
    ldr     x0, [sp, LSUMLENGTH]
    cmp     x0, 1
    bne     endif5

    // return FALSE;
    mov     x30, FALSE
    ret 

endif6:

   // oSum->aulDigits[lSumLength] = 1;
   ldr      x0, [sp, OSUM]
   add      x0, x0, 8
   ldr      x1, [sp, LSUMLENGTH]
   str      1, [x0, x1, lsl [x1]]

   // lSumLength++;
    adr     x0, LSUMLENGTH
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

endif5:

    // oSum->lLength = lSumLength;
    ldr     x0, [sp, OSUM]
    ldr     x0, [x0]
    ldr     x1, [sp, LSUMLENGTH]
    str     x1, [x0]

    // return TRUE;
    mov     x30, TRUE
    ret 
    
    // Epilog and return TRUE;
    mov     x30, TRUE
    ldr     x30, [sp]
    add     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
    ret 

    .size BigInt_add, (. - BigInt_add)


