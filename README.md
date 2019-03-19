# MULTEXT-East morphosyntactic specifications

This project contains the multilingual MULTEXT-East morphosyntactic specifications in TEI (cf. http://nl.ijs.si/ME/) together with the scripts that are used to process them in various ways. Also included are scripts that help in adding a new langauge to the specifications.

The processing is given in the `Makefile`. It starts from the specifications and example lexicons in the `xml-edit` directory, and produces the "cooked" specifications in the `xml` directory. From these specifications it then generates the HTML version of the specifications in the `html` directory and the specifications in tabular format in the `tables` directory.
