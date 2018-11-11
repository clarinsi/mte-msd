val:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | $j schema/mte_tei.rng
	$s -xi -xsl:bin/copy.xsl xml/msd.xml | $j schema/mte_tei.rng

# Test generation of the feature-structure libraries
tst-fs:
	$s -xsl:bin/msd-fslib.xsl xml/msd-en.xml > tmp/fslib-en.xml
	$s -xsl:bin/check-links.xsl tmp/fslib-en.xml
	$s -xsl:bin/expand-fs.xsl tmp/fslib-en.xml > tmp/fslib2-en.xml
	$s -xsl:bin/msd-fslib.xsl xml/msd-sl.xml > tmp/fslib-sl.xml
	$s -xsl:bin/check-links.xsl tmp/fslib-sl.xml
	$s -xsl:bin/expand-fs.xsl tmp/fslib-sl.xml > tmp/fslib2-sl.xml
# Test generation of tables for a couple of languages
tst-tbls:
	bin/msd-tables.pl -specs xml/msd.xml -infiles xml/msd-en.xml -outdir tmp
	bin/msd-tables.pl -specs xml/msd.xml -infiles xml/msd-sl.xml -outdir tmp
# Test generation of MSD index for a couple of languages
tst-indx:
	bin/msd-index.pl en xml-edit/msd-en.xml < xml-edit/msd-en.wfl.txt > tmp/msd-en.msd.xml
	bin/msd-index.pl sl xml-edit/msd-sl.xml < xml-edit/msd-sl.wfl.txt > tmp/msd-sl.msd.xml

###PROCESSING THE XML SOURCE
nohup:
	nohup time make all > nohup.all &
all:	htm tbls

# Generate (in parallel) all the language tables
tbls:
	ls -d xml/msd-*.spc.xml | parallel --gnu --halt 0 --jobs 20 \
	bin/msd-tables.pl -specs xml/msd.xml -infiles {} -outdir tables

# Make HTML version of the specifications
htm:
	rm -f html/*
	$s language=eng localisation=en -xsl:bin/teiHeader2html.xsl xml/msd.xml
	$s -xi -xsl:bin/msd-spec2prn.xsl xml/msd.xml | $s splitLevel=1 - -xsl:bin/msd-prn2html.xsl 
	cp html/msd.html html/index.html

W = /net/mantra/project/www-nl/www/ME/V6
mount:
	rm -fr $W/*
	cp -r xml $W
	cp -r html $W
	cp -r tables $W
	cp -r schema $W
#
cast-all:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | $j schema/mte_tei.rng
	cp xml-edit/msd.xml xml/msd.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-bg.spc.xml > xml/msd-bg.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-bs.spc.xml > xml/msd-bs.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ce.spc.xml > xml/msd-ce.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-cs.spc.xml > xml/msd-cs.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-en.spc.xml > xml/msd-en.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-et.spc.xml > xml/msd-et.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-fa.spc.xml > xml/msd-fa.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-hr.spc.xml > xml/msd-hr.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-hu.spc.xml > xml/msd-hu.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-mk.spc.xml > xml/msd-mk.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-pl.spc.xml > xml/msd-pl.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ro.spc.xml > xml/msd-ro.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ru.spc.xml > xml/msd-ru.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sk.spc.xml > xml/msd-sk.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sl-rozaj.spc.xml > xml/msd-sl-rozaj.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sl.spc.xml > xml/msd-sl.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sr.spc.xml > xml/msd-sr.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-uk.spc.xml > xml/msd-uk.spc.xml
	$s -xi -xsl:bin/copy.xsl xml/msd.xml | $j schema/mte_tei.rng



#### ADDING A NEW LANGUAGE
## Take a new language $L section
L = sq
## create a MSD index for it
## and merge its features into the section with common tables
## complains if this leads to errors
## If necessary, can first make an example lexicon for the specifications on the basis of a full lexicon
## Takes examples from the start of the lexicon, so it should be appropriatelly sorted!
new-lex:
	cat < /xxx//wfl-$L.txt | bin/wfl2exa.pl 5 > xml-edit/msd-sl.wfl.txt
## Make a new MSD index on the basis of the example lexicon
new-msd:
	bin/msd-index.pl $L xml-edit/msd-$L.xml < xml-edit/msd-$L.wfl.txt > xml-edit/msd-$L.msd.xml
## Merge the language specific section with the common one
new-merge:
	$s add=../xml-edit/msd-$L.spc.xml -xsl:bin/msd-merge.xsl xml/msd.xml \
	> xml-edit/msd_with_$L.xml 2> xml-edit/msd-$L.log
# Processes specs from xml-edit/ and puts them into xml/
new-cast:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd-bg.spc.xml xml/msd-bg2.spc.xml

#XML validate TEI source
new-val:
	# $s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | rnv schema/mte_tei.rnc
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | $j schema/mte_tei.rng


##############################################3
#Saxon for funny files (large text nodes, long UTF-8 chars
s = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform
#Default Saxon but doesn't show STDERR (<xsl:message>)
s = java -jar /usr/local/bin/saxon9he.jar
#This one does:
s = java -jar /home/tomaz/bin/saxon9he.jar
#Validation of TEI against RelaxNG schema
j = java -jar /usr/local/bin/jing.jar
