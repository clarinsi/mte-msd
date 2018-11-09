<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">

<xsl:output
  indent="yes" 
  method="xml"
  omit-xml-declaration="yes"
  />

<!--xsl:template match="tei:tagsDecl"-->
<xsl:template match="/">
  <tagsDecl>
    <namespace name="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates mode="tagCount" select="tei:*"/>
    </namespace>
  </tagsDecl> 
</xsl:template>

<xsl:template mode="tagCount" match="text()"/>
<xsl:template mode="tagCount" match="tei:teiHeader"/>
<xsl:template mode="tagCount" match="tei:*">
  <xsl:variable name="self" select="name()"/>
  <xsl:if test="not(following::*[name()=$self] or descendant::*[name()=$self] )">
    <xsl:element name="tagUsage">
      <xsl:attribute name="gi">
        <xsl:value-of select="$self"/>
      </xsl:attribute>
      <xsl:attribute name="occurs">
        <xsl:number level="any"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:if>
  <xsl:apply-templates mode="tagCount"/>
</xsl:template>


</xsl:stylesheet>
