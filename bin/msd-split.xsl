<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		xmlns:xi="http://www.w3.org/2001/XInclude"
		exclude-result-prefixes="tei xd xi">
  <xd:doc>
    <xd:desc>
      <xd:p>Extracts language particular specifications from common morphosyntactic tables.
      Used for creating a draft language particular specification on the basis of existing ones present in the
      common tables.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>
  <!-- The union of the features of these languages go into the output -->
  <xsl:param name="in-langs"/>
  <!-- The output language of the draft specifications -->
  <xsl:param name="out-lang"/>

  <xsl:strip-space elements="*"/>
  <!-- Mode can be "brief" or "verbose", the former outputs only the key divisions
       of the lang.part. section, the latter outpus all its parts -->
  <xsl:param name="mode">verbose</xsl:param>

  <!-- Name of the language, should be present in the teiHeader! -->
  <xsl:variable name="langName"
		select="//tei:teiHeader/tei:profileDesc/
			tei:langUsage/tei:language[@ident=$out-lang]"/>
  
  <xsl:variable name="notes">
    <div>
      <head>Notes</head>
      <list>
        <item>Put notes (if there are any) here.</item>
        <item>In there are no notes, delete this div.</item>
      </list>
    </div>
  </xsl:variable>

  <xsl:template match="/">
    <div xmlns="http://www.tei-c.org/ns/1.0" type="part" n="msd-language" select="{$out-lang}">
      <xsl:attribute name="xml:id">
        <xsl:text>msd-</xsl:text>
        <xsl:value-of select="$out-lang"/>
      </xsl:attribute>
      <head>
        <xsl:value-of select="concat($langName, ' Specifications')"/>
      </head>
      <list type="gloss">
	<label>Language Name:</label>
	<item>
          <xsl:value-of select="$langName"/>
	</item>
	<label>Code:</label>
	<item>
          <xsl:value-of select="$out-lang"/>
	</item>
	<label>Reference:</label>
	<item>
	  <!-- Change XXX to the appropriate three letter code for the language -->
	  <ref target="http://www.ethnologue.com/language/XXX">Ethnologue</ref>
	</item>
	<label>Authors of the Specification:</label>
	<item>XXX</item>
      </list>
      <xsl:if test="$mode = 'verbose'">
	<divGen type="subtoc"/>
	<div>
	  <head>
            <xsl:value-of select="concat('Introduction to ', $langName, ' Specifications')"/>
	  </head>
          <p>Here comes the introduction.</p>
	</div>
	<div type="section" select="{$out-lang}">
          <xsl:attribute name="xml:id">
            <xsl:text>msd.categories-</xsl:text>
            <xsl:value-of select="$out-lang"/>
          </xsl:attribute>
	  <head>
            <xsl:value-of select="concat($langName, ' Category Index')"/>
	  </head>
          <divGen type="msd.cats" select="{$out-lang}"/>
	  <xsl:copy-of select="$notes"/>	
	</div>
      </xsl:if>
      <xsl:for-each select="//tei:div[tei:table[@n='msd.cat']]">
        <xsl:variable name="select">
          <xsl:apply-templates mode="select-langs"
			       select="tei:table[@n='msd.cat']/tei:row[@role='type']/tei:cell[@role='lang']">
            <xsl:with-param name="langs" select="$in-langs"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="normalize-space($select)">
          <xsl:variable name="catname"
            select="tei:table[@n='msd.cat']/tei:row[@role='type']/tei:cell[@role='value']"/>
          <xsl:variable name="catcode"
            select="tei:table[@n='msd.cat']/tei:row[@role='type']/tei:cell[@role='code']"/>
          <div type="section" select="{$out-lang}">
            <xsl:attribute name="xml:id">
              <xsl:value-of select="@xml:id"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="$out-lang"/>
            </xsl:attribute>
	    <head>
              <xsl:value-of select="tei:head"/>
	    </head>
            <table n="msd.cat" select="{$out-lang}"
		   xml:id="msd.cat.{$catcode}-{$out-lang}">
	      <head>
                <xsl:value-of select="concat('Specification for ', $langName, ' ', $catname)"/>
	      </head>
              <xsl:apply-templates select="tei:table[@n='msd.cat']/tei:row"/>
            </table>
            <xsl:if test="$mode = 'verbose'">
	      <xsl:copy-of select="$notes"/>
	      <div>
		<head>Combinations</head>
		<table n="msd.combs">
		  <row>
		    <cell>Put combinations here</cell>
		    <cell>If combinations are not specificed, delete this section.</cell>
		  </row>
		</table>
	      </div>
            </xsl:if>
	    <divGen type="msd.lex" select="{$out-lang}"/>
          </div>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="$mode = 'verbose'">
	<div type="section" xml:id="msd.attributes-{$out-lang}">
	  <head>
            <xsl:value-of select="concat($langName, ' Attribute Index')"/>
	  </head>
	  <p>In this section all the attributes presented in the tables are listed in alphabetical
          order.</p>
	  <divGen type="msd.atts" select="{$out-lang}"/>
	</div>
	<div type="section" xml:id="msd.values-{$out-lang}">
	  <head>
            <xsl:value-of select="concat($langName, ' Value Index')"/>
	  </head>
	  <p>The values presented within the tables are, in the following, listed in alphabetical order;
          the first column gives the name of the value, the second column its code and the third lists
          attributes for which the value is appropriate.</p>
	  <divGen type="msd.vals" select="{$out-lang}"/>
	</div>
	<div select="{$out-lang}" type="section" xml:id="msd.msds-{$out-lang}">
	  <head>
	    <xsl:value-of select="concat($langName, ' MSD Index')"/>
	  </head>
	  <p>This index gives the list of morphosyntactic descriptions (MSDs) and their features. 
	  In the table below, 
	  the first column gives the MSD, 
	  the second its expansion into a feature-structure,
	  the third gives the number of entries in the lexicon,
	  and the fourth gives some examples as word-form/lemma. 
	  </p>
	  <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="msd-{$out-lang}.msd.xml"/>
	</div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template mode="select-langs" match="tei:cell">
    <xsl:param name="langs"/>
    <xsl:choose>
      <xsl:when
        test="contains($langs,',') and (substring-before($langs,',') = normalize-space(text()))">
        <xsl:value-of select="substring-before($langs,',')"/>
      </xsl:when>
      <xsl:when test="contains($langs,',')">
        <xsl:apply-templates mode="select-langs" select=".">
          <xsl:with-param name="langs" select="substring-after($langs,',')"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$langs = text()">
        <xsl:value-of select="$langs"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:row[@role='attribute']">
    <xsl:variable name="select">
      <xsl:apply-templates mode="select-langs"
        select="tei:cell/tei:table/tei:row/tei:cell[@role='lang']">
        <xsl:with-param name="langs" select="$in-langs"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="normalize-space($select)">
      <xsl:element name="{local-name()}">
        <xsl:apply-templates select="*|@*"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:row[@role='value']">
    <xsl:variable name="select">
      <xsl:apply-templates mode="select-langs" select="tei:cell[@role='lang']">
        <xsl:with-param name="langs" select="$in-langs"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="normalize-space($select)">
      <xsl:element name="{local-name()}">
        <xsl:apply-templates select="*|@*"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:cell[@role='lang']"/>
  <xsl:template match="tei:cell[@role='name'] | tei:cell[@role='code'] | tei:cell[@role='value']">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:apply-templates select="*|comment()|text()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:cell[tei:table]">
    <xsl:variable name="select">
      <xsl:apply-templates mode="select-langs" select="tei:table/tei:row/tei:cell[@role='lang']">
        <xsl:with-param name="langs" select="$in-langs"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="normalize-space($select)">
      <xsl:element name="{local-name()}">
        <xsl:apply-templates select="*|@*"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@rows"/>
  <xsl:template match="@cols"/>
  <xd:doc><xd:desc>
    <xd:p>By default pass through</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()|text()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|comment()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
