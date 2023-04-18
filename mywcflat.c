/*--------------------------------------------------------------------*/
/* mywcflat.c                                                         */
/* Author: Kok Wei Pua and Cherie Jiraphanphong                       */
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

countLoop:
    if((iChar = getchar()) == EOF) goto countLoopEnd;
    lCharCount++;
    if(!isspace(iChar)) goto else1;
    if(!iInWord) goto endif2;
        lWordCount++;
        iInWord = FALSE;
        goto endif2;
    else1:
    if(iInWord) goto endif2;
        iInWord = TRUE;
    endif2:
    if(iChar != '\n') goto endif3;
        lLineCount++;
    endif3:
    goto countLoop;
countLoopEnd:

if (!iInWord) goto endif4;
    lWordCount++;
endif4: 

printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
return 0;
   
}