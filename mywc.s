//----------------------------------------------------------------------
// mywc.s
// Author: Jonah Johnson and Jeffrey Xu
//----------------------------------------------------------------------

.equ    FALSE, 0
.equ    TRUE, 1
.equ    EOF, -1


        .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
        .section .data

lLineCount:
        .quad 0

lWordCount:
        .quad 0

lCharCount:
        .quad 0

iInWord:
        .word FALSE

//----------------------------------------------------------------------
        .section .bss

iChar:
        .skip   4

//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and 
        // characters are in stdin. A word is a sequence of 
        // non-whitespace characters. Whitespace is defined by the 
        // isspace() function. Return 0.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main: 

    // Prolog
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]

    // While loop to iterate through until the end of file
    whileLoop:

    // if ((iChar = getchar()) == EOF) goto endWhileLoop;
    bl      getchar
    adr     x1, iChar
    str     w0, [x1]
    cmp     w0, EOF
    beq     endWhileLoop

    // lCharCount++;
    adr     x0, lCharCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // if (!isspace(iChar)) goto notSpace;
    adr     x0, iChar
    ldr     w0, [x0]
    bl      isspace
    cmp     w0, FALSE
    beq     notSpace
    
    // if (!iInWord) goto newlineChecker;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, FALSE
    beq     newlineChecker

    // lWordCount++;
    adr     x0, lWordCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]
    
    // iInWord = FALSE;
    // DO WE NEED TO DO THIS OR CAN WE JUST USE WZR TO BE FAST????????
    adr     x0, iInWord
    mov     w1, FALSE
    str     w1, [x0]
    
    // goto newlineChecker;
    b       newlineChecker

    notSpace:
    // if (iInWord) goto newlineChecker;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, TRUE
    beq     newlineChecker

    // iInWord = TRUE;
    adr     x0, iInWord
    mov     w1, TRUE
    str     w1, [x0]

    newlineChecker:

    // if (iChar != '\n') goto whileLoop;
    adr     x0, iChar
    ldr     w0, [x0]
    cmp     w0, '\n'
    bne     whileLoop

    // lLineCount++;
    adr     x0, lLineCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // goto whileLoop;
    b whileLoop

    endWhileLoop:

    // if (!iInWord) goto printStatement;
    adr     x0, iInWord
    ldr     w0, [x0]
    cmp     w0, FALSE
    beq     printStatement

    // lWordCount++;
    adr     x0, lWordCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    printStatement:

    // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    adr     x0, printfFormatStr
    adr     x1, lLineCount
    ldr     x1, [x1]
    adr     x2, lWordCount
    ldr     x2, [x2]
    adr     x3, lCharCount
    ldr     x3, [x3]
    bl      printf
    
    // epilog
    mov     w0, 0 
    ldr     x30, [sp]
    add     sp, sp, MAIN_STACK_BYTECOUNT
    ret

    .size   main, (. - main)
