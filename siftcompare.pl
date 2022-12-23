#!/usr/bin/env -S perl -w

$sift = "ezSIFT/platforms/desktop/build/bin/image_match";

`rm -rf compare ; mkdir -p compare`;
`mkdir compare/a`;
`mkdir compare/b`;

foreach $file (`ls output`) {
   $file =~ s/[\x0a\x0d]//g;
   `convert output/$file compare/a/$file.pgm`;
}

foreach $file (`ls references`) {
   $file =~ s/[\x0a\x0d]//g;
   if (!($file =~ /\.pl/)) {
      @out = `file references/$file`;
      $w = $h = 0;
      $out[0] =~ s/([0-9]*) x ([0-9]*)/$w=$1,$h=$2/ge;

      if ($h != 0 && $w != 0) {
         $base = $file;
         $base =~ s/\..*//g;
         `convert references/$file -background black -alpha remove -alpha off -trim compare/b/$base.pgm`
      }
   }
}

@a = `ls compare/a`;
@b = `ls compare/b`;

foreach $a (@a) {
   $a =~ s/[\x0a\x0d]//g;
   $high = -1;
   foreach $b (@b) {
      $b =~ s/[\x0a\x0d]//g;
      @num = `$sift compare/a/$a compare/b/$b`;
      $num = pop @num;
      $num =~ s/^.*: //g;
      $num = $num + 0;

      if ($high == -1 || $num > $high) {
         $high = $num;
         $highest = $b;
      }
   }
   print "$high $a $highest\n";
}
