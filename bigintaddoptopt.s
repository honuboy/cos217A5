//----------------------------------------------------------------------
// bigintaddoptopt.s
// Author: Jonah Johnson and Jeffrey Xu
//----------------------------------------------------------------------

.equ    FALSE, 0
.equ    TRUE, 1
.equ    MAX_DIGITS, 32768

        .section .rodata

//----------------------------------------------------------------------
        .section .data

//----------------------------------------------------------------------
        .section .bss

//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if 
        // an overflow occurred, and 1 (TRUE) otherwise.
        // int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, 
        // BigInt_T oSum)
        //--------------------------------------------------------------
        
        // Must be a multiple of 16
        .equ    BIGINTADD_STACK_BYTECOUNT, 48

        // register alias
        ULSUM       .req    x6
        LINDEX      .req    x7
        LSUMLENGTH  .req    x22
        OADDEND1    .req    x23
        OADDEND2    .req    x24
        OSUM        .req    x25
                
        // LLENGTH, AULDIGITS: struct offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, BIGINTADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x22, [sp, 8]
        str     x23, [sp, 16]
        str     x24, [sp, 24]
        str     x25, [sp, 32]
        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        // Determine the larger length.
        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength);

        ldr     LSUMLENGTH, [OADDEND1, LLENGTH]
        ldr     x1, [OADDEND2, LLENGTH]
        cmp     LSUMLENGTH, x1
        bgt     clearArray

larger2: 
        // move lLength2 into lSumLength
        mov     LSUMLENGTH, x1

clearArray:
        // Clear oSum's array if necessary.
        // if (oSum->lLength <= lSumLength) goto performAddition;
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        ble     performAddition

        // memset(oSum->aulDigits, 0, MAX_DIGITS * 
        // sizeof(unsigned long));
        mov     x0, OSUM
        add     x0, x0, AULDIGITS
        mov     w1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

performAddition:
        // lIndex = 0;
        mov     LINDEX, 0
        // carry reg = 0
        adds    x0, x0, xzr

        // if (lIndex >= lSumLength) goto endWhileLoop;
        sub     x0, LINDEX, LSUMLENGTH
        cbz     x0, endWhileLoop

whileLoop:
        // x1 gets digit of oAddend1, x2 gets digit of oAddend2
        add     x0, OADDEND1, AULDIGITS
        ldr     x1, [x0, LINDEX, lsl 3]
        add     x0, OADDEND2, AULDIGITS
        ldr     x2, [x0, LINDEX, lsl 3]

        // add two digits together, with the carry flag set by last time
        adcs    ULSUM, x1, x2
        
        // store sum into memory
        add     x0, OSUM, AULDIGITS
        str     ULSUM, [x0, LINDEX, lsl 3]

        // lIndex++
        add     LINDEX, LINDEX, 1
        sub     x0, LSUMLENGTH, LINDEX

        // continue loop if x0 (holding the value LSUMLENGTH - LINDEX)
        // does not hold a value equal to 0; carries out guarded loop
        cbnz    x0, whileLoop

endWhileLoop: 
        // if carry flag = 0 goto setSumLength;
        bcc     setSumLength

        // if (lSumLength != MAX_DIGITS) goto carryOut;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     carryOut

        // return FALSE; epilog
        mov     w0, FALSE
        ldr     x30, [sp]
        ldr     x22, [sp, 8]
        ldr     x23, [sp, 16]
        ldr     x24, [sp, 24]
        ldr     x25, [sp, 32]
        add     sp, sp, BIGINTADD_STACK_BYTECOUNT
        ret

carryOut: 
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, 1
        add     x1, OSUM, AULDIGITS
        str     x0, [x1, LSUMLENGTH, lsl 3]
        
        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1
        
setSumLength: 
        // oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // return TRUE; epilog
        mov     w0, TRUE
        ldr     x30, [sp]
        ldr     x22, [sp, 8]
        ldr     x23, [sp, 16]
        ldr     x24, [sp, 24]
        ldr     x25, [sp, 32]
        add     sp, sp, BIGINTADD_STACK_BYTECOUNT
        ret

        .size BigInt_add, (. - BigInt_add)
