#! /usr/bin/perl
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
$lang = shift;
print "<table xmlns=\"http://www.tei-c.org/ns/1.0\" xml:lang=\"en\" select=\"$lang\"><row role=\"header\"><cell role=\"label\">MSD</cell></row>";
print "\n";
while (<>) {
  chomp;
  print "<row role=\"msd\"><cell xml:lang=\"en\" select=\"$lang\" role=\"msd\">";
  print;
  print "</cell></row>\n";
}
print "</table>\n";
