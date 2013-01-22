<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" version="2.0">
    <!-- 
        <purpose>XSLT-2 generate a view for the explain-record (http://www.loc.gov/standards/sru/specs/explain.html) </purpose>
        <params>
        <param name=""></param>
        </params>
        <history>
        <change on="2012-02-05" type="created" by="vr">from scan2view.xsl, from model2view.xsl</change>
        
        </history>
       
    -->
    <xsl:import href="../commons_v2.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="lang" select="'de'"/>
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>
    <xsl:variable name="title" select="concat('explain: ', (//databaseInfo/title[@lang=$lang]/text(), $site_name)[1])"/>
    <xsl:template name="continue-root">
        <xsl:apply-templates/>
        <!--<div class="explain-view">
            <xsl:apply-templates select="." mode="format-xmlelem"/>
        </div>-->
    </xsl:template>
    <xsl:template match="serverInfo"/>
    <xsl:template match="schemaInfo"/>
    <xsl:template match="databaseInfo">
        <h2>
            <xsl:value-of select="title[@lang=$lang]"/>
        </h2>
        <div>
            <xsl:value-of select="description[@lang=$lang]"/>
        </div>
    </xsl:template>
    <xsl:template match="indexInfo">
        <h3>Available indexes</h3>
        <ul class="indexInfo">
            <xsl:apply-templates select="index"/>
        </ul>
    </xsl:template>
    <xsl:template match="index">
        <xsl:variable name="scan-index" select="concat('?operation=scan&amp;scanClause=', map/name , '&amp;x-context=', $x-context, '&amp;x-format=', $format )"/>
        <li>
            <a href="{$scan-index}">
                <xsl:value-of select="(title[@lang=$lang],title)[1]"/>
            </a>
        </li>
    </xsl:template>
    <!--
    <xsl:template match="*[@lang]" >
        
    </xsl:template>-->
</xsl:stylesheet>