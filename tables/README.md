# Specifications in tabular format

This directory contains the specifications, in particular their lists of valid MSDs, mapped to various formats, that can be used for further processing or look-up. Note that the specification that do not contain a list of valid MSDs will have empty files.

Four files are given for each langauge:

* `msd-human-xx.tbl`: The table giving the MSDs and their mapping to "human" readable formats. The columns are the following:
1. A string (e.g. `01N010000`) that can be used as the collating sequence for ordering the MSDs according to the Category and attribute values as they appear in the specifications, so that e.g. Noun comes before Conjuction or singular before plural;
2. The MSD, e.g. `Nc`
3. The short expansion of the MSD into features (e.g. `Noun common`), where only the values of the attributes are given. Note that only attributes with values are listed (e.g. `Noun common singular` for `Nc-s`) and that Boolean values are marked with a plus or minus before the name of the attribute (e.g. `+Animate` for `Animate=yes`);
4. The long expansions of the MSD into features (e.g. `Noun Type=common`), where pairs `Attribute=value` are given. Again, only attributes with values are listed;
5. For languages that have localised specifications, the MSD in the local language
6. For languages that have localised specifications, the short expansion in the local language
7. For languages that have localised specifications, the long expansion in the local language

* `msd-canon-xx.tbl`: The table giving the MSDs and their mapping to "canonical" MSDs and expansions. The columns are the following:
1. The MSD as defined in the language particular section, e.g. `Ncmsan`
2. The very long expansions of the MSD into features, where pairs `Attribute=value` are given for all attributes defined for the language; in case the attribute is not set it is given the value zero (0), e.g. `Noun Type=common Gender=masculine Number=singular Case=accusative Animate=no VForm=0 Person=0 Negative=0 Degree=0 Definiteness=0 Formation=0 Form=0`;
3. Tne MSD as defined in the common tables (e.g. `Ncmsa--n`) which might have a different ordering of attributes than the language specific ones;
4. The super long expansions of the MSD into features, where pairs `Attribute=value` are given for all attributes defined in the specifications; in case the attribute is not set it is given the value zero (0), e.g. `Noun Type=common Gender=masculine Number=singular Case=accusative Definiteness=0 Clitic=0 Animate=no Owner_Number=0 Owner_Person=0 Owned_Number=0 Case2=0 Human=0 Aspect=0 Negation=0 Class=0 VForm=0 Tense=0 Person=0 Voice=0 Negative=0 Clitic_s=0 Courtesy=0 Transitive=0 Degree=0 Formation=0 Owner_Gender=0 Referent_Type=0 Syntactic_Type=0 Pronoun_Form=0 Wh_Type=0 Inclusion=0 Modific_Type=0 Coord_Type=0 Sub_Type=0 Form=0`;
* `msd-fslib2-xx.xml`: The MSDs expressed as a TEI feature structure library, structured as follows:
- the root element of the file is a TEI division (`<div>`), which, after a short introduction contains
- a feature library (`<fLib>`), giving the definitions of all the categories, attributes and their values as TEI features (`<f>`), e.g. `<f name="CATEGORY" xml:id="N0" xml:lang="en"><symbol value="Noun"/></f>` or `<f name="Type" xml:id="N1.c" xml:lang="en"><symbol value="common"/></f>`); for languages with localisation, the definitions are also given in the local language and connected to the English ones, e.g. `<f name="besedna_vrsta" xml:id="sl-S0" corresp="#N0" xml:lang="sl"><symbol value="samostalnik"/></f>`;
- a feature value library (`<fvLib>`), giving the feature structures (`<fs>`) of all the MSDs for the language, with pointers to the definitions of their features, e.g. `<fs xml:id="Nc" xml:lang="en" feats="#N0 #N1.c"/>`; for languages with localisation, the MSDs are also given in the local language and connected to the English ones;
* `msd-fslib2-xx.xml`: Same as above, but without the feature definitions or pointers; rather, each MSD feature structure directly contains its features, e.g. `<fs xml:id="Nc" xml:lang="en"><f name="CATEGORY"><symbol value="Noun"/></f> <f name="Type"><symbol value="common"/></f></fs>`. Again, languages with localisations have the MSDs expressed in both languages and connected,
`

* `msd.xml`: The common specifications for all languages; the language particular specification should be merged with the common ones; this is done automatically

How to check the validity of the specifications, make the MSD index, and merge them into the common ones is illustrated in the ../Makefile.

