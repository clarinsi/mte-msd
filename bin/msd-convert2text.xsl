<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		exclude-result-prefixes="tei xd">
  <xd:doc>
    <xd:desc>
      <xd:p>Converts a list of MSDs from the common to language specific format or vice-versa.</xd:p>
      <xd:p>With TEI P5 MULTEXT-East type morphosyntactic specification as input XML
      converts a list of MSDs to various formats and localisations.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xd:doc><xd:desc>
    <xd:p>If xsl:output/@method is xml outputs TEI table, if to text a tab separated
    file. STDERR should output same as STDOUT in @method="text"</xd:p>
  </xd:desc></xd:doc>
  <xsl:output method="text"/>
  
  <xd:doc><xd:desc>
    <xd:p>A MULTEXT-East morphosyntactic specification file. Needs to contain both the common and language specific tables for the chosen language.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="specs"/>
  
  <xd:doc><xd:desc><xd:p>Take as reference the common tables, rather than language specific tables
  (which is the default).</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="common"/>
  
  <xd:doc><xd:desc>
    <xd:p>Output header row in table if set.</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="header"></xsl:param>
  
  <xd:doc><xd:desc>
    <xd:p>Output localisations for the features. MUST BE en.</xd:p>
  </xd:desc></xd:doc>
  <xsl:variable name="localise">en</xsl:variable>
  
  <xd:doc><xd:desc>
    <xd:p> What to output as intermediary format. Should always be attval!</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="output">attval</xsl:param>
  <xd:doc><xd:desc>
    <xd:p> Which cannonical form to produce. Should always be none!</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="canonical">none</xsl:param>
  
  <xd:doc><xd:desc>
    <xd:p>Error mark.</xd:p>
  </xd:desc></xd:doc>
  <xsl:variable name="err">@</xsl:variable>
  
  <xd:doc><xd:desc>
    <xd:p>Primary separator in table. Only important if text output is
    selected.</xd:p>
  </xd:desc></xd:doc>
  <xsl:variable name="primary-separator">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xd:doc><xd:desc>
    <xd:p>Secondary separator in table (between features). Only important if text output is selected.</xd:p>
  </xd:desc></xd:doc>
  <xsl:variable name="secondary-separator">
    <xsl:text> </xsl:text>
  </xsl:variable>
  
  <xd:doc><xd:desc>
    <xd:p>Sanity check and process.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="/">
    <xsl:if test="not(normalize-space($specs))">
      <xsl:message terminate="yes">Need file with specifications!</xsl:message>
    </xsl:if>
    <xsl:if test="not(document($specs))">
      <xsl:message terminate="yes">Can't find specifications file <xsl:value-of
      select="$specs"/></xsl:message>
    </xsl:if>
    <xsl:if test="not(//tei:table//tei:cell[@role='msd'])">
      <xsl:message terminate="yes">No MSDs found in input file!</xsl:message>
    </xsl:if>
    <xsl:if test="not(tei:*/@xml:lang)">
      <xsl:message terminate="yes">Localisation language (@xml:lang) not specified in MSD
      file!</xsl:message>
    </xsl:if>
    <xsl:if test="not(tei:*/@select)">
      <xsl:message terminate="yes">Language (@select) not specified in MSD file!</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="//tei:table[.//tei:cell[@role='msd']]"/>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>Process table with MSDs. Copy input from table and add target MSD column.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:table">
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="$common">
          <xsl:text>common2specific</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>specific2common</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <table xml:lang="en">
      <xsl:if test="ancestor-or-self::tei:*[@select]">
        <xsl:attribute name="select">
          <xsl:value-of select="ancestor-or-self::tei:*[@select][1]/@select"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$header">
        <row role="header">
          <cell role="label">MSD</cell>
          <xsl:value-of select="$primary-separator"/>
          <cell role="label">
            <xsl:value-of select="$label"/>
          </cell>
          <xsl:for-each
              select="tei:row[1][tei:cell/@role='label']/tei:cell[not(. = 'MSD')]">
            <xsl:value-of select="$primary-separator"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </row>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:for-each select="tei:row[tei:cell[@role='msd']]">
        <row role="msd_convert">
          <xsl:copy-of select="tei:cell[@role='msd']"/>
          <xsl:value-of select="$primary-separator"/>
          <cell role="{$label}">
            <xsl:apply-templates select="tei:cell[@role='msd'][1]"/>
          </cell>
	  <!--
              <xsl:for-each select="tei:cell[not(@role) or not(@role='msd')]">
              <xsl:value-of select="$primary-separator"/>
              <xsl:copy-of select="."/>
              </xsl:for-each>
	  -->
        </row>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </table>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>Expand one MSD.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:cell[@role='msd']">
    <xsl:param name="output">attval</xsl:param>
    <xsl:variable name="localisation" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="language" select="ancestor-or-self::tei:*[@select][1]/@select"/>
    <xsl:variable name="msd" select="normalize-space(.)"/>
    <xsl:variable name="cat-code" select="substring($msd,1,1)"/>
    <xsl:variable name="common-cat">
      <xsl:call-template name="cat-table">
        <xsl:with-param name="common">true</xsl:with-param>
        <xsl:with-param name="localisation" select="$localisation"/>
        <xsl:with-param name="language" select="$language"/>
        <xsl:with-param name="cat-code" select="$cat-code"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="particular-cat">
      <xsl:call-template name="cat-table">
        <xsl:with-param name="common"/>
        <xsl:with-param name="localisation" select="$localisation"/>
        <xsl:with-param name="language" select="$language"/>
        <xsl:with-param name="cat-code" select="$cat-code"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="source">
      <xsl:choose>
        <xsl:when test="$common">
          <xsl:copy-of select="$common-cat"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$particular-cat"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="$common">
          <xsl:copy-of select="$particular-cat"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$common-cat"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="source-attval">
      <xsl:apply-templates mode="expand" select="$source/tei:table">
        <xsl:with-param name="output" select="$output"/>
        <xsl:with-param name="msd" select="$msd"/>
        <xsl:with-param name="position">0</xsl:with-param>
        <xsl:with-param name="localisation" select="$localisation"/>
        <xsl:with-param name="language" select="$language"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="target-msd">
      <xsl:call-template name="strip">
        <xsl:with-param name="msd">
          <xsl:call-template name="convert">
            <xsl:with-param name="atts" select="$source-attval"/>
            <xsl:with-param name="position">0</xsl:with-param>
            <xsl:with-param name="category" select="$target"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <!--xsl:message terminate="no">
      <xsl:text>INFO msd-convert2text </xsl:text>
      <xsl:value-of select="$msd"/>
      <xsl:text>&#32;</xsl:text>
      <xsl:if test="$msd != $target-msd">
        <xsl:text>!</xsl:text>
      </xsl:if>
      <xsl:text>= </xsl:text>
      <xsl:value-of select="$target-msd"/>
    </xsl:message-->
    <xsl:copy-of select="$target-msd"/>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p> Expand one MSD, with context node appropriate PoS table. <xd:param name="msd"
    type="string">MSD to process.</xd:param>
    </xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="expand" match="tei:table">
    <xsl:param name="output"/>
    <xsl:param name="msd"/>
    <xsl:param name="position"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:if test="normalize-space($msd)">
      <xsl:variable name="code" select="substring($msd,1,1)"/>
      <xsl:variable name="result">
        <xsl:apply-templates mode="expand"
			     select="tei:row[tei:cell[@role='position'] = $position]">
          <xsl:with-param name="output" select="$output"/>
          <xsl:with-param name="code" select="$code"/>
          <xsl:with-param name="localisation" select="$localisation"/>
          <xsl:with-param name="language" select="$language"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="normalize-space($result)">
          <xsl:copy-of select="$result"/>
        </xsl:when>
        <xsl:when test="$code!='-'">
          <xsl:value-of select="$err"/>
          <xsl:value-of select="$code"/>
          <xsl:value-of select="$secondary-separator"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="expand" select=".">
        <xsl:with-param name="output" select="$output"/>
        <xsl:with-param name="msd" select="substring($msd,2)"/>
        <xsl:with-param name="position" select="$position+1"/>
        <xsl:with-param name="localisation" select="$localisation"/>
        <xsl:with-param name="language" select="$language"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p> Expand category. <xd:param name="code" type="string">Category code to
    process.</xd:param>
    </xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="expand" match="tei:row[@role='type']">
    <xsl:param name="output"/>
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:variable name="result">
      <xsl:apply-templates mode="expand-value" select=".">
        <xsl:with-param name="output" select="$output"/>
        <xsl:with-param name="code" select="$code"/>
        <xsl:with-param name="localisation" select="$localisation"/>
        <xsl:with-param name="language" select="$language"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($result)">
        <xsl:copy-of select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$err"/>
        <xsl:value-of select="$code"/>
        <xsl:message>
          <xsl:text>Category for MSD </xsl:text>
          <xsl:value-of select="$code"/>
          <xsl:text> failed to expand - something wrong with the specifications?</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p> Expand one feature. Context node should be the correct attribute row for code.
    <xd:param name="code" type="string">Attribute-value code to process.</xd:param>
    </xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="expand" match="tei:row[@role='attribute']">
    <xsl:param name="output"/>
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:variable name="att-name"
		  select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"/>
    <xsl:choose>
      <xsl:when test="$code = '-'">
        <xsl:choose>
          <xsl:when test="$output='msd' or $output='id'">
            <xsl:text>-</xsl:text>
          </xsl:when>
          <xsl:when test="$output='attval' or $output='check'">
            <xsl:if test="$canonical='cat'">
              <xsl:value-of select="$att-name"/>
              <xsl:text>=</xsl:text>
              <xsl:text>0</xsl:text>
              <xsl:value-of select="$secondary-separator"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$output='val'">
            <xsl:if test="$canonical='cat'">
              <xsl:text>0</xsl:text>
              <xsl:value-of select="$att-name"/>
              <xsl:value-of select="$secondary-separator"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$output='collate'">
            <xsl:text>00</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$output='attval' or $output='check'">
          <xsl:value-of select="$att-name"/>
          <xsl:text>=</xsl:text>
        </xsl:if>
        <xsl:variable name="result">
          <xsl:apply-templates mode="expand-value"
                               select="tei:cell/tei:table/tei:row[@role='value']">
            <xsl:with-param name="output" select="$output"/>
            <xsl:with-param name="code" select="$code"/>
            <xsl:with-param name="localisation" select="$localisation"/>
            <xsl:with-param name="language" select="$language"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($result)">
            <xsl:copy-of select="$result"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$err"/>
            <xsl:value-of select="$code"/>
            <xsl:value-of select="$secondary-separator"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p> Expand category value. <xd:param name="code" type="string">Category code to
    process.</xd:param>
    </xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="expand-value" match="tei:row[@role='type']">
    <xsl:param name="output"/>
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:choose>
      <xsl:when
          test="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]  = $code">
        <xsl:variable name="result">
          <xsl:choose>
            <xsl:when test="$output='id'">
              <xsl:value-of
                  select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]"
                  />
            </xsl:when>
            <xsl:when test="$output='msd'">
              <xsl:value-of
                  select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"
                  />
            </xsl:when>
            <xsl:when test="$output='val'">
              <xsl:value-of
                  select="tei:cell[@role='value'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"/>
              <xsl:value-of select="$secondary-separator"/>
            </xsl:when>
            <xsl:when test="$output='attval' or $output='check'">
              <xsl:value-of
                  select="tei:cell[@role='value'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"/>
              <xsl:value-of select="$secondary-separator"/>
            </xsl:when>
            <xsl:when test="$output='collate'">
              <xsl:choose>
                <xsl:when test="normalize-space($common)">
                  <xsl:apply-templates mode="position"
                                       select="document($specs)//tei:table[@n='msd.cat']
                                               [tei:row[@role='type']/tei:cell[@role='lang']=$language]">
                    <xsl:with-param name="category" select="parent::tei:table"/>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates mode="position"
                                       select="document($specs)//tei:table[@n='msd.cat']
                                               [ancestor-or-self::tei:*[@select=$language]]">
                    <xsl:with-param name="category" select="parent::tei:table"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates mode="position" select=".//tei:table[@n='msd.cat']">
                <xsl:with-param name="code" select="$code"/>
                <xsl:with-param name="localisation" select="$localisation"/>
              </xsl:apply-templates>
              <xsl:value-of
                  select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"
                  />
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($result)">
            <xsl:copy-of select="$result"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$err"/>
            <xsl:value-of select="$code"/>
            <xsl:call-template name="warn">
              <xsl:with-param name="text">Category value not found</xsl:with-param>
              <xsl:with-param name="output" select="$output"/>
              <xsl:with-param name="code" select="$code"/>
              <xsl:with-param name="language" select="$language"/>
              <xsl:with-param name="localisation" select="$localisation"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$err"/>
        <xsl:value-of select="$code"/>
        <xsl:call-template name="warn">
          <xsl:with-param name="text">Category table not found</xsl:with-param>
          <xsl:with-param name="output" select="$output"/>
          <xsl:with-param name="code" select="$code"/>
          <xsl:with-param name="language" select="$language"/>
          <xsl:with-param name="localisation" select="$localisation"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p> Expand attribute value. <xd:param name="code" type="string">Code to process.</xd:param>
    </xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="expand-value" match="tei:row[@role='value']">
    <xsl:param name="output"/>
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:if
        test="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]] = $code">
      <xsl:variable name="result">
        <xsl:choose>
          <xsl:when test="$output='id'">
            <xsl:value-of
                select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]"
                />
          </xsl:when>
          <xsl:when test="$output='msd'">
            <xsl:value-of
                select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"
                />
          </xsl:when>
          <xsl:when test="$output='val'">
            <xsl:variable name="binary"
                          select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
            <xsl:choose>
              <xsl:when test="$binary = 'no' or $binary = 'yes'">
                <xsl:if test="$binary = 'no'">-</xsl:if>
                <xsl:if test="$binary = 'yes'">+</xsl:if>
                <xsl:value-of
                    select="ancestor::tei:row[@role='attribute']/
                            tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"
                    />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                    select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"
                    />
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$secondary-separator"/>
          </xsl:when>
          <xsl:when test="$output='attval' or $output='check'">
            <xsl:value-of
                select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localise]]"/>
            <xsl:value-of select="$secondary-separator"/>
          </xsl:when>
          <xsl:when test="$output='collate'">
            <xsl:apply-templates mode="position"
				 select="parent::tei:table/tei:row[@role='value']">
              <xsl:with-param name="code" select="$code"/>
              <xsl:with-param name="localisation" select="$localisation"/>
            </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="normalize-space($result)">
          <xsl:copy-of select="$result"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$err"/>
          <xsl:value-of select="$code"/>
          <xsl:text>Attribute value not found!</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="position" match="tei:table[@n='msd.cat']">
    <xsl:param name="category"/>
    <xsl:if test=". = $category">
      <xsl:number value="position()" format="01"/>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="position" match="tei:row">
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:if test="tei:cell[@role='code']
		  [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
		  =$code">
      <xsl:number value="position()" format="01"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="cat-table">
    <xsl:param name="common"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:param name="cat-code"/>
    <xsl:choose>
      <xsl:when test="$common">
        <xsl:choose>
          <xsl:when
              test="document($specs)//tei:table[@n='msd.cat']//tei:cell[@role='lang']
                    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]=$language">
            <xsl:copy-of
                select="document($specs)//tei:table[@n='msd.cat']
                        [tei:row[@role='type']/tei:cell[@role='lang']=$language]
                        [tei:row[@role='type']/tei:cell[@role='code']
                        [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
                        = $cat-code]"
                />
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>Can't find language "</xsl:text>
              <xsl:value-of select="$language"/>
              <xsl:text> with localisation </xsl:text>
              <xsl:value-of select="$localisation"/>
              <xsl:text>" in common tables!</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- need language specific table - look for it in MSD list specs first -->
      <xsl:when
          test="//tei:table[@n='msd.cat']
                [ancestor-or-self::tei:*[@select=$language]]
                [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
                ">
        <xsl:copy-of
            select="//tei:table[@n='msd.cat']
                    [tei:row[@role='type']/tei:cell[@role='code']
                    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
                    [ancestor-or-self::tei:*[@select=$language]]
                    = $cat-code
                    ]"
            />
      </xsl:when>
      <!-- maybe in specifications? -->
      <xsl:when
          test="document($specs)//tei:table[@n='msd.cat']
                [ancestor-or-self::tei:*[@select=$language]]
                [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
                ">
        <xsl:copy-of
            select="document($specs)//tei:table[@n='msd.cat']
                    [tei:row[@role='type']/tei:cell
                    [@role='code']
                    [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang=$localisation]]
                    [ancestor-or-self::tei:*[@select=$language]]
                    = $cat-code
                    ]"
            />
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>CONVERT: Can't find language "</xsl:text>
          <xsl:value-of select="$language"/>
          <xsl:text> with localisation </xsl:text>
          <xsl:value-of select="$localisation"/>
          <xsl:text>" in language specific tables!</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="pad">
    <xsl:param name="len"/>
    <xsl:if test="$len &gt; 0">
      <xsl:text>-</xsl:text>
      <xsl:call-template name="pad">
        <xsl:with-param name="len" select="$len - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="strip">
    <xsl:param name="msd"/>
    <xsl:choose>
      <xsl:when test="substring($msd,string-length($msd),1)='-'">
        <xsl:call-template name="strip">
          <xsl:with-param name="msd" select="substring($msd,1,string-length($msd)-1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$msd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="convert">
    <xsl:param name="atts"/>
    <xsl:param name="position"/>
    <xsl:param name="category"/>
    <xsl:choose>
      <xsl:when test="$position = 0">
        <xsl:value-of
            select="$category//tei:row[@role='type']/tei:cell[@role='code']
                    [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']"/>
        <xsl:call-template name="convert">
          <xsl:with-param name="atts" select="$atts"/>
          <xsl:with-param name="position">1</xsl:with-param>
          <xsl:with-param name="category" select="$category"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when
          test="$position &lt;= $category//tei:row[@role='attribute'][last()]/tei:cell[@role='position']">
        <xsl:variable name="attribute"
                      select="$category//tei:row[@role='attribute'][tei:cell[@role='position']=$position]"/>
        <xsl:variable name="name"
                      select="$attribute/tei:cell[@role='name']
			      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']"/>
        <xsl:variable name="value"
                      select="substring-before(substring-after($atts,concat(' ',$name,'=')),$secondary-separator)"/>
	<!--xsl:message>
	  <xsl:text>!!!</xsl:text>
	  <xsl:value-of select="$attribute"/>
	  <xsl:text>, </xsl:text>
	  <xsl:value-of select="$position"/>
	  <xsl:text> // </xsl:text>
	  <xsl:value-of select="$name"/>
	  <xsl:text> .. </xsl:text>
	  <xsl:value-of select="$value"/>
        </xsl:message-->
        <xsl:choose>
          <xsl:when test="normalize-space($name) and normalize-space($value)">
            <xsl:value-of
                select="$attribute//
                        tei:row[tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']=$value]
                        /tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']"
                />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>-</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="convert">
          <xsl:with-param name="atts" select="$atts"/>
          <xsl:with-param name="position" select="$position + 1"/>
          <xsl:with-param name="category" select="$category"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>Warn on STDERR about problems.</xd:p>
  </xd:desc></xd:doc>
  <xsl:template name="warn">
    <xsl:param name="text"/>
    <xsl:param name="output"/>
    <xsl:param name="code"/>
    <xsl:param name="localisation"/>
    <xsl:param name="language"/>
    <xsl:message terminate="no">
      <xsl:value-of select="$text"/>
      <xsl:text>: </xsl:text>
      <xsl:text> output = </xsl:text>
      <xsl:value-of select="$output"/>
      <xsl:text>  code = </xsl:text>
      <xsl:value-of select="$code"/>
      <xsl:text> language = </xsl:text>
      <xsl:value-of select="$language"/>
      <xsl:text> localisation = </xsl:text>
      <xsl:value-of select="$localisation"/>
      <xsl:text> localise to = </xsl:text>
      <xsl:value-of select="$localise"/>
      <xsl:text> !!! </xsl:text>
    </xsl:message>
  </xsl:template>
</xsl:stylesheet>
