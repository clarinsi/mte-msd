<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:edate="http://exslt.org/dates-and-times" xmlns:estr="http://exslt.org/strings"
  xmlns:exsl="http://exslt.org/common" xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:local="http://www.pantor.com/ns/local" xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="exsl estr edate"
  exclude-result-prefixes="html xd exsl estr edate a fo local rng tei teix" version="1.0">
  <xd:doc type="stylesheet">
    <xd:short>Stylesheet for MULTEXT-East morphosyntactic specifications. Extracts language
      particular specification from common morphosyntactic tables. </xd:short>
    <xd:author>Tomaž Erjavec tomaz.erjavec@ijs.si</xd:author>
    <xd:date>2009-03-08</xd:date>
    <xd:detail> This library is free software; you can redistribute it and/or modify it under the
      terms of the GNU Lesser General Public License as published by the Free Software Foundation;
      either version 2.1 of the License, or (at your option) any later version. This library is
      distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
      implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
      General Public License for more details. You should have received a copy of the GNU Lesser
      General Public License along with this library; if not, write to the Free Software Foundation,
      Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA </xd:detail>
  </xd:doc>

  <xsl:output indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="mode">brief</xsl:param>
  <xsl:param name="lang">sl</xsl:param>
  <xsl:param name="in-langs" select="$lang"/>
  <xsl:param name="out-lang" select="$lang"/>
  <xsl:variable name="langname"
    select="//tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language[@ident=$out-lang]"/>
  <xsl:variable name="div-header">
    <xsl:apply-templates
      select="//tei:table[@xml:id='msd.langs']/tei:row[tei:cell[@role='code']=$out-lang]"
      mode="lang-intro"/>
    <xsl:if test="$mode = 'verbose'">
      <divGen type="subtoc"/>
      <div>
        <xsl:call-template name="div-head">
          <xsl:with-param name="head">Introduction</xsl:with-param>
        </xsl:call-template>
        <p>Here comes the introduction.</p>
      </div>
      <div type="section" select="{$out-lang}">
        <xsl:attribute name="xml:id">
          <xsl:text>sec.cattable-</xsl:text>
          <xsl:value-of select="$out-lang"/>
        </xsl:attribute>
        <xsl:call-template name="div-head">
          <xsl:with-param name="head">Category Index</xsl:with-param>
        </xsl:call-template>
        <divGen type="msd.cats" select="{$out-lang}"/>
        <div>
          <head>Notes</head>
          <list>
            <item>Put notes here</item>
          </list>
        </div>
      </div>
    </xsl:if>
  </xsl:variable>
  <xsl:template match="tei:row" mode="lang-intro">
    <list type="gloss">
      <label>Language Name:</label>
      <item>
        <xsl:value-of select="tei:cell[@role='name']"/>
      </item>
      <label>Code:</label>
      <item>
        <xsl:value-of select="tei:cell[@role='code']"/>
      </item>
      <label>Reference:</label>
      <item>
        <xsl:apply-templates select="tei:cell[@role='ref']/* | tei:cell[@role='ref']/text() "/>
      </item>
      <label>Authors of the Specification:</label>
      <item>
        <xsl:apply-templates
          select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[@select=$out-lang]/tei:name"
        />
      </item>
    </list>
  </xsl:template>

  <xsl:variable name="cat-tail">
    <div>
      <head>Notes</head>
      <list>
        <item>Put notes here</item>
      </list>
    </div>
    <div>
      <head>Combinations</head>
      <table n="msd.combs">
        <row>
          <cell>Put combinations here</cell>
        </row>
      </table>
    </div>
    <div>
      <head>Lexicon</head>
      <table n="msd.lex">
        <row>
          <cell>Put lexicon here</cell>
        </row>
      </table>
    </div>
  </xsl:variable>
  <xsl:variable name="div-tail">
    <div type="section">
      <xsl:call-template name="div-head">
        <xsl:with-param name="head">Attribute Index</xsl:with-param>
      </xsl:call-template>
      <p>In this section all the attributes presented in the tables are listed in alphabetical
        order. //For some attributes which are not self-explanatory, a brief description of their
        semantics is provided.//</p>
      <divGen type="msd.atts" select="{$out-lang}"/>
    </div>
    <div type="section">
      <xsl:call-template name="div-head">
        <xsl:with-param name="head">Value Index</xsl:with-param>
      </xsl:call-template>
      <p>The values presented within the tables are, in the following, listed in alphabetical order;
        the first column gives the name of the value, the second column its code and the third lists
        attributes for which the value is appropriate.</p>
      <divGen type="msd.vals" select="{$out-lang}"/>
    </div>
    <div type="section">
      <xsl:call-template name="div-head">
        <xsl:with-param name="head">Lexicon</xsl:with-param>
      </xsl:call-template>
      <p>This section gives the complete list of MSDs.</p>
      <divGen type="msd.msds" select="{$out-lang}"/>
    </div>
  </xsl:variable>
  <xsl:template name="div-head">
    <xsl:param name="head">???</xsl:param>
    <head>
      <xsl:value-of select="$langname"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$head"/>
    </head>
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

  <xsl:template match="/">
    <div xmlns="http://www.tei-c.org/ns/1.0" type="part" n="msd-language" select="{$out-lang}">
      <xsl:attribute name="xml:id">
        <xsl:text>msd-</xsl:text>
        <xsl:value-of select="$out-lang"/>
      </xsl:attribute>
      <xsl:call-template name="div-head">
        <xsl:with-param name="head">Specifications</xsl:with-param>
      </xsl:call-template>
      <xsl:copy-of select="$div-header"/>
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
            <xsl:call-template name="div-head">
              <xsl:with-param name="head" select="tei:head"/>
            </xsl:call-template>
            <table n="msd.cat" select="{$out-lang}">
              <xsl:attribute name="xml:id">
                <xsl:text>msd.cat.</xsl:text>
                <xsl:value-of select="$catcode"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$out-lang"/>
              </xsl:attribute>
              <xsl:call-template name="div-head">
                <xsl:with-param name="head">
                  <xsl:text>Specification for </xsl:text>
                  <xsl:value-of select="$catname"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:apply-templates select="tei:table[@n='msd.cat']/tei:row"/>
            </table>
            <xsl:if test="$mode = 'verbose'">
              <xsl:copy-of select="$cat-tail"/>
              <!--xsl:apply-templates select="exsl:node-set($cat-tail)"/-->
            </xsl:if>
          </div>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="$mode = 'verbose'">
        <xsl:copy-of select="$div-tail"/>
      </xsl:if>
    </div>
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
  <xd:doc>
    <xd:short>By default pass through</xd:short>
  </xd:doc>
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
