#include <stdio.h>
#include <stdlib.h>

int main(void) 
{
    int num;
    int charCount = 0;
    int lineCount = 0;
    int mod = 0x7F;

   while ((charCount < 50000)) {
        num = rand();
        num = num % mod;

       if (num == 0x0A && (lineCount <= 1000)) {
            lineCount++;
            charCount++;
            printf("%c", num);
        } 
        else if (((num == 0x09) || (num >= 0x20 && num <= 0x7E)) && (charCount <= 50000)) {
            charCount++;
            printf("%c", num);
        }
        if (lineCount == 1000) break;
   }
   return 0; 
}
