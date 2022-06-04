#!/usr/bin/env -S perl -w

`rm -rf compare ; mkdir -p compare`;
`mkdir compare/a`;
`mkdir compare/b`;

$scale = 256;
$scalescale = $scale . "x" . $scale;

foreach $file (`ls output`) {
   $file =~ s/[\x0a\x0d]//g;
   `convert output/$file -resize "$scalescale!" RGB:compare/a/$file`;
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
         `convert references/$file -background black -alpha remove -alpha off -trim -resize "$scalescale!" RGB:compare/b/$base.png`
      }
   }
}

@a = `ls compare/a`;
@b = `ls compare/b`;

foreach $a (@a) {
   $a =~ s/[\x0a\x0d]//g;
   $low = -1;
   foreach $b (@b) {
      $b =~ s/[\x0a\x0d]//g;
      @num = `./trisubdot compare/a/$a compare/b/$b`;
      $num = $num[0] + 0;

      if ($low == -1 || $num < $low) {
         $low = $num;
         $lowest = $b;
      }
   }
   print "$low $a $lowest\n";
}
