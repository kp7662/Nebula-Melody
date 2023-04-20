#include <stdio.h>
#include <stdlib.h>

int main(void) 
{
    int num;
    int charCount = 0;
    int lineCount = 0;
    int mod = 0x7F;

   while ((charCount < 50000) && (lineCount < 1000)) {
        num = rand();
        num = num % mod;

        if((num == 0x09) || (num == 0x0A) || (num >= 0x20 && num <= 0x7E)) {
            printf("%c", num);
            if (num == 0x0A) {
                lineCount++;
            }
            else {
                charCount++;
            }
        }
   }
   return 0; 
}
