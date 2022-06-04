#!/usr/bin/env -S perl -w

# used to generate the first reference.txt

# This is very delicate, any changes at the fevgames end will likely hose this.

@cont = `wget https://fevgames.net/ingress/ingress-guide/concepts/medal/ --quiet -O -`;

sub do_subpage($) {
   my $arg = shift @_;

   if ($arg =~ /characters/) {
      return;
   }

   my @cont = `wget $arg --quiet -O -`;

   my @images = ();

   foreach my $ol (@cont) {
      my $line = $ol;
      $line =~ s/[\x0a\x0d]//g;
      if ($line =~ /data-large-file/) {
         $tmp = $line;
         $tmp =~ s/data-large-file=\"([^"]+)/push @images, $1/ge;
      }
   }

   if ($#images < 0) {
      return;
   }

   print "Bronze $title " . shift(@images) . "\n";
   print "Silver $title " . shift(@images) . "\n";
   print "Gold $title " . shift(@images) . "\n";
   print "Platinum $title " . shift(@images) . "\n";
   print "Onyx $title " . shift(@images) . "\n";
}

foreach $orig_line (@cont) {
   $line = $orig_line;
   $line =~ s/[\x0a\x0d]//g;
   if ($line =~ /^<h2>.*<img/) {
      # limited edition medals, oi vey
      @lems = ();
      $line =~ s/data-large-file=\"([^"]+)/push @lems, $1/ge;
      foreach $lem (@lems) {
         $tmp = $lem;
         $tmp =~ s/^.*\///g;
         $tmp =~ s/\..*//g;
         $tmp =~ s/-/ /g;
         print "Limited Edition $tmp $lem\n";
      }
   }
   elsif ($line =~ /data-image-caption/) {
      $line =~ s/data-image-caption=\"([^"]+)/$caption=$1/ge;
      $caption =~ s/\&lt;/</g;
      $caption =~ s/\&gt;/>/g;
      $caption =~ s/<p>//g;
      $caption =~ s/<\/p>//g;
      $caption =~ s/&#8211;/-/g;
   }
   elsif ($line =~ /data-large-file/) {
      $line =~ s/data-large-file=\"([^"]+)/$file=$1/ge;
      if (length($lasthead)) {
         print "$lasthead ";
      }
      print "$caption $file\n";
   }
   elsif ($line =~ /^<p>/) {
      $tmp = $line;
      $tmp =~ s/<[^>]*>//g;
      $tmp =~ s/\&nbsp;//g;
      $tmp =~ s/The following medals are not covered by one of the other medal categories://g;
      $tmp =~ s/^[ ]+//g;
      $tmp =~ s/[ ]+$//g;
      if ($tmp =~ /^Anomaly medals are /) {
         $tmp = "";
      }
      $lasthead = $tmp;
   }
   elsif ($line =~ /^<li><strong><a title="/) {
      $tmp = $line;
      $tmp =~ s/title=\"([^"]+)\" href=\"([^"]+)/$title=$1,$href=$2/ge;

      do_subpage($href);
   }
   elsif ($line =~ /^<li><strong><a href="/) {
      $tmp = $line;
      $tmp =~ s/^<li><strong><a href=\"([^"]+)\">([^>]+)/$href=$1,$title=$2/ge;

      do_subpage($href);
   }
}

#$state = 0;
#foreach $orig_line (@cont) {
#   $line = $orig_line;
#   $line =~ s/[\x0a\x0d]//g;
#
#   if ($state == 0 && $line =~ /Limited Edition Medals/) {
#      $state = 1;
#   }
#   elsif ($state != 0) {
#      if ($state == 1 && $line =~ /<tr>/) {
#         $state = 2;
#      }
#      elsif ($state == 2) {
#         $line =~ s/\&#8217;/'/g;
#         $line =~ s/<[^>]+>//g;
#         $line = "Limited Edition " . $line;
#         push @lems, $line;
#         $state = 1;
#      }
#   }
#}
#shift @lems;
#print join("\n", @lems) . "\n";
