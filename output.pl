#!/usr/bin/env -S perl -w

print "<html>\n";
print "<body>\n";
print "<table>\n";

while (<>) {
   s/[\x0a\x0d]//g;
   ($score,$output,$reference) = split / /;
   print "<tr>\n";
   print "   <td>$score</td>\n";
   print "   <td><img src=output/$output><br>$output</td>\n";
   print "   <td><img src=references/$reference><br>$reference</td>\n";
   print "</tr>\n";
}

print "</table>\n";
print "</body>\n";
print "</html>\n";
