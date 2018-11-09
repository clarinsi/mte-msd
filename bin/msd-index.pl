#! /usr/local/bin/perl
# From an example MULTEXT-type lexicon makes TEI table with 
# a) MSDs, b) their expansions to features, 
# c) type and d) token counts (if they are included in the lexicon)
# f) localised MSD, g) localised features (if they are localised in the specifications)
# h) examples of usage
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

$tmpD = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tmpD, CLEANUP => 1);

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
#and dress them as an XML table that expand understands
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
$OPTIONS = "output='id msd attval' localise=$lang";
$COMMAND = "$SAXON specs=$specFile $OPTIONS -xsl:$EXPAND $tmpDir/msds.xml > $tmpDir/expand2.tbl";
if (system($COMMAND)) {
    print STDERR "ERROR with $COMMAND!\n"
}
close TBL;
if (-z "$tmpDir/expand2.tbl") {$localised = 0}
else {
    $localised = 1;
    while (<TBL>) {
	chomp;
	my ($msd, $msd_loc, $feats_loc) = split /\t/;
	$localised = 1; #if one is localised, they all should be!
	$msd_loc{$msd_en} = $msd_loc;
	$feats_loc{$msd_en} = $long_loc;
    }
    close TBL;
}

$NS = 'xmlns="http://www.tei-c.org/ns/1.0"';
print "<table $NS xml:id=\"msd.lex-$lang\" xml:lang=\"en\" select=\"$lang\" n=\"msd.lex\">\n";
print "  <head>MSD Index</head>\n";
print "    <row role=\"header\">\n";
print "      <cell role=\"label\">MSD</cell>\n";
print "      <cell role=\"label\">Features</cell>\n";
#Assume that localisation is into the langauge that the specs are describing!
if ($localised) {
    print "      <cell role=\"label\">MSD ($lang)</cell>\n";
    print "      <cell role=\"label\">Features ($lang)</cell>\n";
}
print "      <cell role=\"label\">Types</cell>\n";
print "      <cell role=\"label\">Tokens</cell>\n" if $tokcount;
print "      <cell role=\"label\">Examples</cell>\n";
print "    </row>\n";

foreach my $col (sort keys %collate) {
    $msd = $collate{$col};
    print "    <row>";
    print "<cell role=\"msd\" xml:lang=\"en\">$msd</cell>";
    print "<cell role=\"attval\" xml:lang=\"en\">$feats{$msd}</cell>";
    if ($localised) {
	print "<cell role=\"msd\" xml:lang=\"$lang\">$msd_loc{$msd}</cell>";
	print "<cell role=\"attval\" xml:lang=\"$lang\">$feats_loc{$msd}</cell>"
    }
    print "<cell>$types{$msd}</cell>";
    print "<cell>$tokens{$msd}</cell>" if $tokcount;
    my $exas = join(", ", @{$lex{$msd}});
    print "<cell xml:lang=\"$lang\">$exas</cell>";
    print "</row>\n";
}
print "</table>\n";
