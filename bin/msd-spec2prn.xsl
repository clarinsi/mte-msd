<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei xd">
  <xd:doc type="stylesheet">
    <xd:desc>
      <xd:p>Stylesheet for converting MULTEXT-East morphosyntactic specifications.
      Transforms the source specifications into a print-oriented TEI.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
      <xd:p>Date: 2018-11-11</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output indent="yes" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xd:doc><xd:desc>
    <xd:p>Process elements of MULTEXT attribute-value table for a Category (PoS)</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:table[@n='msd.cat']">
    <table rend="frame">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:head"/>
      <!-- space separated (and terminated!) list of language localisations to display; '? ' means implicit language -->
      <xsl:variable name="langs">
        <xsl:call-template name="cat-langs"/>
      </xsl:variable>
      <!--xsl:comment>
	<xsl:text>INFO: localisation languages for </xsl:text>
	<xsl:value-of select="@select"/>
	<xsl:text> are </xsl:text>
	<xsl:value-of select="$langs"/>
      </xsl:comment-->
      <row role="label">
        <cell role="position">P</cell>
        <xsl:call-template name="ABCD">
          <xsl:with-param name="langs" select="$langs"/>
          <xsl:with-param name="A">Attribute</xsl:with-param>
          <xsl:with-param name="B">Value</xsl:with-param>
          <xsl:with-param name="C">Code</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="allLangRow"/>
      </row>
      <row role="data">
        <cell role="position">
          <xsl:value-of select="tei:row[@role='type']/tei:cell[@role = 'position']"/>
        </cell>
        <xsl:call-template name="ABCD">
          <xsl:with-param name="langs" select="$langs"/>
          <xsl:with-param name="A" select="tei:row[@role='type']/tei:cell[@role = 'name']"/>
          <xsl:with-param name="B" select="tei:row[@role='type']/tei:cell[@role = 'value']"/>
          <xsl:with-param name="C" select="tei:row[@role='type']/tei:cell[@role = 'code']"/>
        </xsl:call-template>
        <xsl:call-template name="LangRow">
          <xsl:with-param name="langs" select="tei:row[@role='type']/tei:cell[@role='lang']"/>
        </xsl:call-template>
      </row>
      <xsl:for-each select="tei:row[@role='attribute']">
        <xsl:for-each select="tei:cell/tei:table/tei:row[@role='value']">
          <xsl:element name="{local-name()}">
            <xsl:choose>
              <xsl:when test="position()=1">
                <xsl:apply-templates
                  select="ancestor::tei:row[@role='attribute']/tei:cell[@role='position']"/>
                <xsl:call-template name="ABCD">
                  <xsl:with-param name="langs" select="$langs"/>
                  <xsl:with-param name="A"
                    select="ancestor::tei:row[@role='attribute']/tei:cell[@role='name']"/>
                  <xsl:with-param name="B" select="tei:cell[@role='name']"/>
                  <xsl:with-param name="C" select="tei:cell[@role='code']"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <cell/>
                <xsl:call-template name="ABCD">
                  <xsl:with-param name="langs" select="$langs"/>
                  <xsl:with-param name="B" select="tei:cell[@role = 'name']"/>
                  <xsl:with-param name="C" select="tei:cell[@role = 'code']"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="LangRow">
              <xsl:with-param name="langs" select="tei:cell[@role='lang']"/>
            </xsl:call-template>
          </xsl:element>
        </xsl:for-each>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>By default pass through</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:table">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="rend">frame</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@rows"/>
  <xsl:template match="@cols"/>
  <xsl:template match="tei:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <!-- Returns the languages that a particular cat table has localisations for;
       in common tables, returns '? '-->
  <xsl:template name="cat-langs">
    <xsl:choose>
      <xsl:when test="ancestor::tei:div[@xml:id='msd.common']">
        <!-- must be followed by space! -->
        <xsl:text>? </xsl:text>
      </xsl:when>
      <xsl:when test="self::tei:table">
        <xsl:for-each select="tei:row[1]/tei:cell[@role='value']/@xml:lang">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each
          select="ancestor::tei:div[@n='msd-language']/tei:div[tei:table[@n='msd.cat']][1]/
          tei:table[@n='msd.cat'][1]/tei:row[1]/tei:cell[@role='value']/@xml:lang">
          <xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="div-atts">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="@type"/>
      <xsl:if test="@select">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@select"/>
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Output row of all defined languages from table[@id='msd.langs']</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="allLangRow">
    <xsl:if test="ancestor::tei:div[@xml:id='msd.common']">
      <!-- dont do it for language particular tables-->
      <xsl:for-each select="//tei:table[@xml:id='msd.langs']/tei:row[@role='lang']">
        <xsl:apply-templates select="tei:cell[@role='name']"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Output row of defined languages from table[@id='msd.langs'] if they are defined in
      $langs</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="LangRow">
    <xsl:param name="langs" select="tei:cell[@role='lang']"/>
    <!-- dont do it for language particular tables-->
    <xsl:if test="ancestor::tei:div[@xml:id='msd.common']">
      <xsl:for-each
        select="//tei:table[@xml:id='msd.langs']/tei:row[@role='lang']/tei:cell[@role='code']">
        <cell role="lang">
          <!--complications because of attribute languages - defined only thru values-->
          <xsl:variable name="langcodes">
            <xsl:apply-templates select="$langs" mode="langs">
              <xsl:with-param name="lang" select="."/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:value-of select="substring-before($langcodes,' ')"/>
        </cell>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xd:doc><xd:desc>
    <xd:p>Output label lang only if it matches with selected language</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="*" mode="langs">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test=". = $lang">
        <!-- Could rather give name here? -->
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ABCD">
    <xsl:param name="langs"/>
    <xsl:param name="A"/>
    <xsl:param name="B"/>
    <xsl:param name="C"/>
    <xsl:param name="D"/>
    <xsl:variable name="lang" select="substring-before($langs,' ')"/>
    <xsl:if test="normalize-space($lang)">
      <cell>
        <xsl:call-template name="lang-cell">
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:with-param name="X" select="$A"/>
        </xsl:call-template>
      </cell>
      <xsl:if test="$B">
        <cell>
          <xsl:call-template name="lang-cell">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="X" select="$B"/>
          </xsl:call-template>
        </cell>
      </xsl:if>
      <xsl:if test="$C">
        <cell>
          <xsl:call-template name="lang-cell">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="X" select="$C"/>
          </xsl:call-template>
        </cell>
      </xsl:if>
      <xsl:if test="$D">
        <cell>
          <xsl:call-template name="lang-cell">
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="X" select="$D"/>
          </xsl:call-template>
        </cell>
      </xsl:if>
      <xsl:call-template name="ABCD">
        <xsl:with-param name="langs" select="substring-after($langs,' ')"/>
        <xsl:with-param name="A" select="$A"/>
        <xsl:with-param name="B" select="$B"/>
        <xsl:with-param name="C" select="$C"/>
        <xsl:with-param name="D" select="$D"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lang-cell">
    <xsl:param name="lang"/>
    <xsl:param name="X"/>
    <!-- 
    <xsl:message>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$lang"/>
       <xsl:text>/</xsl:text>
      <xsl:value-of select="$X"/>
      <xsl:text>]</xsl:text>
      </xsl:message>
      -->
    <xsl:choose>
      <xsl:when test="$X and $X[@xml:lang=$lang]">
        <xsl:choose>
          <xsl:when test="$lang = '?'">
            <xsl:value-of select="$X"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$X[@xml:lang=$lang]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- ET: has language, but not correct one -->
      <xsl:when test="$X and $X[@xml:lang]">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$X//@xml:lang"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="$X">
        <xsl:value-of select="$X"/>
        <xsl:if test="$lang != '?'">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="$lang"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
