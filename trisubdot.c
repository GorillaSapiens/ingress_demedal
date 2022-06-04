#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main (int argc, char **argv) {
   FILE *a = fopen(argv[1], "rb");
   unsigned char ad[256*256*3];
   fread(ad, 1, 256*256*3, a);
   fclose(a);

   FILE *b = fopen(argv[2], "rb");
   unsigned char bd[256*256*3];
   fread(bd, 1, 256*256*3, b);
   fclose(b);

   int sums[3][3] = {
      { 256*256 - 255 * 4, 256*256 - 255 * 4, 256*256 - 255 * 4 },
      { 256*256 - 255 * 4, 256*256 - 255 * 4, 256*256 - 255 * 4 },
      { 256*256 - 255 * 4, 256*256 - 255 * 4, 256*256 - 255 * 4 }};

   for (int y = 1; y < 254; y++) {
      for (int x = 1; x < 254; x++) {
         int oa = y * 256 * 3 + x * 3;
         for (int dy = -1; dy < 2; dy++) {
            for (int dx = -1; dx < 2; dx++) {
               int ob = (y+dy) * 256 * 3 + (x+dx) * 3;

               int deltar = abs((int)ad[oa+0]-(int)bd[ob+0]);
               int deltag = abs((int)ad[oa+1]-(int)bd[ob+1]);
               int deltab = abs((int)ad[oa+2]-(int)bd[ob+2]);

               int delta = sqrt(deltar*deltar+deltag*deltag+deltab*deltab);

               if (delta < 256) {
                  sums[dx+1][dy+1]--;
               }
            }
         }
      }
   }

   int sum = sums[0][0];

   for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 3; y++) {
         if (sums[x][y] < sum) {
            sum = sums[x][y];
         }
      }
   }

   printf("%d\n", sum);
}
