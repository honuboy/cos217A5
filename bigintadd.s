//----------------------------------------------------------------------
// bigintadd.s
// Author: Jonah Johnson and Jeffrey Xu
//----------------------------------------------------------------------

.equ    FALSE, 0
.equ    TRUE, 1
.equ    OADDEND1, 48
.equ    ULCARRY, 24
.equ    LLENGTH, 0
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
        .equ    BIGINTLARGER_STACK_BYTECOUNT, 16
        .equ    LLARGER, 8

BigInt_larger:
        // Prolog
        sub     sp, sp, BIGINTLARGER_STACK_BYTECOUNT
        str     x30, [sp]

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

        .equ    BIGINTLARGER_STACK_BYTECOUNT, 48
        .equ    ULCARRY, 8
        .equ    ULSUM, 16
        .equ    LINDEX, 24
        .equ    LSUMLENGTH, 32
        .equ    AULDIGITS, 8
        .equ    SIZEOFUL, 8
        .req    OADDEND1, x5
        .req    OADDEND2, x6
        .req    OSUM, x7
        

BigInt_add:
        // Determine the larger length.
        // lSumLength = BigInt_larger(oAddend1->lLength, 
        // oAddend2->lLength);

        ldr     OADDEND1, x0 
        ldr     OADDEND2, x1
        ldr     OSUM, x2

        // x0 gets oAddend1->lLength, similar for x1
        ldr     x0, [x0]
        ldr     x1, [x1]

        // call function BigInt_larger
        bl      BigInt_larger
        
        // lSumLength gets return value
        str     x30, [sp, LSUMLENGTH]

        // Clear oSum's array if necessary.
        // if (oSum->lLength <= lSumLength) goto performAddition;
        cmp     [OSUM], x30
        ble     performAddition

        // memset(oSum->aulDigits, 0, MAX_DIGITS * 
        // sizeof(unsigned long));
        add     x0, OSUM, AULDIGITS
        mov     w1, 0
        mul     OSUM, MAX_DIGITS, SIZEOFUL
        bl      memset

performAddition:
        // ulCarry = 0;
        ldr     x0, [sp, ULCARRY]
        mov     x1, 0
        str     x1, [x0]

        // lIndex = 0;
        ldr     x0, [sp, LINDEX]
        mov     x1, 0
        str     x1, [x0]

whileLoop:
        // if (lIndex >= lSumLength) goto endWhileLoop;
        add     x0, sp, LINDEX
        ldr     x0, [x0]
        add     x1, sp, LSUMLENGTH
        ldr     x1, [x1]
        cmp     x0, x1
        bge     endWhileLoop

        // ulSum = ulCarry;






// CAN WE DO THIS? OR DO WE NEED TO MAKE SLOW AND UGLY WITH LDR AND MOV AND WHATNOT







        add     x0, sp, ULCARRY
        ldr     x0, [x0]
        str     x0, [sp, ULSUM]

        // ulCarry = 0;
        ldr     x0, [sp, ULCARRY]
        mov     x1, 0
        str     x1, [x0]


        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, OADDEND1
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x3, [x1, x2, lsl 3]
        ldr     x4, [x0]
        add     x4, x4, [x3]
        str     x0, x4

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto 
        // endFirstOverflowCheck;
        ldr     x0, [sp, ULSUM]
        ldr     x1, OADDEND1
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x3, [x1, x2, lsl 3]
        ldr     x4, [x0]
        cmp     x4, x3
        bge     endFirstOverflowCheck

        // ulCarry = 1;
        ldr     x0, [sp, ULCARRY]
        mov     x1, 1
        str     x1, [x0]

endFirstOverflowCheck:
        // ulSum += oAddend2->aulDigits[lIndex];


// if previous logic sucks, this will too
// just copy and paste, change OADDEND 2 TO 1


        ldr     x0, [sp, ULSUM]
        ldr     x1, OADDEND2
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x3, [x1, x2, lsl 3]
        ldr     x4, [x0]
        add     x4, x4, [x3]
        str     x0, x4
        
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endSecondOverflowCheck;
        ldr     x0, [sp, ULSUM]
        ldr     x1, OADDEND2
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x3, [x1, x2, lsl 3]
        ldr     x4, [x0]
        cmp     x4, x3
        bge     endSecondOverflowCheck

        // ulCarry = 1;
        ldr     x0, [sp, ULCARRY]
        mov     x1, 1
        str     x1, [x0]

endSecondOverflowCheck:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, OSUM
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        add     x0, x0, x1, lsl 3
        ldr     x3, [sp, ULSUM]
        str     x3, [x0]

        // lIndex++;