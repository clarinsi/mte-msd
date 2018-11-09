<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:import href="Stylesheets/profiles/default/html/to.xsl"/>

  <xsl:variable name="project">MULTEXT-East Morphosyntactic Specifications</xsl:variable>
  <xsl:param name="searchURL"/>
  <xsl:param name="feedbackURL">mailto:tomaz.erjavec@ijs.si</xsl:param>
  <xsl:param name="institution" select="$project"></xsl:param>
  <xsl:param name="department"/>
  <xsl:param name="homeWords">MULTEXT-East Morphosyntactic specifications</xsl:param>
  <xsl:param name="homeLabel">MULTEXT-East</xsl:param>
  <xsl:param name="homeURL">http://nl.ijs.si/ME/V6/msd/</xsl:param>
  <xsl:param name="parentWords">MULTEXT-East Version 6</xsl:param>
  <xsl:param name="parentURL">http://nl.ijs.si/ME/V6/</xsl:param>
  <xsl:param name="htmlTitlePrefix">MULTEXT-East, Version 6</xsl:param>
  <xsl:template name="copyrightStatement">This work is licensed under the 
  <a href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International</a>.</xsl:template>
  
  <xsl:param name="urlChunkPrefix">#</xsl:param>
  <xsl:param name="outputEncoding">utf-8</xsl:param>
  <xsl:param name="outputDir">html</xsl:param>
  <!--xsl:param name="cssFile">tei.css</xsl:param-->
  <xsl:param name="STDOUT">false</xsl:param>
  <xsl:param name="useIDs">true</xsl:param>
  <xsl:param name="outputName">msd</xsl:param>
  <xsl:param name="autoToc">false</xsl:param>
  <xsl:param name="tocDepth">1</xsl:param>
  <xsl:param name="subTocDepth">5</xsl:param>
  <xsl:param name="splitLevel">1</xsl:param>
  <xsl:param name="verbose">false</xsl:param>
  
  <xsl:param name="teiHeaderFile">teiHeader.html</xsl:param>
  
  <xsl:output method="xhtml" omit-xml-declaration="yes" encoding="utf-8"/>
  <xsl:template match="tei:divGen[@type='toc']">
    <xsl:if test="normalize-space($teiHeaderFile)">
      <a href="{$teiHeaderFile}">TEI Header</a>
    </xsl:if>
    <a name="TOC"> </a>
    <h2>
      <xsl:call-template name="i18n">
        <xsl:with-param name="word">tocWords</xsl:with-param>
      </xsl:call-template>
    </h2>
    <xsl:call-template name="mainTOC"/>
  </xsl:template>
  
  <xsl:template match="tei:docAuthor | tei:docDate">
    <p>
      <i>
	<xsl:apply-templates/>
      </i>
    </p>
  </xsl:template>

</xsl:stylesheet>
