#!/usr/bin/perl -w
#Sorting by frequency doesn't seem to work!
$max = shift;
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
my $freq;
while (<>) {
    chomp;
    ($word, $lemma, $msd, $freq) = split /\t/;
    $freq = 0 unless $freq and $freq =~ /^\d+$/;
    $msd_type{$msd}++;
    $msd_tok{$msd}{"$word\t$lemma"} += $freq
}
foreach $msd (sort keys %msd_type) {
    $i = 0;
    foreach $lex 
	(sort {$msd_tok{$msd}{$a} <=> $msd_tok{$msd}{$b} 
	       or $b cmp $a} 
	 keys %{$msd_tok{$msd}}) {
	    if ($i < $max) {
		print "$lex\t$msd\t$msd_type{$msd}\t$msd_tok{$msd}{$lex}\n";
		$i++
	    }
    }
}
