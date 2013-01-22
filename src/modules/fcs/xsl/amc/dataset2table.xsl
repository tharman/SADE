<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my="myFunctions" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" extension-element-prefixes="my exsl xd">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> 2012-09-26</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> m</xd:p>
            <xd:p>sub-stylesheet to produce a html table out of the internal dataset-representation</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="mode">dataseries-table</xsl:param>



  <!-- taken from cmd2graph.xsl -->
    <xsl:function name="my:normalize">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value,'*/-.'',$@={}:[]()#&gt;&lt; ','XZ__')"/>
    </xsl:function>
    <xsl:template match="/">
   <!-- some root element, to deliver well-formed x(ht)ml -->
        <div>
            <xsl:apply-templates select="*" mode="data2table"/>
        </div>
    </xsl:template>
    <xsl:template match="*" mode="data2table">
        <xsl:apply-templates select="*" mode="data2table"/>
    </xsl:template>
    <xsl:template match="dataset" mode="data2table">
        <xsl:param name="data" select="."/>
        <xsl:choose>
            <xsl:when test="$mode='dataseries-table'">
                <xsl:apply-templates select="$data" mode="dataseries-table"/>
            </xsl:when>
            <xsl:otherwise>
                <table>
                    <caption>
            <!--                        <xsl:value-of select="exsl:node-set($data)/@label"/>-->
                        <xsl:value-of select="$data/@label"/>
                    </caption>
                    <xsl:choose>
                        <xsl:when test="count($data/labels/label) &gt; count($data/dataseries)">
                            <xsl:variable name="inverted-dataset">
                <!--<xsl:apply-templates select="exsl:node-set($data)" mode="invert"/>-->
                                <xsl:apply-templates select="$data" mode="invert"/>
                            </xsl:variable>
                            <xsl:apply-templates select="$inverted-dataset" mode="table"/>
              <!--<xsl:copy-of select="."></xsl:copy-of>
                            <xsl:copy-of select="$inverted-dataset"></xsl:copy-of>-->
                        </xsl:when>
                        <xsl:otherwise>
              <!--                            <xsl:apply-templates select="exsl:node-set($data)" mode="table"/>-->
                            <xsl:apply-templates select="$data" mode="table"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </table>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  <!--<xsl:template match="dataset" mode="data2table">
    <xsl:param name="data" select="."></xsl:param>
<xsl:choose>
  
    <xsl:when test="$mode='dataseries-table'">
      <xsl:apply-templates select="$data" mode="dataseries-table"></xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
        <table >
          <caption><xsl:value-of select="exsl:node-set($data)/@label"/></caption>
          <xsl:choose>
            <xsl:when test="count($data/labels/label) > count($data/dataseries)">
              <xsl:variable name="inverted-dataset">
                <xsl:apply-templates select="exsl:node-set($data)" mode="invert"></xsl:apply-templates>
              </xsl:variable>
              
              <xsl:apply-templates select="$inverted-dataset" mode="table"></xsl:apply-templates>
            </xsl:when>
            
            <xsl:otherwise>
              <xsl:apply-templates select="exsl:node-set($data)" mode="table"></xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </table>
    </xsl:otherwise>
</xsl:choose>          

        
  </xsl:template>
  -->
    <xsl:template match="labels" mode="table">
        <thead>
            <tr>
                <th>key</th>
                <xsl:apply-templates mode="table"/>
            </tr>
        </thead>
    </xsl:template>
    <xsl:template match="dataseries" mode="table">
        <tr>
            <td>
                <xsl:value-of select="(@name,@label,@key)[not(.='')][1]"/>
                <xsl:if test="@type='reldata'">
                    <br/>
                    <xsl:value-of select="ancestor::dataset/@percentile-unit"/>
                </xsl:if>
            </td>
            <xsl:apply-templates mode="table"/>
        </tr>
    </xsl:template>
    <xsl:template match="labels" mode="dataseries-table"/>
    <xsl:template match="dataseries" mode="dataseries-table">
  <!--  variable $labels not used yet, todo :  -->
        <xsl:variable name="labels" select="../labels"/>
        <div id="{concat(my:normalize(../@key), '-', my:normalize(@key))}">
            <table>
                <caption>
                    <xsl:value-of select="(@name,@label,@key)[not(.='')][1]"/>
                </caption>
                <xsl:for-each select="value">
                    <tr>
                        <td>
                            <xsl:value-of select="(@label|@key)[not(.='')][1]"/>
                        </td>
                        <xsl:apply-templates select="." mode="table"/>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="label" mode="table">
        <th>
            <xsl:value-of select="(.|@key)[not(.='')][1]"/>
        </th>
    </xsl:template>
    <xsl:template match="value" mode="table">
        <td class="value number">
            <xsl:choose>
                <xsl:when test="@formatted">
                    <xsl:value-of select="@formatted"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <xsl:if test="@rel_formatted">
            <td class="value number">
                <xsl:value-of select="@rel_formatted"/>
            </td>
        </xsl:if>
      
<!--      <xsl:value-of select="@abs" />-->
<!--      <xsl:value-of select="@formatted" />-->
<!--      <xsl:if test="@rel_formatted">
        <br/><xsl:value-of select="@rel_formatted" />
      </xsl:if>-->
    </xsl:template>
    <xsl:template match="dataset" mode="invert">
        <xsl:param name="dataset" select="."/>
        <dataset>
            <xsl:copy-of select="@*"/>
            <labels>
                <xsl:for-each select="dataseries">
                    <label>
                        <xsl:if test="@type">
                            <xsl:attribute name="type" select="@type"/>
                        </xsl:if>
                        <xsl:if test="@key">
                            <xsl:attribute name="key" select="@key"/>
                        </xsl:if>
                        <xsl:value-of select="(@name, @label ,@key)[1]"/>
                    </label>
                </xsl:for-each>
            </labels>
            <xsl:for-each select="labels/label">
                <xsl:variable name="curr_label_old" select="(@key, text())[1]"/>
                <dataseries key="{$curr_label_old}" label="{text()}">
                    <xsl:for-each select="$dataset//value[$curr_label_old=@key or $curr_label_old=@label]">
                        <value key="{(../@name, ../@label,../@key)[not(.='')][1]}">
                            <xsl:copy-of select="@*[not(.='')]"/>
              <!-- formatted="{@formatted}"
                <xsl:if test="../@type"><xsl:attribute name="type" select="../@type"></xsl:attribute></xsl:if>-->
                            <xsl:value-of select="."/>
                        </value>
                    </xsl:for-each>
                </dataseries>
            </xsl:for-each>
        </dataset>
    </xsl:template>
</xsl:stylesheet>