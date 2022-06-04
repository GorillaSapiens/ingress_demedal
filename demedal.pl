#!/usr/bin/env -S perl -w

`rm -rf output ; mkdir -p output`;

for ($i = 0; $i <= $#ARGV; $i++) {
   print "=== $ARGV[$i]\n";

   $fname = $ARGV[$i];
   $n = int(rand(65536*32768));
   $tmpname = "/tmp/demedal$n";

   if (-e $fname) {
      @out = `file $fname`;
      foreach $line (@out) {
         $h = $w = 0;
         $line =~ s/([0-9]+) x ([0-9]+)/$w=$1,$h=$2/ge; # works for png
         $line =~ s/, ([0-9]+)x([0-9]+),/$w=$1,$h=$2/ge; # works for jpg
         if ($h != 0 && $w != 0) {
            print `convert $fname rgb:$tmpname`;
            @blobs = `./demedal $w $h $tmpname`;
            foreach $blob (@blobs) {
               $blob =~ s/[\x0a\x0d]//g;
               ($x, $y, $w, $h, $f) = split / /, $blob;
               $size = $w . "x" . $h;
               $ar = $w/$h;
               if ($w > 100 && $h > 100 && $ar > .75 && $ar < 1.25) {
                  `convert -size $size -depth 8 RGB:output/$f output/$n-$y-$x.png`;
               }
               `rm output/$f`;
            }
         }
         else {
            print "could not determine size\n";
         }
      }
   }
   else {
      print "'file $fname' failed\n";
   }
}
