<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		exclude-result-prefixes="tei xd">
  <xd:doc>
    <xd:desc>
      <xd:p>Converts a "stand-off" representation of feature structures to an in-place one.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <xsl:variable name="doc" select="/"/>

  <xsl:template match="tei:fLib"/>
  
  <xsl:template match="tei:fs">
    <xsl:copy>
      <xsl:copy-of select="@xml:id"/>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:copy-of select="@corresp"/>
      <xsl:for-each select="tokenize(@feats, ' ')">
	<xsl:apply-templates mode="strip" select="key('id', substring-after(., '#'), $doc)"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="strip" match="tei:f">
    <xsl:copy>
      <xsl:attribute name="name" select="@name"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:*|text()|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

 </xsl:stylesheet>
