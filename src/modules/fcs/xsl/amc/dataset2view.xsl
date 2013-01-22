<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="exsl">
    <xsl:import href="amc-helpers.xsl"/>
    <xsl:import href="dataset2table.xsl"/>
    <xsl:import href="dataset2google-json.xsl"/>
    <xsl:include href="../commons_v2.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b>  2013-01-15</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> matej</xd:p>
            <xd:p>based on amc.xsl</xd:p>
            <xd:p>from amc views it shall only render the dataset</xd:p>
            <xd:p>to be used alone?
                or who provides the html-boilerplate </xd:p>
            <xd:p>expects data as dataset (dataset.xsd)</xd:p>
            <xd:p>it is displayed as separate table and chart.</xd:p>
            <xd:p>Example:                
                <xd:pre><![CDATA[
 <dataseries name="haus">
   <value label="all" 
          formatted="1.153.332" 
          abs="1153332" 
          rel="0.04224215720642085"
          rel_formatted="42.242,16">
      42242.16
   </value>
  </dataseries>]]></xd:pre>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="html" indent="yes" omit-xml-declaration="no" media-type="text/html; charset=UTF-8" encoding="utf-8"/>
    <xsl:template name="continue-root">
        <div>
            <!--<xsl:call-template name="callback-header-dataset"></xsl:call-template>-->
            <xsl:apply-templates select="//dataset">
<!--            datasets with less categories come first-->
                <xsl:sort select="count(labels/label)" data-type="number" order="ascending"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>

<!--
    <xsl:template match="result" mode="record-data">
<!-\-        <xsl:call-template name="callback-header-dataset"></xsl:call-template>-\->
        
        
        <xsl:apply-templates select="//dataset">
            <!-\-            datasets with less categories come first-\->
            <xsl:sort select="count(labels/label)" data-type="number" order="ascending"/>
        </xsl:apply-templates>
    </xsl:template>
    
-->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>invokes appropriate template (<xd:ref name="pivot2data" type="template"/> or <xd:ref name="qx2data" type="template"/>) to generate a unified internal representation of the data 
                 (<xd:ref>dataset</xd:ref> nodeset in the <xd:ref>chart-data</xd:ref> variable), creates the html-boilerplate
                and calls the templates to produce the table and chart representation of the data.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="dataset">
        <xsl:variable name="corrected-dataset">
            <xsl:apply-templates select="." mode="correct"/>
        </xsl:variable>
<!--            <xsl:apply-templates  mode="query-input"/>-->
<!--            <xsl:copy-of select="$corrected-dataset"/>-->
        <xsl:variable name="dataset-name" select="concat(@name,position())"/>
        <xsl:if test="contains($parts,'chart')">
            <div class="infovis-wrapper">
                <div id="infovis-navi-{$dataset-name}">
<!--                        <a onclick="drawChart({position() - 1})" ><xsl:value-of select="@name"/></a>-->
                    
<!--                    <a onclick="toggleStacked();" >stacked</a>-->
                    <a onclick="toggleLayout('{$dataset-name}');">layout</a>
                </div>
                <div class="infovis" id="chart-{$dataset-name}"/>
            </div>
            <xsl:call-template name="chart-google">
                <xsl:with-param name="data">
                    <xsl:apply-templates select="$corrected-dataset" mode="invert"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="contains($parts,'table')">
                <!--<form id="filter-form">
                    <input type="text" id="filter" />
                </form>-->
            <xsl:apply-templates select="$corrected-dataset" mode="data2table">
                    <!--                    <xsl:with-param name="data" select="$chart-data"></xsl:with-param>-->
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*" mode="correct">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="correct"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="dataseries" mode="correct">
        <xsl:variable name="q" select="ancestor::result/lst[@name='params']/str[@name='q']"/>
<!--        <xsl:variable name="qkey" select="ancestor::result/lst[@name='params']/str[@name='qkey']"/>-->
        <xsl:variable name="qkey" select="normalize-space(ancestor::result/lst[@name='params']/str[@name='qkey'])"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@type='reldata' and $qkey">
                    <xsl:attribute name="name" select="$qkey"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="name" select="translate(@name,'&#34;','')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@*[not(name()='name')]"/>
            <xsl:apply-templates mode="correct"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="label" mode="correct">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="text()">
                    <xsl:value-of select="text()"/>
                </xsl:when>
                <xsl:otherwise>_EMPTY_</xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="callback-header">
        <xsl:call-template name="callback-header-dataset"/>
    </xsl:template>
    <xsl:template name="callback-header-dataset">
        <link rel="stylesheet" type="text/css" href="{concat($scripts-dir, 'style/jquery.ui.resizable.css')}"/>
        <link rel="stylesheet" type="text/css" href="{concat($scripts-dir, 'style/jquery.ui.all.css')}"/>
                <!--
                  	<xsl:call-template name="chart-jit" >
                        <xsl:with-param name="facet-list" select="//lst[@name='facet_fields']/lst[1]"></xsl:with-param>
                  	</xsl:call-template>
                -->
        <style type="text/css">
        table { border-collapse:collapse;  border:1px solid grey }
        td {padding: 3px; border:1px solid grey}
        div.infovis-wrapper {border: 1px solid grey; margin: 20px; padding: 5px; height:350px; width:700px;}
        .infovis {height: 90%; width: 100%;}
        .value { text-align: right; }
        </style>
        <script type="text/javascript" src="{concat($scripts-dir, 'js/jquery/jquery.min.js')}"/>
        <script type="text/javascript" src="{concat($scripts-dir, 'js/jquery/jquery-ui.min.js')}"/>
        <xsl:if test="contains($parts,'table')">
            <script type="text/javascript" src="{concat($scripts-dir, 'js/jquery/jquery.tablesorter.js')}"/>
            <script type="text/javascript" src="{concat($scripts-dir, 'js/jquery/jquery.uitablefilter.js')}"/>
        </xsl:if>
     
     <!-- it would be nicer, if this is in chart-xsl, but how to call it in a generic way -->
        <xsl:if test="contains($parts,'chart')">
            <xsl:call-template name="callback-header-chart"/>
        </xsl:if>
        
        <!--   <script type="text/javascript" src="{concat($scripts-dir, 'js/amc.js')}"></script>-->
    </xsl:template>
</xsl:stylesheet>