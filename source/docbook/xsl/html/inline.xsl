<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                exclude-result-prefixes="xlink"
                version='1.0'>

<!-- ********************************************************************
     $Id: inline.xsl,v 1.4 2003/07/10 20:33:42 nilgun Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<xsl:template name="simple.xlink">
  <xsl:param name="node" select="."/>
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="$node/@xlink:type='simple' and $node/@xlink:href">
      <a>
        <xsl:if test="@xlink.title">
          <xsl:attribute name="title">
            <xsl:value-of select="@xlink:title"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:attribute name="href">
          <xsl:choose>
            <!-- if the href starts with # and does not contain an "(" -->
            <!-- or if the href starts with #xpointer(id(, it's just an ID -->
            <xsl:when test="starts-with(@xlink:href,'#')
                            and (not(contains(@xlink:href,'&#40;'))
                            or starts-with(@xlink:href,'#xpointer&#40;id&#40;'))">
              <xsl:variable name="idref">
                <xsl:call-template name="xpointer.idref">
                  <xsl:with-param name="xpointer" select="@xlink:href"/>
                </xsl:call-template>
              </xsl:variable>

              <xsl:variable name="targets" select="key('id',$idref)"/>
              <xsl:variable name="target" select="$targets[1]"/>

              <xsl:call-template name="check.id.unique">
                <xsl:with-param name="linkend" select="@linkend"/>
              </xsl:call-template>

              <xsl:choose>
                <xsl:when test="count($target) = 0">
                  <xsl:message>
                    <xsl:text>XLink to nonexistent id: </xsl:text>
                    <xsl:value-of select="$idref"/>
                  </xsl:message>
                  <xsl:text>???</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="href.target">
                    <xsl:with-param name="object" select="$target"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>

            <!-- otherwise it's a URI -->
            <xsl:otherwise>
              <xsl:value-of select="@xlink:href"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:copy-of select="$content"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="inline.charseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:copy-of select="$content"/>
</xsl:template>

<xsl:template name="inline.monoseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <tt><xsl:copy-of select="$content"/></tt>
</xsl:template>

<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <!-- don't put <b> inside figure, example, or table titles -->
  <xsl:choose>
    <xsl:when test="local-name(..) = 'title'
                    and (local-name(../..) = 'figure'
                         or local-name(../..) = 'example'
                         or local-name(../..) = 'table')">
      <xsl:copy-of select="$content"/>
    </xsl:when>
    <xsl:otherwise>
      <b><xsl:copy-of select="$content"/></b>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <i><xsl:copy-of select="$content"/></i>
</xsl:template>

<xsl:template name="inline.boldmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <!-- don't put <b> inside figure, example, or table titles -->
  <!-- or other titles that may already be represented with <b>'s. -->
  <xsl:choose>
    <xsl:when test="local-name(..) = 'title'
                    and (local-name(../..) = 'figure'
                         or local-name(../..) = 'example'
                         or local-name(../..) = 'table'
                         or local-name(../..) = 'formalpara')">
      <tt><xsl:copy-of select="$content"/></tt>
    </xsl:when>
    <xsl:otherwise>
      <b><tt><xsl:copy-of select="$content"/></tt></b>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <i><tt><xsl:copy-of select="$content"/></tt></i>
</xsl:template>

<xsl:template name="inline.superscriptseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <sup><tt><xsl:copy-of select="$content"/></tt></sup>
</xsl:template>

<xsl:template name="inline.subscriptseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <sub><tt><xsl:copy-of select="$content"/></tt></sub>
</xsl:template>

<!-- ==================================================================== -->
<!-- some special cases -->

<xsl:template match="author">
  <span class="{name(.)}"><xsl:call-template name="person.name"/></span>
</xsl:template>

<xsl:template match="editor">
  <span class="{name(.)}"><xsl:call-template name="person.name"/></span>
</xsl:template>

<xsl:template match="othercredit">
  <span class="{name(.)}"><xsl:call-template name="person.name"/></span>
</xsl:template>

<xsl:template match="authorinitials">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="accel">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="action">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="application">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="classname|signalname|enumname|propname">
  <xsl:call-template name="inline.boldmonoseq"/>
</xsl:template>

<xsl:template match="exceptionname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="interfacename">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="methodname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="command">
  <xsl:call-template name="inline.boldmonoseq"/>
</xsl:template>

<xsl:template match="computeroutput">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="constant">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="database">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="errorcode">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="errorname">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="errortype">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="envar">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="filename">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="function">
  <xsl:choose>
    <xsl:when test="$function.parens != '0'
                    and (parameter or function or replaceable)">
      <xsl:variable name="nodes" select="text()|*"/>
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:call-template name="simple.xlink">
            <xsl:with-param name="content">
              <xsl:apply-templates select="$nodes[1]"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="$nodes[position()>1]"/>
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:call-template name="inline.monoseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="function/parameter" priority="2">
  <xsl:call-template name="inline.italicmonoseq"/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="function/replaceable" priority="2">
  <xsl:call-template name="inline.italicmonoseq"/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="guibutton">
  <span class="guibutton">
  <xsl:text>[</xsl:text>
  <xsl:call-template name="inline.charseq"/>
  <xsl:text>]</xsl:text>
  </span>
</xsl:template>

<xsl:template match="guiicon">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="guilabel">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="guimenu">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="guimenuitem">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="guisubmenu">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="hardware">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="interface">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="interfacedefinition">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="keycap">
  <xsl:text>&lt;</xsl:text>
  <xsl:call-template name="inline.boldseq"/>
  <xsl:text>></xsl:text>
</xsl:template>

<xsl:template match="keycode">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="keysym">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="literal">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="medialabel">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="shortcut">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="mousebutton">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="option">
  <xsl:choose>
    <xsl:when test="(ancestor-or-self::refentry)">
      <xsl:call-template name="inline.boldmonoseq"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.monoseq"/>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:template>

<xsl:template match="parameter">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="property">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="prompt">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="replaceable" priority="1">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="returnvalue">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="structfield">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="structname">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="symbol">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="systemitem">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="token">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="type">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="userinput|statement">
  <xsl:call-template name="inline.boldmonoseq"/>
</xsl:template>

<xsl:template match="abbrev">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="acronym">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="citerefentry">
  <xsl:choose>
    <xsl:when test="$citerefentry.link != '0'">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="generate.citerefentry.link"/>
        </xsl:attribute>
        <xsl:call-template name="inline.charseq"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.charseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="generate.citerefentry.link">
  <!-- nop -->
</xsl:template>

<xsl:template name="x.generate.citerefentry.link">
  <xsl:text>http://example.com/cgi-bin/man.cgi?</xsl:text>
  <xsl:value-of select="refentrytitle"/>
  <xsl:text>(</xsl:text>
  <xsl:value-of select="manvolnum"/>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="citetitle">
  <xsl:choose>
    <xsl:when test="@pubwork = 'article'">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.italicseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="emphasis">
  <span>
    <xsl:choose>
      <xsl:when test="@role and $emphasis.propagates.style != 0">
        <xsl:attribute name="class">
          <xsl:value-of select="@role"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">
          <xsl:text>emphasis</xsl:text>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="anchor"/>

    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:choose>
          <xsl:when test="@role = 'bold'">
            <!-- backwards compatibility: make bold into b elements, but -->
            <!-- don't put bold inside figure, example, or table titles -->
            <xsl:choose>
              <xsl:when test="local-name(..) = 'title'
                              and (local-name(../..) = 'figure'
                              or local-name(../..) = 'example'
                              or local-name(../..) = 'table')">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <b><xsl:apply-templates/></b>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <i><xsl:apply-templates/></i>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </span>
</xsl:template>

<xsl:template match="foreignphrase">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="markup">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="phrase">
  <span>
    <xsl:if test="@role and $phrase.propagates.style != 0">
      <xsl:attribute name="class">
        <xsl:value-of select="@role"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </span>
</xsl:template>

<xsl:template match="quote">
  <xsl:text>“</xsl:text><xsl:apply-templates/><xsl:text>”</xsl:text>
<!--
  <xsl:variable name="depth">
    <xsl:call-template name="dot.count">
      <xsl:with-param name="string"><xsl:number level="multiple"/></xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$depth mod 2 = 0">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="gentext.nestedstartquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.nestedendquote"/>
    </xsl:otherwise>
  </xsl:choose>
-->
</xsl:template>

<xsl:template match="varname">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="wordasword">
  <span class="wordasword"><xsl:call-template name="inline.italicseq"/></span>
</xsl:template>

<xsl:template match="lineannotation">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="superscript">
  <xsl:call-template name="inline.superscriptseq"/>
</xsl:template>

<xsl:template match="subscript">
  <xsl:call-template name="inline.subscriptseq"/>
</xsl:template>

<xsl:template match="trademark">
  <xsl:call-template name="inline.charseq"/>
  <xsl:choose>
    <xsl:when test="@class = 'copyright'
                    or @class = 'registered'">
      <xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat" select="@class"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@class = 'service'">
      <sup>SM</sup>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>™</xsl:text>
      <!--xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat" select="'trademark'"/>
      </xsl:call-template-->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="firstterm">
  <xsl:call-template name="glossterm">
    <xsl:with-param name="firstterm" select="1"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="glossterm" name="glossterm">
  <xsl:param name="firstterm" select="0"/>
  <span>
    <xsl:if test="(@vendor)">
      <xsl:attribute name="title">
        <xsl:value-of select="@vendor"/>
      </xsl:attribute>
    </xsl:if>
  <xsl:choose>

    <xsl:when test="($firstterm.only.link = 0 or $firstterm = 1) and @linkend">
      <xsl:variable name="targets" select="key('id',@linkend)"/>
      <xsl:variable name="target" select="$targets[1]"/>

      <xsl:call-template name="check.id.unique">
        <xsl:with-param name="linkend" select="@linkend"/>
      </xsl:call-template>

      <a>
        <xsl:if test="@id">
          <xsl:attribute name="name">
            <xsl:value-of select="@id"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$target"/>
          </xsl:call-template>
        </xsl:attribute>

        <xsl:call-template name="inline.italicseq"/>
      </a>
    </xsl:when>

    <xsl:when test="not(@linkend)
                    and ($firstterm.only.link = 0 or $firstterm = 1)
                    and $glossary.collection != ''">
      <xsl:variable name="term">
        <xsl:choose>
          <xsl:when test="@baseform"><xsl:value-of select="@baseform"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="cterm"
           select="(document($glossary.collection,.)//glossentry[glossterm=$term])[1]"/>

      <!-- HACK HACK HACK! But it works... -->
      <!-- You'd need to do more work if you wanted to chunk on glossdiv, though -->

      <xsl:variable name="glossary" select="//glossary[@role='auto']"/>

      <xsl:if test="count($glossary) != 1">
        <xsl:message>
          <xsl:text>Warning: glossary.collection specified, but there are </xsl:text>
          <xsl:value-of select="count($glossary)"/>
          <xsl:text> automatic glossaries</xsl:text>
        </xsl:message>
      </xsl:if>

      <xsl:variable name="glosschunk">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="$glossary"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="chunkbase">
        <xsl:choose>
          <xsl:when test="contains($glosschunk, '#')">
            <xsl:value-of select="substring-before($glosschunk, '#')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$glosschunk"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="not($cterm)">
          <xsl:message>
            <xsl:text>There's no entry for </xsl:text>
            <xsl:value-of select="$term"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="$glossary.collection"/>
          </xsl:message>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="id">
            <xsl:text>gl.</xsl:text>
            <xsl:choose>
              <xsl:when test="$cterm/@id">
                <xsl:value-of select="$cterm/@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="generate-id($cterm)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <a href="{$chunkbase}#{$id}">
            <xsl:call-template name="inline.italicseq"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="not(@linkend)
                    and ($firstterm.only.link = 0 or $firstterm = 1)
                    and $glossterm.auto.link != 0">
      <xsl:variable name="term">
        <xsl:choose>
          <xsl:when test="@baseform">
            <xsl:value-of select="@baseform"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="targets"
                    select="//glossentry[glossterm=$term or glossterm/@baseform=$term]"/>
      <xsl:variable name="target" select="$targets[1]"/>

      <xsl:choose>
        <xsl:when test="count($targets)=0">
          <xsl:message>
            <xsl:text>Error: no glossentry for glossterm: </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>.</xsl:text>
          </xsl:message>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:if test="@id">
              <xsl:attribute name="name">
                <xsl:value-of select="@id"/>
              </xsl:attribute>
            </xsl:if>

            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="$target"/>
              </xsl:call-template>
            </xsl:attribute>

            <xsl:call-template name="inline.italicseq"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="(@vendor)">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="sgmltag">
  <xsl:call-template name="format.sgmltag"/>
</xsl:template>

<xsl:template name="format.sgmltag">
  <xsl:param name="class">
    <xsl:choose>
      <xsl:when test="@class">
        <xsl:value-of select="@class"/>
      </xsl:when>
      <xsl:otherwise>element</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <tt class="sgmltag-{$class}">
    <xsl:choose>
      <xsl:when test="$class='attribute'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='attvalue'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='element'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='endtag'">
        <xsl:text>&lt;/</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='genentity'">
        <xsl:text>&amp;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='numcharref'">
        <xsl:text>&amp;#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='paramentity'">
        <xsl:text>%</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='pi'">
        <xsl:text>&lt;?</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='xmlpi'">
        <xsl:text>&lt;?</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>?&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='starttag'">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='emptytag'">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>/&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='sgmlcomment'">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>--&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </tt>
</xsl:template>

<xsl:template match="email">
  <span class="email">
  <xsl:text>&lt;</xsl:text>
  <xsl:variable name="addr">
    <xsl:call-template name="nospam">
      <xsl:with-param name="p" select="text()"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="$addr"/>
    <!--
    <a>
      <xsl:variable name="addr">
       <xsl:call-template name="nospam">
         <xsl:with-param name="p" select="text()"/>
       </xsl:call-template>
     </xsl:variable>
     <xsl:attribute name="href">mailto:<xsl:value-of select="$addr"/></xsl:attribute>
     <xsl:value-of select="."/>
    </a>
    -->
    <xsl:text>&gt;</xsl:text>
    </span>
</xsl:template>

<xsl:template name="nospam">
  <xsl:param name="p"></xsl:param>

  <xsl:variable name="q" select="normalize-space($p)"/>
  <xsl:choose>
    <xsl:when test="contains($p,'@')">
      <xsl:call-template name="string.replace">
        <xsl:with-param name="string" select="$q"/>
        <xsl:with-param name="target" select="'@'"/>
        <xsl:with-param name="replace" select="' (at) '"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$q"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="keycombo">
  <xsl:variable name="action" select="@action"/>
  <xsl:variable name="joinchar">
    <xsl:choose>
      <xsl:when test="$action='seq'"><xsl:text> </xsl:text></xsl:when>
      <xsl:when test="$action='simul'">+</xsl:when>
      <xsl:when test="$action='press'">-</xsl:when>
      <xsl:when test="$action='click'">-</xsl:when>
      <xsl:when test="$action='double-click'">-</xsl:when>
      <xsl:when test="$action='other'"></xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:for-each select="*">
    <xsl:if test="position()>1"><xsl:value-of select="$joinchar"/></xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:for-each>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="menuchoice">
  <xsl:variable name="shortcut" select="./shortcut"/>
  <xsl:call-template name="process.menuchoice"/>
  <xsl:if test="$shortcut">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="$shortcut"/>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="process.menuchoice">
  <xsl:param name="nodelist" select="guibutton|guiicon|guilabel|guimenu|guimenuitem|guisubmenu|interface"/><!-- not(shortcut) -->
  <xsl:param name="count" select="1"/>

  <xsl:choose>
    <xsl:when test="$count>count($nodelist)"></xsl:when>
    <xsl:when test="$count=1">
      <xsl:apply-templates select="$nodelist[$count=position()]"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node" select="$nodelist[$count=position()]"/>
      <xsl:choose>
        <xsl:when test="name($node)='guimenuitem'
                        or name($node)='guisubmenu'">
          <xsl:text>-&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>+</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="$node"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="optional">
  <xsl:value-of select="$arg.choice.opt.open.str"/>
  <xsl:call-template name="inline.charseq"/>
  <xsl:value-of select="$arg.choice.opt.close.str"/>
</xsl:template>

<xsl:template match="citation">
  <!-- todo: biblio-citation-check -->
  <xsl:text>[</xsl:text>
  <xsl:call-template name="inline.charseq"/>
  <xsl:text>]</xsl:text>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="comment|remark">
  <xsl:if test="$show.comments != 0">
    <i><xsl:call-template name="inline.charseq"/></i>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="productname">
  <xsl:call-template name="inline.charseq"/>
  <xsl:if test="@class">
    <xsl:call-template name="dingbat">
      <xsl:with-param name="dingbat" select="@class"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="productnumber">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="pob|street|city|state|postcode|country|otheraddr">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="phone|fax">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- in Addresses, for example -->
<xsl:template match="honorific|firstname|surname|lineage|othername">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>

