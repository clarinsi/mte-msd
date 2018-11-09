<?xml version="1.0" encoding="UTF-8"?>
<!-- Checks if all references in a TEI document have a corresponding @xml:id -->
<!-- et -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="tei fn" 
    version="2.0">

  <xsl:output encoding="utf-8" method="text"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <xsl:variable name="primary" select="/"/>

  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="@xml:lang">
    <xsl:variable name="lang" select="."/>
    <xsl:if test="//tei:teiHeader and not(//tei:teiHeader//tei:language[@ident = $lang])">
      <xsl:message>
	<xsl:text>ERROR: Can't find language definition for </xsl:text>
	<xsl:value-of select="parent::tei:*/name()"/>
	<xsl:text>/@xml:lang = </xsl:text>
	<xsl:value-of select="$lang"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:variable name="message">
      <xsl:text>ERROR: Can't find source for </xsl:text>
      <xsl:value-of select="parent::tei:*[1]/name()"/>
      <xsl:text>/@</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:variable>
    <xsl:if test="contains(.,'#')">
      <xsl:for-each select="tokenize(.,' ')">
	<xsl:variable name="link" select="."/>
	<xsl:variable name="file" select="substring-before(.,'#')"/>
	<xsl:variable name="id" select="substring-after(.,'#')"/>
	<!--xsl:message>
	  <xsl:value-of select="concat('Info: link ',$link,' file ',$file,' id ',$id)"/>
	</xsl:message-->
	<xsl:choose>
	  <xsl:when test="normalize-space($file)">
	    <xsl:choose>
	      <xsl:when test="document($file)">
		<xsl:for-each select="document($file)">
		  <xsl:if test="not(normalize-space(key('id',$id)))">
		    <xsl:message>
		      <xsl:value-of select="$message"/>
		      <xsl:value-of select="concat('&#10;[In file ',$file,' cant find id ',$id,']')"/>
		    </xsl:message>
		  </xsl:if>
		</xsl:for-each>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:message>
		  <xsl:text>ERROR: Can't find external document for </xsl:text>
		  <xsl:value-of select="$link"/>
		</xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each select="$primary">
	      <xsl:if test="not(key('id',$id))[1]">
		<xsl:message>
		  <xsl:value-of select="$message"/>
		  <xsl:text>&#10;[Can't find local xml:id="</xsl:text>
		  <xsl:value-of select="$id"/>
		  <xsl:text>"]</xsl:text>
		</xsl:message>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
