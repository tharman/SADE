<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" xmlns:zr="http://explain.z3950.org/dtd/2.0/" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" version="1.0">
    <!-- 
        <purpose> generate a view for the explain-record (http://www.loc.gov/standards/sru/specs/explain.html) </purpose>
        <params>
        <param name=""></param>
        </params>
        <history>
        <change on="2012-02-05" type="created" by="vr">from scan2view.xsl, from model2view.xsl</change>
        
        </history>
       
    -->
    <xsl:import href="../commons_v1.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="lang" select="'de'"/>
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>
    <xsl:variable name="title">
        <xsl:text>explain: </xsl:text>
        <xsl:choose>
            <xsl:when test="//zr:databaseInfo/zr:title[@lang=$lang]/text()">
                <xsl:value-of select="//zr:databaseInfo/zr:title[@lang=$lang]/text()"/>
            </xsl:when>
            <xsl:when test="//zr:databaseInfo/zr:title/text()">
                <xsl:value-of select="//zr:databaseInfo/zr:title[1]/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$site_name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template name="continue-root">
        <xsl:apply-templates/>
        <!--<div class="explain-view">
            <xsl:apply-templates select="." mode="format-xmlelem"/>
        </div>-->
    </xsl:template>
    <xsl:template match="zr:serverInfo"/>
    <xsl:template match="zr:schemaInfo"/>
    <xsl:template match="zr:databaseInfo">
        <h2>
            <xsl:value-of select="zr:title[@lang=$lang]"/>
        </h2>
        <div>
            <xsl:value-of select="zr:description[@lang=$lang]"/>
        </div>
    </xsl:template>
    <xsl:template match="zr:indexInfo">
        <h3>Available indexes</h3>
        <ul class="zr:indexInfo">
            <xsl:apply-templates select="zr:index"/>
        </ul>
    </xsl:template>
    <xsl:template match="zr:index">
        <xsl:variable name="scan-index" select="concat('?operation=scan&amp;scanClause=', map/name , '&amp;x-context=', $x-context, '&amp;x-format=', $format )"/>
        <li>
            <a href="{$scan-index}">
                <xsl:choose>
                    <xsl:when test="zr:title[@lang=$lang]">
                        <xsl:value-of select="zr:title[@lang=$lang]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="zr:title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </li>
    </xsl:template>
    <!--
    <xsl:template match="*[@lang]" >
        
    </xsl:template>-->
</xsl:stylesheet>