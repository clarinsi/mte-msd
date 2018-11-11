# Editable specifications

This directory contains the specifications that can be edited or where
new langauge specifications can be added.

Four files are relevant for each langauge:
* `msd-xx.spc.xml`: The language particular specifications with definitions of features
* `msd-xx.wfl.xml`: An example lexicon that should contain ~5 entries for each valid MSD
* `msd-xx.msd.xml`: The MSD index which is a part of the specifications, and is automatically generated from the example lexicon
* `msd.xml`: The common specifications for all languages; the language particular specification should be merged with the common ones; this is done automatically

How to check the validity of the specifications, make the MSD index, and merge them into the common ones is illustrated in the ../Makefile.

