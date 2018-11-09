#!/usr/bin/perl -w
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
    $max{$msd}++;
    if ($max{$msd} <= $freq) {
	push @{$lex{$msd}}, "$word\t$lemma";
    }
    $msd_type{$msd}++;
    $msd_token{$msd} += $freq
}
foreach $msd (sort keys %lex) {
    foreach $lex (@{$lex{$msd}}) {
	print "$lex\t$msd\t$msd_type{$msd}";
	print "\t$msd_token{$msd}"
	    if exists $msd_token{$msd} and $msd_token{$msd};
	print "\n"
    }
}
