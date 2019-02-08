#!/usr/bin/perl -w
# MULTEXT-East Morphosyntactic Specifications munging
# Driver program that uses XSLT scripts to make various MSD related tables
# 
# Toma&zcaron; Erjavec
#
use utf8;
use Getopt::Long;
use File::Spec;
use FindBin qw($Bin);
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
$tmpDir = "$Bin/tmp";
my $tempdir = tempdir(DIR => $tmpDir, CLEANUP => 0);

GetOptions("specs=s"   => \$specF,     #File with common specifications
	   "infiles=s" => \$inFileS,   #Files with language specific specifications
	   "outdir=s"  => \$outDir     #Output directory
          );
die "Need common specification file!\n" unless $specF;
my $specFile = File::Spec->rel2abs($specF) ;
die "Need language specific input files!\n" unless $inFileS;
die "Need output directory!\n" unless $outDir;
@infiles = glob($inFileS);

#Used programs
#Use for "funny" files:
#my $SAXON   = 'java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform';
#my $SAXON   = "java -jar /usr/local/bin/saxon9he.jar";
my $SAXON   = "java -jar /home/tomaz/bin/saxon9he.jar";
my $EXPAND  = "$Bin/msd-expand2text.xsl";
my $CONVERT = "$Bin/msd-convert2text.xsl";
my $FSLIB   = "$Bin/msd-fslib.xsl";
my $FSEXP   = "$Bin/expand-fs.xsl";
my $DRESS   = "$Bin/dress-msd.pl";
#my JING = 'java -jar /usr/local/bin/jing.jar'; #Not used

#Various combinations of options to pass to the scripts
my $check   = "output='check'";
my $chuman  = "output='collate id val attval'";
my $lhuman  = "output='id val attval'";
my $slhuman = "output='msd val attval'";
my $canon   = "output='id attval' canonical=full";
my $common  = "common=true";
my $cspecs  = "specs=$specFile"; 
my $clocal  = "localise=en";

foreach $inF (@infiles) {
    my $inFile = File::Spec->rel2abs($inF) ;
    ($fname) = $inFile =~ m|([^/]+\.xml)$|;
    if (($lg) = $fname =~ /-([a-z-]+)\./) {
	print STDERR "Processing $lg: $inFile\n";
    }
    else {next}
    my $lspecs = "specs=$inFile"; 
    my $llocal = "localise=$lg";

    #$localised = `$SAXON lang=$lg -xsl:check-localisation.xsl $inFile`;
    #print STDERR ">>$lg / $localised\n" if $localised;

    # $tmp0 = "$outDir/msd-lspecs-$lg.err";
    # run_command("$SAXON $lspecs $check $EXPAND $inFile > $tmp0", $tmp0);

    $tmp6 = "$outDir/msd-fslib-$lg.xml";
    $COMMAND = "$SAXON -xsl:$FSLIB $inFile";
    #print STDERR "INFO1: doing $COMMAND\n";
    run_command("$COMMAND > $tmp6", $tmp6);

    $tmp7 = "$outDir/msd-fslib2-$lg.xml";
    $COMMAND = "$SAXON -xsl:$FSEXP $tmp6";
    run_command("$COMMAND > $tmp7", $tmp7);

    ### Hopefully no longer needed!
    # #if ($lg eq 'sl' or $lg eq 'sk' or $lg eq 'uk') {
    # if ($lg eq 'sl') {
    # 	$tmp6a = "$outDir/msd-fslib-$lg.$lg.xml";
    # 	$COMMAND = "$SAXON -xsl:$FSLIB $inFile";
    # 	#print STDERR "INFO2: doing $COMMAND\n";
    # 	run_command("$COMMAND > $tmp6a", 
    # 		    $tmp6a);
    # }

    $COMMAND = "$SAXON $lspecs $chuman $clocal -xsl:$EXPAND $inFile";
    #print STDERR "INFO3: doing $COMMAND\n";
    $tmp1 = `$COMMAND`;
    if ($lg eq 'sl' or $lg eq 'sk' or $lg eq 'uk') {
	$tmp2 = "$tempdir/msd-loc.tmp";
	if ($lg eq 'sl') {
	    run_command("$SAXON $lspecs $slhuman $llocal -xsl:$EXPAND $inFile > $tmp2", $tmp2);
	}
	elsif ($lg eq 'sk' or $lg eq 'uk') {
	    run_command("$SAXON $lspecs $lhuman $llocal -xsl:$EXPAND $inFile > $tmp2", $tmp2);
	}
	$i = 0;
	$tmp_human = '';
	open(O, $tmp2) or die "Cant open $tmp2";
	binmode(O,'utf8');
	foreach my $l (split(/\n/,$tmp1)) {
	    $ll = <O>;
	    if ($l eq $ll) {$tmp_human .= "$l"}
	    else {$tmp_human .= "$l\t$ll"}
	}
	close O;
    }
    else {$tmp_human = $tmp1}
    open(O,">$outDir/msd-human-$lg.tbl") or die "Cant open $outDir/msd-human-$lg.tbl";
    binmode(O,'utf8');
    print O $tmp_human;
    close O;

    $tmp3 = "$tempdir/msd-cnv.tmp";
    $COMMAND = "$SAXON $cspecs lang=$lg -xsl:$CONVERT $inFile";
    #print STDERR "INFO4: doing $COMMAND\n";
    run_command("$COMMAND > $tmp3", $tmp3);

    $tmp4 = "$tempdir/msd-cnv.tmp.xml";
    $COMMAND = "cut -f2 $tmp3 | $DRESS $lg";
    #print STDERR "INFO5: doing $COMMAND\n";
    run_command("$COMMAND > $tmp4", $tmp4);

    $COMMAND = "$SAXON $cspecs $common $canon -xsl:$EXPAND";
    #print STDERR "INFO6: doing $COMMAND\n";
    $tmp5 = `$COMMAND $tmp4`;

    $COMMAND = "$SAXON $lspecs $canon -xsl:$EXPAND $inFile";
    #print STDERR "INFO6: doing $COMMAND\n";
    $tmp6 = `$COMMAND`;
    open(O,">$outDir/msd-canon-$lg.tbl") or die "Cant open $outDir/msd-canon-$lg.tbl";
    binmode(O,'utf8');
    $tmp_canon = '';
    @ll = split(/\n/,$tmp5);
    $i = 0;
    foreach my $l (split(/\n/,$tmp6)) {
	if ($ll[$i] and $l eq $ll[$i]) {$tmp_canon .= "$l\n"}
	else {$tmp_canon .= "$l\t$ll[$i]\n"}
	$i++;
    }
    print O $tmp_canon;
    close O;

    # $tmp9 = "$outDir/msd-cspecs-$lg.err";
    # run_command("cut -f3 < $outDir/msd-canon-$lg.tbl | $DRESS $lg | $SAXON $cspecs $common $check -xsl:$EXPAND - > $tmp9", $tmp9);
}

    # $expan = `$SAXON $canon $modes $langs $msdsp -xsl:msd-expand.xsl $specFile`;
    # foreach (split('\n',$expan)) {
    #   if (/./) {
    #     chomp;
    # 	  s|<.+?>||g;
    # 	  ($coll,$rest) = /(.+?)\t(.+)/;
    # 	  $sort{$coll} = $rest;
    # 	  print "$sort{$coll}\n";
    #   }
    # }
sub run_command {
    my $cmd  =  shift;
    my $msg = shift;
  #print STDERR "$cmd\n";
  my $die = system("$cmd 2> $tempdir/err.tmp");
  my $err = `cat $tempdir/err.tmp`;
  if ($die) {
      print STDERR "ERROR ($msg): $err\n"
  }
  elsif ($err =~ /!/) {
      $err =~ s/\n[^!]*\n/\n/gso;
      print STDERR "WARNING:\n$err\n"
  }
}
