/*--------------------------------------------------------------------*/
/* mywcflattened.c                                                    */
/* Author: Jonah Johnson & Jeffrey Xu                                 */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{

    whileLoop: 
        if ((iChar = getchar()) == EOF) goto endWhileLoop;
        lCharCount++;
        if (!isspace(iChar)) goto notSpace;
        if (!iInWord) goto newlineChecker;
        lWordCount++;
        iInWord = FALSE;
        goto newlineChecker;
            
    notSpace:
        if (iInWord) goto newlineChecker;
        iInWord = TRUE;
    
    newlineChecker:
        if (iChar != '\n') goto whileLoop;
        lLineCount++;
        goto whileLoop;

    endWhileLoop:
        if (!iInWord) goto printStatement;
        lWordCount++;

    printStatement:
        printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        return 0;
}