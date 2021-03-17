#Validate XML of xml-edit and xml
val:
	xmllint --xinclude xml-edit/msd.xml | $j schema/mte_tei.rng
	xmllint --xinclude xml/msd.xml | $j schema/mte_tei.rng

## TESTING SCRIPTS
# Test generation of canonical table
tst-can:
	$s specs=../xml/msd-sl.spc.xml output='id attval' canonical=full -xsl:bin/msd-expand2text.xsl xml/msd-sl.spc.xml > tmp/msd-canon1-sl.tbl

# Test generation of fsLib
tst-lib:
	$s select=sl -xsl:bin/msd-fslib.xsl xml/msd-sl.spc.xml > tmp/msd-fslib-sl.xml
# Test generation of tables
tst-tbls:
	bin/msd-tables.pl -specs xml/msd.xml -infiles xml/msd-sl.spc.xml -outdir tmp
# Test generation of the feature-structure libraries
tst-fs:
	$s select=en -xsl:bin/msd-fslib.xsl xml/msd-en.spc.xml > tmp/fslib-en.xml
	$s select=sl -xsl:bin/msd-fslib.xsl xml/msd-sl.spc.xml > tmp/fslib-sl.xml
	$s -xsl:bin/check-links.xsl tmp/fslib-sl.xml
	$s -xsl:bin/expand-fs.xsl tmp/fslib-sl.xml > tmp/fslib2-sl.xml
# Test generation of MSD index for a couple of languages
tst-indx:
	bin/msd-index.pl en xml-edit/msd-en.spc.xml < xml-edit/msd-en.wfl.txt > tmp/msd-en.msd.xml
	bin/msd-index.pl sl xml-edit/msd-sl.spc.xml < xml-edit/msd-sl.wfl.txt > tmp/msd-sl.msd.xml

###PROCESSING THE XML SOURCE
nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	htm tbls-all mount
xall:	cast-all htm tbls-all mount

# Put the publishable part of the resources on the Web
# PLATFORM SPECIFIC!
mount:
	scp xml/* nl.ijs.si:/project/www-nl/www/ME/V6/msd/xml
	scp html/* nl.ijs.si:/project/www-nl/www/ME/V6/msd/html
	scp tables/* nl.ijs.si:/project/www-nl/www/ME/V6/msd/tables
	scp schema/* nl.ijs.si:/project/www-nl/www/ME/V6/msd/schema

### Make HTML version of the specifications
htm:
	rm -f html/*
	$s language=eng localisation=en -xsl:bin/teiHeader2html.xsl xml/msd.xml
	$s -xi -xsl:bin/msd-spec2prn.xsl xml/msd.xml | $s splitLevel=1 - -xsl:bin/msd-prn2html.xsl
	cp html/msd.html html/index.html
	cp mte.css html/

# Generate (in parallel) all the language tables
tbls-all:
	ls -d xml/msd-*.spc.xml | parallel --gnu --halt 0 --jobs 20 \
	bin/msd-tables.pl -specs xml/msd.xml -infiles {} -outdir tables

### Convert root to its final (and redundant) form
cast-root:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | $j schema/mte_tei.rng
	$s -xsl:bin/msd-castspecs.xsl xml-edit/msd.xml > xml/msd.xml

### Convert all editable specifications to their final (and redundant) form
cast-all:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | $j schema/mte_tei.rng
	$s -xsl:bin/msd-castspecs.xsl xml-edit/msd.xml > xml/msd.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-bg.spc.xml > xml/msd-bg.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ce.spc.xml > xml/msd-ce.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-cs.spc.xml > xml/msd-cs.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-en.spc.xml > xml/msd-en.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-et.spc.xml > xml/msd-et.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-fa.spc.xml > xml/msd-fa.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-hbs.spc.xml > xml/msd-hbs.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-hr.spc.xml > xml/msd-hr.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-hu.spc.xml > xml/msd-hu.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-mk.spc.xml > xml/msd-mk.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-pl.spc.xml > xml/msd-pl.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ro.spc.xml > xml/msd-ro.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-ru.spc.xml > xml/msd-ru.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sk.spc.xml > xml/msd-sk.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sl-rozaj.spc.xml > xml/msd-sl-rozaj.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sl.spc.xml > xml/msd-sl.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sq.spc.xml > xml/msd-sq.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-sr.spc.xml > xml/msd-sr.spc.xml
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-uk.spc.xml > xml/msd-uk.spc.xml
	$s -xi -xsl:bin/copy.xsl xml/msd.xml | $j schema/mte_tei.rng

#### ADDING A NEW LANGUAGE
## This block illustrates how to add a new language to the specifications:
## 0. If starting from scratch, base new language on most similar language(s) in the current specs,
##    then edit the new specifications so that they are ok
## 1. Create an MSD index for the language from the lexicon
## 2. Merge the language specific features into the section with common tables
## 3. Hand edit the common section so that it documents the inclusion of the new language
## 4. Move the langauge specific section from the editable folder xml-edit to the official folder xml-edit

new-nohup:
	nohup time make new-lang > nohup.new &

new-lang:	new-lex new-msds new-val new-cast new-tbls htm mount
xxxnew-lang:	new-split new-lex new-msds new-val new-merge new-cast new-tbls htm mount

## Name of the new language
NL = ka

# Test generation of new draft language specific section
## These will, of course, then need lots of hand editing!
## Once done, move msd-${NL}.spc.xml from tmp/ to xml-edit
new-split:
	$s in-langs='et hu' out-lang='${NL}' -xsl:bin/msd-split.xsl xml/msd.xml > tmp/msd-${NL}.spc.xml

##  It is assumed that two files have first been added to the project:
##  xml-edit/msd-${NL}.spc.xml: the language specific specifications, without the MSD list
##  lexica/wfl-${NL}.txt: the lexicon of the language in MULTEXT format

## First make the example lexicon on the basis of a full MULTEXT lexicon
## (examples are taken from the start of the lexicon, so it should be appropriatelly sorted!)
new-lex:
	cat < lexica/wfl-${NL}.txt | bin/wfl2exa.pl 5 > xml-edit/msd-${NL}.wfl.txt

## Make a new MSD index on the basis of the example lexicon
new-msds:
	./bin/msd-index.pl ${NL} xml-edit/msd-${NL}.spc.xml \
	< xml-edit/msd-${NL}.wfl.txt > xml-edit/msd-${NL}.msd.xml

## Merge the language specific section with the common one
## The log of the merge is written to xml-edit/msd-${NL}.log
## The output goes into a temporary file xml-edit/msd_with_${NL}.xml

new-merge:
	$s add=../xml-edit/msd-${NL}.spc.xml -xsl:bin/msd-merge.xsl xml-edit/msd.xml \
	> xml-edit/msd_with_${NL}.xml 2> xml-edit/msd-${NL}.log

##HERE comes manual editing
## If the log does not show problems:
# - the temporary files should be edited to include reference to the new specifications
# - and renamed to xml-edit/msd.xml

## Now validate the new specifications
new-val:
	$s -xi -xsl:bin/copy.xsl xml-edit/msd.xml | rnv schema/mte_tei.rnc

# Copies the new files to final xml/ folder and validate
# XInclude the MSD index in the lang. spec. file, but do not XInclude the comment specs
new-cast:
	$s -xi -xsl:bin/msd-castspecs.xsl xml-edit/msd-${NL}.spc.xml > xml/msd-${NL}.spc.xml
	$s -xsl:bin/msd-castspecs.xsl xml-edit/msd.xml > xml/msd.xml
	$s -xi -xsl:bin/copy.xsl xml/msd.xml > msd.tmp
	rnv schema/mte_tei.rnc msd.tmp
	rm msd.tmp

# Generate the language tables for the language
new-tbls:
	bin/msd-tables.pl -specs xml/msd.xml -infiles xml/msd-${NL}.spc.xml -outdir tables
# And this is it, now you can build the HTML

### For testing with a new specifications / lexicon pair
new-try:
	cat < lexica/wfl-${NL}.txt | bin/wfl2exa.pl 5 > xml-edit/msd-${NL}.wfl.txt
	./bin/msd-index.pl ${NL} xml-edit/msd-${NL}.spc.xml \
	< xml-edit/msd-${NL}.wfl.txt > xml-edit/msd-${NL}.msd.xml
	$s add=../xml-edit/msd-${NL}.spc.xml -xsl:bin/msd-merge.xsl xml-edit/msd.xml \
	> xml-edit/msd_with_${NL}.xml 2> xml-edit/msd-${NL}.log

##############################################3
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
