#!/usr/bin/perl -w
# From a MULTEXT-type lexicon takes $max examples of each MSD
$max = shift;
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
my $has_freq;
while (<>) {
    chomp;
    ($word, $lemma, $msd, $freq) = split /\t/;
    $has_freq = 1 if $freq and $freq =~ /^\d+$/;
    $freq = 0 unless $freq;
    $max{$msd}++;
    if ($max{$msd} <= $max) {
	push @{$lex{$msd}}, "$word\t$lemma";
    }
    $msd_type{$msd}++;
    $msd_token{$msd} += $freq
}
foreach $msd (sort keys %lex) {
    foreach $lex (@{$lex{$msd}}) {
	print "$lex\t$msd\t$msd_type{$msd}";
	print "\t$msd_token{$msd}"
	    if $has_freq;
	print "\n"
    }
}
