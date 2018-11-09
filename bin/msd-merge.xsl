<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		exclude-result-prefixes="tei xd">
  <xd:doc>
    <xd:desc>
      <xd:p>Stylesheet for MULTEXT-East morphosyntactic specifications. Merges language
      specific specification to common specification.</xd:p>
      <xd:p>Stylesheet takes the common specifications, in particular the tables defining
      categories (PoS), their attributes and values, and modifies these tables so that they
      correspond to the (tables of a) language specific (l.s.) section, i.e. it merges the l.s.
      tables into the common ones. The stylesheet reports on attributes and values removed or
      added to the common specifications on STDERR.</xd:p>
      <xd:p>Author: Tomaž Erjavec tomaz.erjavec@ijs.si</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="p"/>
  
  <xd:doc><xd:desc>
    <xd:p>The language specific morphosyntactic specification</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="add"/>

  <xd:doc><xd:desc>
    <xd:p>If set (to whatever) then comments will be written in the output specification in places where it has been modified</xd:p>
  </xd:desc></xd:doc>
  <xsl:param name="debug">yes</xsl:param>

  <xsl:variable name="lang" select="document($add)/tei:div/@select"/>
  
  <xd:doc><xd:desc>
    <xd:p>Process Category table from common specifications</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:table[@n='msd.cat']">
    <xsl:variable name="cat-name" select="tei:row[@role='type']/tei:cell[@role='value']"/>
    <!-- the tree fragment from the (modified) language category table -->
    <xsl:variable name="add-category"
		  select="document($add)//tei:table[@n='msd.cat'][tei:row[@role='type']/tei:cell[@role='value']=$cat-name]"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:head"/>
      <xsl:apply-templates mode="merge" select="tei:row[@role='type']">
        <xsl:with-param name="add-type"
			select="$add-category/tei:row[@role='type']"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="merge" select="tei:row[@role='attribute']">
        <xsl:with-param name="cat-name" select="$cat-name"/>
        <xsl:with-param name="add-category" select="$add-category"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="new"
			   select="$add-category/tei:row[@role='attribute'][1]">
        <xsl:with-param name="cat-name" select="$cat-name"/>
        <xsl:with-param name="com-category" select="."/>
        <xsl:with-param name="com-position">
          <xsl:choose>
            <xsl:when test="tei:row[@role='attribute']">
              <xsl:value-of select="tei:row[@role='attribute'][last()]/tei:cell[@role='position'] + 1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>1</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Process Type row</xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="merge" match="tei:row[@role='type']">
    <xsl:param name="add-type"/>
    <xsl:variable name="cat-name" select="tei:cell[@role='value']"/>
    <xsl:variable name="message-str" select="concat('category ', $cat-name)"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:cell[not(@role='lang')] | comment()"/>
      <xsl:choose>
        <xsl:when
            test="not(normalize-space($add-type)) and not(tei:cell[@role='lang']=$lang)">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
        </xsl:when>
        <xsl:when test="not(normalize-space($add-type)) and tei:cell[@role='lang']=$lang">
          <xsl:call-template name="message">
            <xsl:with-param name="msg" select="concat('removed from ',$message-str)"/>
          </xsl:call-template>
          <xsl:apply-templates select="tei:cell[@role='lang'][text() != $lang]"/>
        </xsl:when>
        <xsl:when test="normalize-space($add-type) and not(tei:cell[@role='lang']=$lang)">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
          <xsl:call-template name="message">
            <xsl:with-param name="msg" select="concat('added to ',$message-str)"/>
          </xsl:call-template>
          <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="cell">
            <xsl:attribute name="role">lang</xsl:attribute>
            <xsl:value-of select="$lang"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="normalize-space($add-type) and tei:cell[@role='lang']=$lang">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Weird Type combo</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Process Attribute row</xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="merge" match="tei:row[@role='attribute']">
    <xsl:param name="cat-name"/>
    <xsl:param name="add-category"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="comment()"/>
      <xsl:apply-templates select="tei:cell[@role='position']"/>
      <xsl:apply-templates select="tei:cell[@role='name']"/>
      <xsl:element name="cell">
        <xsl:element name="table">
          <xsl:variable name="att-name" select="tei:cell[@role='name']"/>
          <xsl:variable name="add-attribute"
                        select="$add-category/tei:row[@role='attribute'][tei:cell[@role='name']=$att-name]/tei:cell/tei:table"/>
          <xsl:apply-templates mode="merge"
                               select="tei:cell/tei:table/tei:row[@role='value']">
            <xsl:with-param name="cat-name" select="$cat-name"/>
            <xsl:with-param name="att-name" select="$att-name"/>
            <xsl:with-param name="add-attribute" select="$add-attribute"/>
          </xsl:apply-templates>
          <xsl:apply-templates mode="new"
                               select="$add-attribute/tei:row[@role='value'][1]">
            <xsl:with-param name="cat-name" select="$cat-name"/>
            <xsl:with-param name="att-name" select="$att-name"/>
            <xsl:with-param name="com-attribute" select="tei:cell/tei:table"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Process Value row</xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="merge" match="tei:row[@role='value']">
    <xsl:param name="cat-name"/>
    <xsl:param name="att-name"/>
    <xsl:param name="add-attribute"/>
    <xsl:variable name="value" select="tei:cell[@role='name']"/>
    <xsl:variable name="add-value"
		  select="$add-attribute/tei:row[@role='value'][tei:cell[@role='name']=$value]"/>
    <xsl:variable name="message-str"
		  select="concat('feature ', $cat-name,'/',$att-name,'=',$value)"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="comment()"/>
      <xsl:apply-templates select="tei:cell[not(@role='lang')]"/>
      <xsl:choose>
        <xsl:when
            test="not(normalize-space($add-value)) and not(tei:cell[@role='lang']=$lang)">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
        </xsl:when>
        <xsl:when test="not(normalize-space($add-value)) and tei:cell[@role='lang']=$lang">
          <xsl:call-template name="message">
            <xsl:with-param name="msg" select="concat('removed from ',$message-str)"/>
          </xsl:call-template>
          <xsl:if test="not(normalize-space(tei:cell[@role='lang'][. != $lang]))">
            <xsl:call-template name="message">
              <xsl:with-param name="level">WARN</xsl:with-param>
              <xsl:with-param name="msg"
                              select="concat('NO LANGUAGES LEFT for ',$message-str)"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:apply-templates select="tei:cell[@role='lang'][. != $lang]"/>
        </xsl:when>
        <xsl:when test="normalize-space($add-value) and not(tei:cell[@role='lang']=$lang)">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
          <xsl:call-template name="message">
            <xsl:with-param name="msg" select="concat('added to ',$message-str)"/>
          </xsl:call-template>
          <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="cell">
            <xsl:attribute name="role">lang</xsl:attribute>
            <xsl:value-of select="$lang"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="normalize-space($add-value) and tei:cell[@role='lang']=$lang">
          <xsl:apply-templates select="tei:cell[@role='lang']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Weird value combo</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xd:doc><xd:desc>
    <xd:p>Check if l.s. table introduces new attributes, and merge them to the common table</xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="new" match="tei:row[@role='attribute']">
    <xsl:param name="cat-name"/>
    <xsl:param name="com-category"/>
    <xsl:param name="com-position"/>
    <xsl:variable name="att-name"
		  select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
    <xsl:choose>
      <xsl:when
          test="$com-category/tei:row[@role='attribute']/tei:cell[@role='name'] = $att-name">
        <xsl:apply-templates mode="new"
			     select="following-sibling::tei:row[@role='attribute'][1]">
          <xsl:with-param name="cat-name" select="$cat-name"/>
          <xsl:with-param name="com-category" select="$com-category"/>
          <xsl:with-param name="com-position" select="$com-position"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message-str"
                      select="concat('attribute ', $cat-name,'/',$att-name,' at position ',$com-position)"/>
        <xsl:call-template name="message">
          <xsl:with-param name="level">WARN</xsl:with-param>
          <xsl:with-param name="msg" select="concat('NEW ',$message-str)"/>
        </xsl:call-template>
        <xsl:element name="row">
          <xsl:attribute name="role">attribute</xsl:attribute>
          <xsl:element name="cell">
            <xsl:attribute name="role">position</xsl:attribute>
            <xsl:value-of select="$com-position"/>
          </xsl:element>
          <xsl:element name="cell">
            <xsl:attribute name="role">name</xsl:attribute>
            <xsl:value-of select="$att-name"/>
          </xsl:element>
          <xsl:element name="cell">
            <xsl:element name="table">
              <xsl:for-each select="tei:cell/tei:table/tei:row">
                <xsl:element name="row">
                  <xsl:attribute name="role">value</xsl:attribute>
                  <xsl:element name="cell">
                    <xsl:attribute name="role">name</xsl:attribute>
                    <xsl:value-of
                        select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"
                        />
                  </xsl:element>
                  <xsl:element name="cell">
                    <xsl:attribute name="role">code</xsl:attribute>
                    <xsl:value-of
                        select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"
                        />
                  </xsl:element>
                  <xsl:element name="cell">
                    <xsl:attribute name="role">lang</xsl:attribute>
                    <xsl:value-of select="$lang"/>
                  </xsl:element>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:element>
        </xsl:element>
        <xsl:apply-templates mode="new"
			     select="following-sibling::tei:row[@role='attribute'][1]">
          <xsl:with-param name="cat-name" select="$cat-name"/>
          <xsl:with-param name="com-category" select="$com-category"/>
          <xsl:with-param name="com-position" select="$com-position+1"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>Check if l.s. table introduces new values, and merge them to the common table</xd:p>
  </xd:desc></xd:doc>
  <xsl:template mode="new" match="tei:row[@role='value']">
    <xsl:param name="cat-name"/>
    <xsl:param name="com-attribute"/>
    <xsl:param name="att-name"/>
    <xsl:variable name="com-value" select="$com-attribute/tei:row[@role='value']"/>
    <xsl:variable name="val-name"
		  select="tei:cell[@role='name'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
    <xsl:variable name="code-name"
		  select="tei:cell[@role='code'][ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
    <xsl:if test="not(normalize-space($val-name))">
      <xsl:message terminate="yes">
        <xsl:text>Not value found in </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> for </xsl:text>
        <xsl:value-of select="$lang"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="message-str"
		  select="concat('value ', $cat-name,'/',$att-name,'=',$val-name,' with code ',$code-name)"/>
    <xsl:choose>
      <xsl:when test="$com-value/tei:cell[@role='name'] = $val-name"/>
      <xsl:otherwise>
        <xsl:call-template name="message">
          <xsl:with-param name="level">WARN</xsl:with-param>
          <xsl:with-param name="msg" select="concat('NEW ',$message-str)"/>
        </xsl:call-template>
        <xsl:if test="$com-value/tei:cell[@role='code'] = $code-name">
          <xsl:call-template name="message">
            <xsl:with-param name="level">!ERROR</xsl:with-param>
            <xsl:with-param name="msg" select="concat('CODE CLASH: NEW ',$message-str)"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:element name="row">
          <xsl:attribute name="role">value</xsl:attribute>
          <xsl:element name="cell">
            <xsl:attribute name="role">name</xsl:attribute>
            <xsl:value-of select="$val-name"/>
          </xsl:element>
          <xsl:element name="cell">
            <xsl:attribute name="role">code</xsl:attribute>
            <xsl:value-of select="$code-name"/>
          </xsl:element>
          <xsl:element name="cell">
            <xsl:attribute name="role">lang</xsl:attribute>
            <xsl:value-of select="$lang"/>
          </xsl:element>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="new" select="following-sibling::tei:row[@role='value'][1]">
      <xsl:with-param name="cat-name" select="$cat-name"/>
      <xsl:with-param name="att-name" select="$att-name"/>
      <xsl:with-param name="com-attribute" select="$com-attribute"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xd:doc><xd:desc>
    <xd:p>By default pass through</xd:p>
  </xd:desc></xd:doc>
  <xsl:template match="tei:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|text()|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="comment()|processing-instruction()">
    <xsl:copy/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:cell[@role='lang']">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()|text()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="message">
    <xsl:param name="msg"/>
    <xsl:param name="level"/>
    <xsl:variable name="str">
      <xsl:if test="normalize-space($level)">
        <xsl:value-of select="$level"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:value-of select="$lang"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:variable>
    <xsl:message>
      <xsl:value-of select="$str"/>
    </xsl:message>
    <xsl:if test="$debug">
      <xsl:comment>
        <xsl:value-of select="$str"/>
      </xsl:comment>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
