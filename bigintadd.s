//----------------------------------------------------------------------
// bigintadd.s
// Author: Jonah Johnson and Jeffrey Xu
//----------------------------------------------------------------------


// notes of edits: this .equ up here for OADDEND1: not necessary?
// not sure whether or not the line needs to be commented out in 155/178 
// (or somewhere near that, things shift)

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
        // Return the larger of lLength1 and lLength2.
        // long BigInt_larger(long lLength1, long lLength2)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    BIGINTLARGER_STACK_BYTECOUNT, 32
        .equ    LLARGER, 8
        .equ    LLENGTH1, 16
        .equ    LLENGTH2, 24

BigInt_larger:
        // Prolog
        sub     sp, sp, BIGINTLARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, LLENGTH1]
        str     x1, [sp, LLENGTH2]

        // if (lLength1 <= lLength2) goto larger2;
        cmp     x0, x1
        ble     larger2
                                    
        // lLarger = lLength1;
        str     x0, [sp, LLARGER]
        b       returnInt
    
larger2: 
        // lLarger = lLength2;
        str     x1, [sp, LLARGER]

returnInt:
        // return lLarger, epilog
        ldr     x0, [sp, LLARGER]
        ldr     x30, [sp]
        add     sp, sp, BIGINTLARGER_STACK_BYTECOUNT
        ret

        .size BigInt_larger, (. - BigInt_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if 
        // an overflow occurred, and 1 (TRUE) otherwise.
        // int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, 
        // BigInt_T oSum)
        //--------------------------------------------------------------
        
        // Must be a multiple of 16
        .equ    BIGINTADD_STACK_BYTECOUNT, 64

        // stack offsets
        .equ    ULCARRY, 8
        .equ    ULSUM, 16
        .equ    LINDEX, 24
        .equ    LSUMLENGTH, 32
        .equ    OADDEND1, 40
        .equ    OADDEND2, 48
        .equ    OSUM, 56
        
        // LLENGTH, AULDIGITS: struct offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, BIGINTADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, OADDEND1]
        str     x1, [sp, OADDEND2]
        str     x2, [sp, OSUM]

        // Determine the larger length.
        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength);

        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1, LLENGTH]

        // call function BigInt_larger
        bl      BigInt_larger
        
        // lSumLength gets return value
        str     x0, [sp, LSUMLENGTH]

        // Clear oSum's array if necessary.
        // if (oSum->lLength <= lSumLength) goto performAddition;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     performAddition

        // memset(oSum->aulDigits, 0, MAX_DIGITS * 
        // sizeof(unsigned long));
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        mov     w1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

performAddition:
        // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]

        // lIndex = 0;
        mov     x0, 0
        str     x0, [sp, LINDEX]

whileLoop:
        // if (lIndex >= lSumLength) goto endWhileLoop;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endWhileLoop

        // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]

        // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND1]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x2, [x1, x2, lsl 3]
        add     x0, x2, x0
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto 
        // endFirstOverflowCheck;
        // x0 still contains ULSUM, x2 still contains array cell
        cmp     x0, x2
        bhs     endFirstOverflowCheck

        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endFirstOverflowCheck:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND2]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x2, [x1, x2, lsl 3]
        add     x0, x2, x0
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto 
        // endSecondOverflowCheck;
        // x0 still contains ULSUM, x2 still contains array cell
        cmp     x0, x2
        bhs     endSecondOverflowCheck

        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endSecondOverflowCheck:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        str     x0, [x1, x2, lsl 3]

        // lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]

        // goto whileLoop
        b       whileLoop

endWhileLoop: 
        // if (ulCarry != 1) goto setSumLength;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, 1
        bne     setSumLength

        // if (lSumLength != MAX_DIGITS) goto carryOut;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0, MAX_DIGITS
        bne     carryOut

        // return FALSE; epilog
        mov     w0, FALSE
        ldr     x30, [sp]
        add     sp, sp, BIGINTADD_STACK_BYTECOUNT
        ret

carryOut: 
        // oSum->aulDigits[lSumLength] = 1;
        mov     x0, 1
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LSUMLENGTH]
        str     x0, [x1, x2, lsl 3]
        
        // lSumLength++;
        mov     x0, 1
        ldr     x1, [sp, LSUMLENGTH]
        add     x1, x1, x0
        str     x1, [sp, LSUMLENGTH]
        
setSumLength: 
        // oSum->lLength = lSumLength;
        ldr     x0, [sp, LSUMLENGTH]
        ldr     x1, [sp, OSUM]
        str     x0, [x1, LLENGTH]

        // return TRUE; epilog
        mov     w0, TRUE
        ldr     x30, [sp]
        add     sp, sp, BIGINTADD_STACK_BYTECOUNT
        ret

        .size BigInt_add, (. - BigInt_add)
        