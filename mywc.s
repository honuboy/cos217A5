//----------------------------------------------------------------------
// mywc.s
// Author: Jonah Johnson and Jeffrey Xu
//----------------------------------------------------------------------

        .section .rodata

newlineStr:
        .string "\n"

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
        .section .bss

lLineCount:
        .skip   8
lWordCount:
        .skip   8
lCharCount:
        .skip   8
iChar:
        .skip   4
iInWord:
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

        .equ    FALSE, 0
        .equ    TRUE, 1


main: 

    // Prolog
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]

    // While loop to iterate through until the end of file
    whileLoop:

    // if ((iChar = getchar()) == EOF) goto endWhileLoop;
    bl      getchar
    adr     w0, iChar
    str     w30, [w0]
    cmp     wzr, w30
    bne     endWhileLoop

    // lCharCount++;
    adr     x0, lCharCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // if (!isspace(iChar)) goto notSpace;
    adr     w0, iChar
    ldr     w0, [w0]
    bl      isspace
    cmp     wzr, w30
    beq     notSpace
    
    // if (!iInWord) goto newlineChecker;
    adr     w0, iInWord
    ldr     w0, [w0]
    cmp     w0, wzr
    beq     newlineChecker

    // lWordCount++;
    adr     x0, lWordCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]
    
    // iInWord = FALSE;
    // DO WE NEED TO DO THIS OR CAN WE JUST USE WZR TO BE FAST????????
    adr     w0, FALSE
    ldr     w0, [w0]
    str     w0, [iInWord]
    
    // goto newlineChecker;
    b       newlineChecker

    notSpace:
    // if (iInWord) goto newlineChecker;
    adr     w0, iInWord
    ldr     w0, [w0]
    cmp     w0, wzr
    bne     newlineChecker

    // iInWord = TRUE;
    adr     w0, iInWord
    mov     w1, 1
    str     w1, [w0]

    newlineChecker:

    // if (iChar != '\n') goto whileLoop;
    adr     w0, iChar
    ldr     w0, [w0]
    mov     w1, newlineStr
    cmp     w0, w1
    beq     whileLoop

    // lLineCount++;
    adr     x0, lLineCount
    ldr     x1, [x0]
    add     x1, x1, 1
    str     x1, [x0]

    // goto whileLoop;
    b whileLoop


    endWhileLoop:

    // if (!iInWord) goto printStatement;
    adr     w0, iInWord
    ldr     w0, [w0]
    cmp     w0, wzr
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