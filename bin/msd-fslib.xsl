<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		xmlns:et="http://nl.ijs.si/et"
		exclude-result-prefixes="tei xd et">
  <xd:doc>
    <xd:desc>
      <xd:p>Stylesheet for MULTEXT-East morphosyntactic specifications. Merges language
      specific specification to common specification.</xd:p>
      <xd:p>From MULTEXT-East morphosyntactic specifications generates two TEI P5 libraries.
      The feature library gives the definitions of the categories, their attributes and their values.
      The feature-structure library gives the list of MSDs with pointers to their attribute-value definitions.
      Supports localisation, i.e. can output the libraries in different languages.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xd:doc><xd:desc>
    <xd:p>For multilingual specifications selects which language to process.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="select"/>

  <xd:doc><xd:desc>
    <xd:p>Optional list of MSDs, separated by spaces. 
    If given, a TEI P5 feature-structure library will also be generated
    giving the the MSDs as feature-structure IDs, 
    and their decomposition into feature-value pairs, defined in the feature library.
    If empty, we try to take it from the specifications.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="msds"/>

  <xd:doc><xd:desc>
    <xd:p>Input localisation of the MSDs.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="lang1">en</xsl:param>

  <xd:doc><xd:desc>
    <xd:p>If the specifications also has a localisation, output that as well and connect the two.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="lang2">
    <xsl:if test="//tei:cell[@role='msd'][@xml:lang and @xml:lang != $lang1]">
      <xsl:variable name="list" select="//tei:cell[@role='msd'][@xml:lang != $lang1][1]/@xml:lang"/>
      <xsl:value-of select="$list[1]"/>
    </xsl:if>
  </xsl:param>

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  <xsl:strip-space elements="tei:*"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  
  <xd:doc><xd:desc>
    <xd:p>Output specifications as feature library, per PoS, and then, if given, MSDs as a fs library.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="/">
    <xsl:if test="not(normalize-space($msds)) and not(//tei:cell[@role='msd'])">
      <xsl:message terminate="yes">
	<xsl:text>No list of MSDs as parameter nor in input file </xsl:text>
	<xsl:value-of select="tei:*[@xml:id]/@xml:id"/>
      </xsl:message>
    </xsl:if>
    <xsl:comment>Automatically generated from XML source</xsl:comment>
    <xsl:comment>cf. http://nl.ijs.si/ME/ and https://github.com/clarinsi/mte-msd</xsl:comment>
    <xsl:comment>Edit at you own risk!</xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <div>
      <xsl:copy-of select="/tei:div/@*"/>
      <xsl:attribute name="select" select="$select"/>
      <head>
	<xsl:text>MULTEXT-East morphosyntactic specifications as a TEI FS library</xsl:text>
      </head>
      <xsl:copy-of select="tei:div/tei:head |
			   tei:div/tei:docAuthor | tei:div/tei:docDate |
			   tei:div/tei:list[@type='gloss']"/>
      <xsl:call-template name="output">
	<xsl:with-param name="lang1" select="$lang1"/>
	<xsl:with-param name="lang2" select="$lang2"/>
      </xsl:call-template>
      <xsl:if test="normalize-space($lang2)">
	<xsl:call-template name="output">
	  <xsl:with-param name="lang1" select="$lang2"/>
	  <xsl:with-param name="lang2" select="$lang1"/>
	</xsl:call-template>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="output">
    <xsl:param name="lang1"/>
    <xsl:param name="lang2"/>
    <fLib xml:lang="{$lang1}">
      <xsl:for-each select="//tei:table[@n='msd.cat']">
        <xsl:call-template name="fLib-PoS">
	  <xsl:with-param name="lang1" select="$lang1"/>
	  <xsl:with-param name="lang2" select="$lang2"/>
	</xsl:call-template>
      </xsl:for-each>
    </fLib>
    <xsl:choose>
      <xsl:when test="normalize-space($msds)">
        <fvLib xml:lang="{$lang1}">
          <xsl:call-template name="fs-msds">
	    <xsl:with-param name="lang1" select="$lang1"/>
            <xsl:with-param name="msds" select="normalize-space($msds)"/>
          </xsl:call-template>
        </fvLib>
      </xsl:when>
      <xsl:otherwise>
        <fvLib xml:lang="{$lang1}">
	  <xsl:for-each select="//tei:row[
				tei:cell[@role='msd']
				[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$lang1]]
				]">
	    <xsl:call-template name="fs-msd">
              <xsl:with-param name="lang1" select="$lang1"/>
              <xsl:with-param name="msd" select="tei:cell[@role='msd']
						 [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$lang1]]"/>
              <xsl:with-param name="corresp" select="tei:cell[@role='msd'][@xml:lang=$lang2]"/>
	    </xsl:call-template>
	  </xsl:for-each>
	</fvLib>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>Output the features of one Category table. 
    Each feature gives the attribute name, value name, and position+code based ID
    and the referece to the feature in the other language (if it exists)</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="fLib-PoS">
    <xsl:param name="lang1"/>
    <xsl:param name="lang2"/>
    <xsl:variable name="catname">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">value</xsl:with-param>
        <xsl:with-param name="lan" select="$lang1"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="catcode">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">code</xsl:with-param>
        <xsl:with-param name="lan" select="$lang1"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="catatt">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">name</xsl:with-param>
        <xsl:with-param name="lan" select="$lang1"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="catname2">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">value</xsl:with-param>
        <xsl:with-param name="lan" select="$lang2"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="catcode2">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">code</xsl:with-param>
        <xsl:with-param name="lan" select="$lang2"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="catatt2">
      <xsl:call-template name="cell">
        <xsl:with-param name="row">type</xsl:with-param>
        <xsl:with-param name="col">name</xsl:with-param>
        <xsl:with-param name="lan" select="$lang2"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="feature">
      <xsl:with-param name="id" select="et:feat-id($catcode, 0, '', $lang1)"/>
      <xsl:with-param name="corresp">
	<xsl:if test="normalize-space($lang2)">
	  <xsl:value-of select="et:feat-id($catcode2, 0, '', $lang2)"/>
	</xsl:if>
      </xsl:with-param>
      <xsl:with-param name="attribute" select="$catatt"/>
      <xsl:with-param name="value" select="$catname"/>
      <xsl:with-param name="select" select="$select"/>
      <xsl:with-param name="lang1" select="$lang1"/>
    </xsl:call-template>
    <xsl:for-each select="tei:row[@role='attribute']">
      <xsl:variable name="attribute">
        <xsl:call-template name="cell">
          <xsl:with-param name="col">name</xsl:with-param>
          <xsl:with-param name="lan" select="$lang1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="position">
        <xsl:call-template name="cell">
          <xsl:with-param name="col">position</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:for-each select="tei:cell/tei:table/tei:row[@role='value']">
	<xsl:variable name="code">
          <xsl:call-template name="cell">
            <xsl:with-param name="col">code</xsl:with-param>
            <xsl:with-param name="lan" select="$lang1"/>
          </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="code2">
          <xsl:call-template name="cell">
            <xsl:with-param name="col">code</xsl:with-param>
            <xsl:with-param name="lan" select="$lang2"/>
          </xsl:call-template>
	</xsl:variable>
        <xsl:call-template name="feature">
	  <xsl:with-param name="id" select="et:feat-id($catcode, $position, $code, $lang1)"/>
	  <xsl:with-param name="corresp">
	    <xsl:if test="normalize-space($lang2)">
	      <xsl:value-of select="et:feat-id($catcode2, $position, $code2, $lang2)"/>
	    </xsl:if>
	  </xsl:with-param>
          <xsl:with-param name="attribute" select="$attribute"/>
          <xsl:with-param name="value">
            <xsl:call-template name="cell">
              <xsl:with-param name="col">name</xsl:with-param>
              <xsl:with-param name="lan" select="$lang1"/>
            </xsl:call-template>
          </xsl:with-param>
	  <xsl:with-param name="lang1" select="$lang1"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
 
  <xd:doc><xd:desc>
    <xd:p>Outputs one feature, but only if value is set:
    catcode (string): Code of the PoS;
    position (number): Position number;
    code (number):Code of the value;
    attribute (number): Name of the attribute;
    value (number): Name of the value.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="feature">
    <xsl:param name="id"/>
    <xsl:param name="corresp"/>
    <xsl:param name="attribute"/>
    <xsl:param name="value"/>
    <xsl:param name="select"/>
    <xsl:param name="lang1"/>
    <xsl:if test="normalize-space($value)">
      <f name="{$attribute}">
        <xsl:attribute name="xml:id" select="$id"/>
	<xsl:if test="normalize-space($corresp)">
          <xsl:attribute name="corresp" select="concat('#', $corresp)"/>
	</xsl:if>
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$lang1"/>
        </xsl:attribute>
        <symbol value="{$value}"/>
      </f>
    </xsl:if>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Output one cell in correct localisation. Assumes table or row context node.
    row (string): The @role of the row; if empty, row is assumed as context node;
    col (string): The @role of the cell;
    lan (string): The @xml:lang of the cell.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="cell">
    <xsl:param name="row"/>
    <xsl:param name="col"/>
    <xsl:param name="lan"/>
    <xsl:variable name="result">
      <xsl:choose>
	<xsl:when test="$row">
          <xsl:choose>
            <xsl:when test="normalize-space($lan) and normalize-space($select)">
              <xsl:value-of select="tei:row[@role=$row][tei:cell[@role='lang']=$select or
				    not(tei:cell[@role='lang'])]
                                    /tei:cell[@role=$col][ancestor-or-self::tei:*
				    [@xml:lang][1][@xml:lang=$lan]]"/>
            </xsl:when>
            <xsl:when test="normalize-space($lan)">
              <xsl:value-of select="tei:row[@role=$row]/tei:cell[@role=$col]
				    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$lan]]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tei:row[@role=$row][not(tei:cell[@role='lang'])]/tei:cell[@role=$col]"/>
            </xsl:otherwise>
          </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
          <xsl:choose>
            <xsl:when test="normalize-space($lan) and normalize-space($select)">
              <xsl:value-of select="tei:cell[@role=$col][../tei:cell[@role='lang']=$select or
				    not(../tei:cell[@role='lang'])]
                                    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$lan]]"/>
            </xsl:when>
            <xsl:when test="normalize-space($lan)">
              <xsl:value-of select="tei:cell[@role=$col]
                                    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$lan]]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tei:cell[@role=$col][not(../tei:cell[@role='lang'])]"/>
            </xsl:otherwise>
          </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(normalize-space($result))">
      <xsl:message>
	<xsl:text>ERROR: no resut found for </xsl:text>
	<xsl:value-of select="concat($row, '/', $col, '/', $lan, ':', .)"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="$result"/>
    </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>MSD 2 fsLib processing with localisation.
    This template splits the list of MSDs and passes them to fs-msds.
    msds (string): Space separated list of MSDs.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="fs-msds">
    <xsl:param name="lang1"/>
    <xsl:param name="msds"/>
    <xsl:choose>
      <xsl:when test="contains($msds,' ')">
        <xsl:variable name="msd" select="substring-before($msds,' ')"/>
        <xsl:variable name="rest" select="substring-after($msds,' ')"/>
        <xsl:call-template name="fs-msd">
          <xsl:with-param name="lang1" select="$lang1"/>
          <xsl:with-param name="msd" select="$msd"/>
        </xsl:call-template>
        <xsl:call-template name="fs-msds">
          <xsl:with-param name="lang1" select="$lang1"/>
          <xsl:with-param name="msds" select="$rest"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="fs-msd">
          <xsl:with-param name="lang1" select="$lang1"/>
          <xsl:with-param name="msd" select="$msds"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Process one MSD, output a feature-structure</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="fs-msd">
    <xsl:param name="lang1"/>
    <xsl:param name="msd"/>
    <xsl:param name="corresp"/>
    <fs>
      <xsl:attribute name="xml:id" select="$msd"/>
      <xsl:attribute name="xml:lang" select="$lang1"/>
      <xsl:if test="normalize-space($corresp)">
	<xsl:attribute name="corresp" select="concat('#',$corresp)"/>
      </xsl:if>
      <xsl:attribute name="feats">
        <xsl:call-template name="msdfs-feature">
          <xsl:with-param name="pos" select="substring($msd,1,1)"/>
          <xsl:with-param name="msd" select="$msd"/>
          <xsl:with-param name="n">0</xsl:with-param>
	  <xsl:with-param name="lang1" select="$lang1"/>
        </xsl:call-template>
      </xsl:attribute>
    </fs>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Output one feature reference.
    Currently, hyphen (-) is not output; arguably wrong.
    No checking is made on the legality of the features.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="msdfs-feature">
    <xsl:param name="pos"/>
    <xsl:param name="msd"/>
    <xsl:param name="n"/>
    <xsl:param name="lang1"/>
    <xsl:if test="normalize-space($msd)">
      <xsl:variable name="code" select="substring($msd,1,1)"/>
      <xsl:if test="$code != '-' ">
        <xsl:if test="$n &gt; 0">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="et:feat-id($pos, $n, $code, $lang1)"/>
      </xsl:if>
      <xsl:call-template name="msdfs-feature">
        <xsl:with-param name="pos" select="$pos"/>
        <xsl:with-param name="msd" select="substring($msd,2)"/>
        <xsl:with-param name="n" select="$n+1"/>
	<xsl:with-param name="lang1" select="$lang1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:function name="et:feat-id">
    <xsl:param name="catcode"/>
    <xsl:param name="position"/>
    <xsl:param name="featcode"/>
    <xsl:param name="lan"/>
    <xsl:if test="normalize-space($lan) and $lan != 'en'">
      <xsl:value-of select="concat($lan,'-')"/>
    </xsl:if>
    <xsl:value-of select="concat($catcode,$position)"/>
    <xsl:if test="$position &gt; 0">
      <xsl:value-of select="concat('.',$featcode)"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
