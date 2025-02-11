<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<!-- ********************************************************************
     $Id: lists.xsl,v 1.3 2003/07/18 23:45:24 nilgun Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:template match="itemizedlist">
  <xsl:variable name="itemsymbol">
    <xsl:call-template name="list.itemsymbol"/>
  </xsl:variable>

  <xsl:call-template name="anchor"/>
  <xsl:if test="title">
    <xsl:apply-templates select="title" mode="liste.title"/>
  </xsl:if>
  <ul type="{$itemsymbol}" class="{name(.)}">
    <xsl:if test="@spacing='compact'">
      <xsl:attribute name="compact">
        <xsl:value-of select="@spacing"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="(indexterm)">
      <xsl:apply-templates select="indexterm"/>
    </xsl:if>
    <xsl:apply-templates select="listitem"/>
  </ul>
</xsl:template>

<xsl:template match="itemizedlist/listitem">
  <xsl:variable name="mark" select="../@mark"/>
  <xsl:variable name="override" select="@override"/>

  <xsl:variable name="usemark">
    <xsl:choose>
      <xsl:when test="$override != ''">
        <xsl:value-of select="$override"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$mark"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="cssmark">
    <xsl:choose>
      <xsl:when test="$usemark = 'bullet'">disc</xsl:when>
      <xsl:when test="$usemark = 'box'">square</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$usemark"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <li>
    <xsl:if test="$css.decoration = '1' and $cssmark != ''">
      <xsl:attribute name="style">
        <xsl:text>list-style-type: </xsl:text>
        <xsl:value-of select="$cssmark"/>
      </xsl:attribute>
    </xsl:if>

    <!-- we can't just drop the anchor in since some browsers (Opera)
         get confused about line breaks if we do. So if the first child
         is a para, assume the para will put in the anchor. Otherwise,
         put the anchor in anyway. -->
    <xsl:if test="local-name(child::*[1]) != 'para'">
      <xsl:call-template name="anchor"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$show.revisionflag and @revisionflag">
        <div class="{@revisionflag}">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </li>
</xsl:template>

<xsl:template name="orderedlist-starting-number">
  <xsl:param name="list" select="."/>
  <xsl:choose>
    <xsl:when test="$list/@continuation != 'continues'">1</xsl:when>
    <xsl:otherwise>
      <xsl:variable name="prevlist"
                    select="$list/preceding::orderedlist[1]"/>
      <xsl:choose>
        <xsl:when test="count($prevlist) = 0">2</xsl:when>
        <xsl:otherwise>
          <xsl:variable name="prevlength" select="count($prevlist/listitem)"/>
          <xsl:variable name="prevstart">
            <xsl:call-template name="orderedlist-starting-number">
              <xsl:with-param name="list" select="$prevlist"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$prevstart + $prevlength"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="orderedlist">
  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="@continuation='continues'">
        <xsl:call-template name="orderedlist-starting-number"/>
      </xsl:when>
      <xsl:when test="(@inheritnum)">
        <xsl:value-of select="@inheritnum"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="numeration">
    <xsl:call-template name="list.numeration"/>
  </xsl:variable>

  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="$numeration='arabic'">1</xsl:when>
      <xsl:when test="$numeration='loweralpha'">a</xsl:when>
      <xsl:when test="$numeration='lowerroman'">i</xsl:when>
      <xsl:when test="$numeration='upperalpha'">A</xsl:when>
      <xsl:when test="$numeration='upperroman'">I</xsl:when>
      <!-- What!? This should never happen -->
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unexpected numeration: </xsl:text>
          <xsl:value-of select="$numeration"/>
        </xsl:message>
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="anchor"/>
  <xsl:if test="title">
    <xsl:apply-templates select="title" mode="liste.title"/>
  </xsl:if>
  <ol class="{name(.)}">
  <xsl:if test="$start != '1'">
    <xsl:attribute name="start">
      <xsl:value-of select="$start"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="$numeration != ''">
    <xsl:attribute name="type">
      <xsl:value-of select="$type"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="@spacing='compact'">
    <xsl:attribute name="compact">
      <xsl:value-of select="compact"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test="(indexterm)">
    <xsl:apply-templates select="indexterm"/>
  </xsl:if>
  <xsl:apply-templates select="listitem"/>
  </ol>
</xsl:template>

<xsl:template match="orderedlist/listitem">
  <li><div class="listitem">
    <xsl:if test="@override">
      <xsl:attribute name="value">
        <xsl:value-of select="@override"/>
      </xsl:attribute>
    </xsl:if>

    <!-- we can't just drop the anchor in since some browsers (Opera)
         get confused about line breaks if we do. So if the first child
         is a para, assume the para will put in the anchor. Otherwise,
         put the anchor in anyway. -->
    <xsl:if test="local-name(child::*[1]) != 'para'">
      <xsl:call-template name="anchor"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$show.revisionflag and @revisionflag">
        <div class="{@revisionflag}">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </div></li>
</xsl:template>

<xsl:template match="variablelist">
  <xsl:variable name="pi-presentation">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'list-presentation'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="presentation">
    <xsl:choose>
      <xsl:when test="$pi-presentation != ''">
        <xsl:value-of select="$pi-presentation"/>
      </xsl:when>
      <xsl:when test="$variablelist.as.table != 0">
        <xsl:value-of select="'table'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'list'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="list-width">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'list-width'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="term-width">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'term-width'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="table-summary">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'table-summary'"/>
    </xsl:call-template>
  </xsl:variable>

  <div class="{name(.)}">
    <xsl:call-template name="anchor"/>
    <xsl:if test="title">
      <xsl:apply-templates select="title" mode="liste.title"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$presentation = 'table'">
        <table border="0">
          <xsl:if test="$list-width != ''">
            <xsl:attribute name="width">
              <xsl:value-of select="$list-width"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$table-summary != ''">
            <xsl:attribute name="summary">
              <xsl:value-of select="$table-summary"/>
            </xsl:attribute>
          </xsl:if>
          <col align="left">
            <xsl:if test="$term-width != ''">
              <xsl:attribute name="width">
                <xsl:value-of select="$term-width"/>
              </xsl:attribute>
            </xsl:if>
          </col>
          <tbody>
            <xsl:apply-templates select="varlistentry" mode="varlist-table"/>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <dl>
          <xsl:apply-templates select="varlistentry"/>
        </dl>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="title" mode="liste.title">
  <div class="halfpara">
    <b><xsl:apply-templates/></b>
  </div>
</xsl:template>

<xsl:template match="listitem" mode="xref">
  <xsl:number format="1"/>
</xsl:template>

<xsl:template match="listitem/simpara" priority="2">
  <!-- If a listitem contains only a single simpara, don't output
       the <p> wrapper; this has the effect of creating an li
       with simple text content. -->
  <xsl:choose>
    <xsl:when test="not(preceding-sibling::*)
                    and not (following-sibling::*)">
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <div class="para">
        <xsl:call-template name="anchor"/>
        <xsl:apply-templates/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="varlistentry">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="varlistentry" mode="varlist-table">
  <xsl:variable name="presentation">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="../processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'term-presentation'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="separator">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="../processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'term-separator'"/>
    </xsl:call-template>
  </xsl:variable>
  <tr>
    <td>
      <xsl:call-template name="anchor"/>
      <xsl:choose>
        <xsl:when test="$presentation = 'bold'">
          <b>
            <xsl:apply-templates select="term"/>
            <xsl:value-of select="$separator"/>
          </b>
        </xsl:when>
        <xsl:when test="$presentation = 'italic'">
          <i>
            <xsl:apply-templates select="term"/>
            <xsl:value-of select="$separator"/>
          </i>
        </xsl:when>
        <xsl:when test="$presentation = 'bold-italic'">
          <b>
            <i>
              <xsl:apply-templates select="term"/>
              <xsl:value-of select="$separator"/>
            </i>
          </b>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="term"/>
          <xsl:value-of select="$separator"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td>
      <xsl:apply-templates select="listitem"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="varlistentry/term">
  <dt>
  <xsl:choose>
    <xsl:when test="ancestor-or-self::refentry">
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
     <span class="term">
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
     </span>
    </xsl:otherwise>
  </xsl:choose>
  </dt>
</xsl:template>
<!--
<xsl:template match="varlistentry/term[position()=last()]" priority="2">
  <xsl:text> </xsl:text>
  <span class="term">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>
-->
<xsl:template match="varlistentry/listitem">
<dd class="varlist">
  <xsl:choose>
    <xsl:when test="$show.revisionflag and @revisionflag">
      <div class="{@revisionflag}">
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  <!--p/-->
</dd>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="simplelist">
  <!-- with no type specified, the default is 'vert' -->
  <xsl:call-template name="anchor"/>
  <table class="simplelist" border="0" summary="Basit bir liste">
    <xsl:call-template name="simplelist.vert">
      <xsl:with-param name="cols">
        <xsl:choose>
          <xsl:when test="@columns">
            <xsl:value-of select="@columns"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </table>
</xsl:template>

<xsl:template match="simplelist[@type='inline']">
  <span class="{name(.)}">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="simplelist[@type='horiz']">
  <xsl:call-template name="anchor"/>
  <table class="simplelist" border="0" summary="Yatay liste">
    <xsl:call-template name="simplelist.horiz">
      <xsl:with-param name="cols">
        <xsl:choose>
          <xsl:when test="@columns">
            <xsl:value-of select="@columns"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </table>
</xsl:template>

<xsl:template match="simplelist[@type='vert']">
  <xsl:call-template name="anchor"/>
  <table class="simplelist" border="0" summary="Düşey liste">
    <xsl:call-template name="simplelist.vert">
      <xsl:with-param name="cols">
        <xsl:choose>
          <xsl:when test="@columns">
            <xsl:value-of select="@columns"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </table>
</xsl:template>

<xsl:template name="simplelist.horiz">
  <xsl:param name="cols">1</xsl:param>
  <xsl:param name="cell">1</xsl:param>
  <xsl:param name="members" select="./member"/>

  <xsl:if test="$cell &lt;= count($members)">
    <tr>
      <xsl:call-template name="simplelist.horiz.row">
        <xsl:with-param name="cols" select="$cols"/>
        <xsl:with-param name="cell" select="$cell"/>
        <xsl:with-param name="members" select="$members"/>
      </xsl:call-template>
   </tr>
    <xsl:call-template name="simplelist.horiz">
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="cell" select="$cell + $cols"/>
      <xsl:with-param name="members" select="$members"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="simplelist.horiz.row">
  <xsl:param name="cols">1</xsl:param>
  <xsl:param name="cell">1</xsl:param>
  <xsl:param name="members" select="./member"/>
  <xsl:param name="curcol">1</xsl:param>

  <xsl:if test="$curcol &lt;= $cols">
    <td>
      <xsl:choose>
        <xsl:when test="$members[position()=$cell]">
          <xsl:apply-templates select="$members[position()=$cell]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$using.chunker != 0">
              <xsl:text>&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <xsl:call-template name="simplelist.horiz.row">
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="cell" select="$cell+1"/>
      <xsl:with-param name="members" select="$members"/>
      <xsl:with-param name="curcol" select="$curcol+1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="simplelist.vert">
  <xsl:param name="cols">1</xsl:param>
  <xsl:param name="cell">1</xsl:param>
  <xsl:param name="members" select="./member"/>
  <xsl:param name="rows"
             select="floor((count($members)+$cols - 1) div $cols)"/>

  <xsl:if test="$cell &lt;= $rows">
    <tr>
      <xsl:call-template name="simplelist.vert.row">
        <xsl:with-param name="cols" select="$cols"/>
        <xsl:with-param name="rows" select="$rows"/>
        <xsl:with-param name="cell" select="$cell"/>
        <xsl:with-param name="members" select="$members"/>
      </xsl:call-template>
    </tr>
    <xsl:call-template name="simplelist.vert">
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="cell" select="$cell+1"/>
      <xsl:with-param name="members" select="$members"/>
      <xsl:with-param name="rows" select="$rows"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="simplelist.vert.row">
  <xsl:param name="cols">1</xsl:param>
  <xsl:param name="rows">1</xsl:param>
  <xsl:param name="cell">1</xsl:param>
  <xsl:param name="members" select="./member"/>
  <xsl:param name="curcol">1</xsl:param>

  <xsl:if test="$curcol &lt;= $cols">
    <td>
      <xsl:choose>
        <xsl:when test="$members[position()=$cell]">
          <xsl:apply-templates select="$members[position()=$cell]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$using.chunker != 0">
              <xsl:text>&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <xsl:call-template name="simplelist.vert.row">
      <xsl:with-param name="cols" select="$cols"/>
      <xsl:with-param name="rows" select="$rows"/>
      <xsl:with-param name="cell" select="$cell+$rows"/>
      <xsl:with-param name="members" select="$members"/>
      <xsl:with-param name="curcol" select="$curcol+1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="member">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="simplelist[@type='inline']/member">
  <xsl:apply-templates/>
  <xsl:text>, </xsl:text>
</xsl:template>

<xsl:template match="simplelist[@type='inline']/member[position()=last()]"
              priority="2">
  <xsl:apply-templates/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="procedure">
  <div class="{name(.)}">
    <xsl:call-template name="anchor"/>
    <xsl:if test="title or $formal.procedures != 0">
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
    <xsl:apply-templates select="*[local-name()!='step']"/>

    <xsl:choose>
      <xsl:when test="count(step) = 1">
        <ul>
          <xsl:apply-templates select="step"/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <ol>
          <xsl:attribute name="type">
            <xsl:value-of select="substring($procedure.step.numeration.formats,1,1)"/>
          </xsl:attribute>
          <xsl:apply-templates select="step"/>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="procedure/title">
</xsl:template>

<xsl:template match="title" mode="procedure.title.mode">
  <div class="proctitle"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="substeps">
  <xsl:variable name="numeration">
    <xsl:call-template name="procedure.step.numeration"/>
  </xsl:variable>

  <xsl:call-template name="anchor"/>

  <ol type="{$numeration}">
    <xsl:apply-templates/>
  </ol>
</xsl:template>

<xsl:template match="step">
  <li>
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<xsl:template match="step/title">
  <xsl:apply-templates select="." mode="procedure.title.mode"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="segmentedlist">
  <xsl:variable name="presentation">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'list-presentation'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="anchor"/>

  <xsl:choose>
    <xsl:when test="$presentation = 'table'">
      <xsl:apply-templates select="." mode="seglist-table"/>
    </xsl:when>
    <xsl:when test="$presentation = 'list'">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:when test="$segmentedlist.as.table != 0">
      <xsl:apply-templates select="." mode="seglist-table"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="segmentedlist/title">
  <div class="segmentedtitle"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="segtitle">
</xsl:template>

<xsl:template match="segtitle" mode="segtitle-in-seg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="seglistitem">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="seg">
  <xsl:variable name="segnum" select="position()"/>
  <xsl:variable name="seglist" select="ancestor::segmentedlist"/>
  <xsl:variable name="segtitles" select="$seglist/segtitle"/>

  <!--
     Note: segtitle is only going to be the right thing in a well formed
     SegmentedList.  If there are too many Segs or too few SegTitles,
     you'll get something odd...maybe an error
  -->

  <div class="para">
    <b>
      <xsl:apply-templates select="$segtitles[$segnum=position()]"
                           mode="segtitle-in-seg"/>
      <xsl:text>: </xsl:text>
    </b>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="segmentedlist" mode="seglist-table">
  <xsl:variable name="table-summary">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'table-summary'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="list-width">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbhtml')"/>
      <xsl:with-param name="attribute" select="'list-width'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:apply-templates select="title" mode="seglist-table"/>
  <table border="0">
    <xsl:if test="$list-width != ''">
      <xsl:attribute name="width">
        <xsl:value-of select="$list-width"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="$table-summary != ''">
      <xsl:attribute name="summary">
        <xsl:value-of select="$table-summary"/>
      </xsl:attribute>
    </xsl:if>
    <thead>
      <tr>
        <xsl:apply-templates select="segtitle" mode="seglist-table"/>
      </tr>
    </thead>
    <tbody>
      <xsl:apply-templates select="seglistitem" mode="seglist-table"/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="segtitle" mode="seglist-table">
  <th><xsl:apply-templates/></th>
</xsl:template>

<xsl:template match="seglistitem" mode="seglist-table">
  <tr>
    <xsl:apply-templates mode="seglist-table"/>
  </tr>
</xsl:template>

<xsl:template match="seg" mode="seglist-table">
  <td><xsl:apply-templates/></td>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="calloutlist">
  <div class="{name(.)}">
    <xsl:call-template name="anchor"/>
    <xsl:if test="./title">
      <div class="callouttitle">
        <xsl:apply-templates select="./title" mode="calloutlist.title.mode"/>
      </div>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$callout.list.table != 0">
        <table border="0" summary="Dikkat edilecek hususlar" cellspacing="0" cellpadding="3" width="100%">
          <xsl:apply-templates/>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <dl compact="compact"><xsl:apply-templates/></dl>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="calloutlist/title">
</xsl:template>

<xsl:template match="calloutlist/title" mode="calloutlist.title.mode">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="callout">
  <xsl:choose>
    <xsl:when test="$callout.list.table != 0">
      <tr>
        <td width="15" valign="top" align="left" class="coimage">
          <xsl:call-template name="anchor"/>
          <xsl:call-template name="callout.arearefs">
            <xsl:with-param name="arearefs" select="@arearefs"/>
          </xsl:call-template>
        </td>
        <td valign="top" align="left">
          <xsl:apply-templates/>
        </td>
      </tr>
    </xsl:when>
    <xsl:otherwise>
      <dt>
        <xsl:call-template name="anchor"/>
        <xsl:call-template name="callout.arearefs">
          <xsl:with-param name="arearefs" select="@arearefs"/>
        </xsl:call-template>
      </dt>
      <dd><xsl:apply-templates/></dd>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="callout.arearefs">
  <xsl:param name="arearefs"></xsl:param>
  <xsl:if test="$arearefs!=''">
    <xsl:choose>
      <xsl:when test="substring-before($arearefs,' ')=''">
        <xsl:call-template name="callout.arearef">
          <xsl:with-param name="arearef" select="$arearefs"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="callout.arearef">
          <xsl:with-param name="arearef"
                          select="substring-before($arearefs,' ')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="callout.arearefs">
      <xsl:with-param name="arearefs"
                      select="substring-after($arearefs,' ')"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="callout.arearef">
  <xsl:param name="arearef"></xsl:param>
  <xsl:variable name="targets" select="key('id',$arearef)"/>
  <xsl:variable name="target" select="$targets[1]"/>

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="$arearef"/>
  </xsl:call-template>

  <xsl:choose>
    <xsl:when test="count($target)=0">
      <xsl:text>???</xsl:text>
    </xsl:when>
    <xsl:when test="local-name($target)='co'">
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$arearef"/>
        </xsl:attribute>
        <xsl:apply-templates select="$target" mode="callout-bug">
          <xsl:with-param name="owner" select="name(.)"/>
        </xsl:apply-templates>
      </a>
      <xsl:text> </xsl:text>
    </xsl:when>
    <xsl:when test="local-name($target)='areaset'">
      <xsl:call-template name="callout-bug">
        <xsl:with-param name="conum">
          <xsl:apply-templates select="$target" mode="conumber"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="local-name($target)='area'">
      <xsl:choose>
        <xsl:when test="$target/parent::areaset">
          <xsl:call-template name="callout-bug">
            <xsl:with-param name="conum">
              <xsl:apply-templates select="$target/parent::areaset"
                                   mode="conumber"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="callout-bug">
            <xsl:with-param name="conum">
              <xsl:apply-templates select="$target" mode="conumber"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>???</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>

