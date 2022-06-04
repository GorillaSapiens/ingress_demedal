#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define COLOR(b,x,y) (\
      (b[(y)*w*3+(x)*3] << 16) | \
      (b[(y)*w*3+(x)*3+1] << 8) | \
      (b[(y)*w*3+(x)*3+2]))

#define BLOB(b,x,y) b[(y)*w+(x)]

typedef unsigned short t_blobmap;

int main(int argc, char**argv) {
   if (argc != 4) {
      printf("Usage: %s <w> <h> <rgbfile>\n", argv[0]);
      return -1;
   }

   int w = atoi(argv[1]);
   int h = atoi(argv[2]);
   FILE *f = fopen(argv[3], "rb");
   if (!f) {
      printf("Could not open %s\n", argv[3]);
      return -1;
   }

   unsigned char *image = (unsigned char *) malloc (w*h*3);
   if (image == NULL) {
      printf("line %d Could not malloc %d\n", __LINE__, w*h*3);
      return -1;
   }

   if (w*h*3 != fread(image, 1, w*h*3, f)) {
      printf("line %d Could not read %d\n", __LINE__, w*h*3);
      return -1;
   }
   fclose(f);

   t_blobmap *blobmap = (t_blobmap *) calloc (w*h, sizeof(t_blobmap));
   if (blobmap == NULL) {
      printf("line %d Could not malloc %ld\n", __LINE__, w*h * sizeof(t_blobmap));
      return -1;
   }

   int blobnum = 0;
   int changes = 0;

again:

   // fills blobmap
   do {
      for (int y = 1; y < h-1; y++) {
         for (int x = 1; x < w-1; x++) {
            t_blobmap us = BLOB(blobmap,x,y);
            if (us != 0) {
               changes = 0;
               for (int dx = -1; dx < 2; dx++) {
                  for (int dy = -1; dy < 2; dy++) {
                     t_blobmap neighbor = BLOB(blobmap,x+dx,y+dy);
                     if (neighbor == 0 && COLOR(image,x+dx,y+dy)) {
                        BLOB(blobmap,x+dx,y+dy) = us;
                        changes++;
                     }
                  }
               }
            }
         }
      }
   } while (changes);

   // checks blobmap for new blobs
   for (int y = 1; y < h-1; y++) {
      for (int x = 1; x < w-1; x++) {
         if (COLOR(image,x,y) && !BLOB(blobmap,x,y)) {
            blobnum--;
            //blobnum -= 20000;
//fprintf(stderr, "blobnum=%d\n", blobnum);
            BLOB(blobmap,x,y) = blobnum;
            goto again;
         }
      }
   }

   // merges blobmap
merge:
   for (int y = 1; y < h-1; y++) {
      for (int x = 1; x < w-1; x++) {
         t_blobmap us = BLOB(blobmap,x,y);
         if (us != 0) {
            for (int dy = -1; dy < 2; dy++) {
               for (int dx = -1; dx < 2; dx++) {
                  t_blobmap them = BLOB(blobmap,x+dx,y+dy);
                  if (them != 0 && us != them) {
                     for (int y = 1; y < h-1; y++) {
                        for (int x = 1; x < w-1; x++) {
                           if (BLOB(blobmap,x,y) == us) {
                              BLOB(blobmap,x,y) = them;
                           }
                        }
                     }
                     goto merge;
                  }
               }
            }
         }
      }
   }

   // checks for gaps in line
   int gaps = 0;
   for (int y = 1; y < h-1; y++) {
      for (int x = 1; x < w-1; x++) {
         t_blobmap us = BLOB(blobmap,x,y);
         if (us != 0) {
            for (int ox = w - 1; ox > x; ox--) {
               t_blobmap them = BLOB(blobmap,ox,y);
               if (us == them) {
                  for (int a = x; a < ox; a++) {
                     if (BLOB(blobmap,a,y) != us) {
                        gaps++;
                        BLOB(blobmap,a,y) = us;
                     }
                  }
                  x = ox; // skip ahead
               }
            }
         }
      }
   }
   if (gaps) {
//      fprintf(stderr, "gaps=%d\n",gaps);
      goto merge;
   }

   // separates blobs
deblob:
   t_blobmap us;
   int top, bottom, left, right;

   for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
         us = BLOB(blobmap,x,y);
         if (us != 0) {
            top = bottom = y;
            left = right = x;
            for (int y = 0; y < h; y++) {
               for (int x = 0; x < w; x++) {
                  t_blobmap them = BLOB(blobmap,x,y);
                  if (them == us) {
                     if (y < top) top = y;
                     if (y > bottom) bottom = y;
                     if (x < left) left = x;
                     if (x > right) right = x;
                  }
               }
            }
            int lw = right - left + 1;
            int lh = bottom - top + 1;
            char buf[64];
            sprintf(buf, "blob%d", us);
            printf("%d %d %d %d %s\n", left, top, lw, lh, buf);
            sprintf(buf, "output/blob%d", us);
            FILE *f = fopen(buf, "wb");
            for (int y = top; y <= bottom; y++) {
               for (int x = left; x <= right; x++) {
                  if (BLOB(blobmap,x,y) == us) {
                     fwrite(image + (y*w*3+x*3), 1, 3, f);
                     BLOB(blobmap,x,y) = 0;
                  }
                  else {
                     fwrite("\0\0\0", 1, 3, f);
                  }
               }
            }
            fclose(f);
         }
      }
   }

return 0;
}
