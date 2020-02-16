#! /usr/local/bin/perl
# From an example MULTEXT-type lexicon makes TEI table where each row containsŽ:
# a) MSD (in English)
# b) its expansions to features (in English)
# c) type count (i.e. how many times this MSD appears in the lexicon
# d) token counts (if they are included in the lexicon)
# f) localised MSD (if MSDs are localised in the specifications)
# g) localised features (if features are localised in the specifications)
# h) examples of usage
# NB: the langauge(s) that have f) and/or g) are explicitly coded below
#
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
use File::Spec;
use FindBin qw($Bin);
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory

my $lang = shift;
my $specF = shift;
my $specFile = File::Spec->rel2abs($specF);

#Error mark in MSDs if illegal. 
# Should be the same as in msd-expand2text.xsl and msd-convert2text.xsl!
$err = '@';

$tmpD = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tmpD, CLEANUP => 0);

#my $SAXON   = 'java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform';
#my $SAXON   = "java -jar /usr/local/bin/saxon9he.jar";
my $SAXON   = "java -jar /home/tomaz/bin/saxon9he.jar";
my $DRESS   = "$Bin/dress-msd.pl $lang";
my $EXPAND  = "$Bin/msd-expand2text.xsl";

my $tokcount  = 0; #Do we have the MSD token count in the lexicon?
while (<>) {
    chomp;
    my ($word, $lemma, $msd, $types, $tokens) = split "\t";
    $types{$msd} = $types;
    if ($tokens) {
	$tokens{$msd} = $tokens;
	$tokcount = 1;
    }
    if ($word eq $lemma) {$exa = $lemma}
    else {$exa = "$word/$lemma"}
    push @{$lex{$msd}}, $exa;
}

#Dump the collected MSDs
open OUT, '>:utf8', "$tmpDir/msd.lst";
foreach my $msd (sort keys %types) {
    print OUT "$msd\n"
}
close OUT;

#Dress them as an XML table that expand understands
$COMMAND = "$DRESS < $tmpDir/msd.lst > $tmpDir/msds.xml";
if (system($COMMAND)) {
    print STDERR "ERROR with $COMMAND!\n"
}

#Get collation sequence and expansion to features
$OPTIONS = "output='id collate attval' localise=en";
$COMMAND = "$SAXON specs=$specFile $OPTIONS -xsl:$EXPAND $tmpDir/msds.xml > $tmpDir/expand1.tbl";
if (system($COMMAND)) {
    print STDERR "ERROR with $COMMAND!\n"
}
open TBL, '<:utf8', "$tmpDir/expand1.tbl";
while (<TBL>) {
    chomp;
    my ($msd, $collate, $feats) = split /\t/;
    $collate{$collate} = $msd;
    $feats{$msd} = $feats;
}
close TBL;

#Get localised MSD and expansion to features
#Localisations are available only for a few languages
#Here they are listed explicitly!
if ($lang eq 'sl') {
    $OPTIONS = "output='id msd attval' localise=$lang";
    $COMMAND = "$SAXON specs=$specFile $OPTIONS -xsl:$EXPAND $tmpDir/msds.xml > $tmpDir/expand2.tbl";
    if (system($COMMAND)) {
	print STDERR "ERROR with $COMMAND!\n"
    }
    open TBL, '<:utf8', "$tmpDir/expand2.tbl";
    while (<TBL>) {
	chomp;
	my ($msd, $msd_loc, $feats_loc) = split /\t/;
	$msd_loc{$msd} = $msd_loc;
	$feats_loc{$msd} = $feats_loc;
    }
    close TBL;
    $localised_feats = 1;
    $localised_msds = 1;
}
elsif ($lang eq 'sk' or $lang eq 'uk') {
    $OPTIONS = "output='id attval' localise=$lang";
    $COMMAND = "$SAXON specs=$specFile $OPTIONS -xsl:$EXPAND $tmpDir/msds.xml > $tmpDir/expand2.tbl";
    if (system($COMMAND)) {
	print STDERR "ERROR with $COMMAND!\n"
    }
    open TBL, '<:utf8', "$tmpDir/expand2.tbl";
    while (<TBL>) {
	chomp;
	my ($msd, $feats_loc) = split /\t/;
	$feats_loc{$msd} = $feats_loc;
    }
    close TBL;
    $localised_feats = 1;
    $localised_msds = 0;
}
else {
    $localised_feats = 0;
    $localised_msds = 0;
}

$NS = 'xmlns="http://www.tei-c.org/ns/1.0"';
print "<table $NS xml:id=\"msd.lex-$lang\" xml:lang=\"en\" select=\"$lang\" n=\"msd.lex\">\n";
print "  <head>MSD Index</head>\n";
print "    <row role=\"header\">\n";
print "      <cell role=\"label\">MSD</cell>\n";
print "      <cell role=\"label\">Features</cell>\n";
#Assume that localisation is into the langauge that the specs are describing!
print "      <cell role=\"label\">MSD ($lang)</cell>\n" if $localised_msds;
print "      <cell role=\"label\">Features ($lang)</cell>\n" if $localised_feats;
print "      <cell role=\"label\">Types</cell>\n";
print "      <cell role=\"label\">Tokens</cell>\n" if $tokcount;
print "      <cell role=\"label\">Examples</cell>\n";
print "    </row>\n";

foreach my $col (sort keys %collate) {
    $msd = $collate{$col};
    $clean_msd = $msd;  #MSD without error marks
    $clean_msd =~ s/\Q$err\E//g;
    print "    <row role=\"msd\">";
    print "<cell role=\"msd\" xml:lang=\"en\">$msd</cell>";
    print "<cell role=\"attval\" xml:lang=\"en\">$feats{$msd}</cell>";
    print "<cell role=\"msd\" xml:lang=\"$lang\">$msd_loc{$msd}</cell>" if $localised_msds;
    print "<cell role=\"attval\" xml:lang=\"$lang\">$feats_loc{$msd}</cell>" if $localised_feats;
    print "<cell>$types{$clean_msd}</cell>";
    print "<cell>$tokens{$clean_msd}</cell>" if $tokcount;
    my $exas = join(", ", @{$lex{$clean_msd}});
    print "<cell xml:lang=\"$lang\">$exas</cell>";
    print "</row>\n";
}
print "</table>\n";
