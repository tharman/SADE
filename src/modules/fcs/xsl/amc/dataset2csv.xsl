<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="1.0" extension-element-prefixes="exsl xd">
    <xsl:output method="text" media-type="text/css" encoding="UTF-8"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> 2012-12-10</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> m</xd:p>
            <xd:p>based on <xd:ref>dataset2table.xsl</xd:ref>
            </xd:p>
            <xd:p>stylesheet to produce a csv-format out of the internal dataset-representation</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="field-separator" select="';'"/>
    <xsl:param name="row-separator" select="'&#xA;'"/>
    <xsl:decimal-format decimal-separator="," grouping-separator="."/>
    <xsl:template match="/|node()">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="text()"/>
    <xsl:template match="labels">
        <xsl:text>key</xsl:text>
        <xsl:value-of select="$field-separator"/>
        <xsl:text>hits</xsl:text>
        <xsl:value-of select="$field-separator"/>
        <xsl:apply-templates/>
        <xsl:value-of select="$row-separator"/>
    </xsl:template>
    <xsl:template match="dataseries">
        <xsl:value-of select="@name"/>
        <xsl:value-of select="$field-separator"/>
        <xsl:value-of select="format-number(@hits,'#.###')"/>
        <xsl:value-of select="$field-separator"/>
        <xsl:apply-templates/>
        <xsl:value-of select="$row-separator"/>
    </xsl:template>
    <xsl:template match="label">
        <xsl:value-of select="."/>
        <xsl:value-of select="$field-separator"/>
        <xsl:value-of select="concat(., 'freq')"/>
        <xsl:value-of select="$field-separator"/>
    </xsl:template>
    <xsl:template match="value">
        <xsl:value-of select="@formatted"/>
        <xsl:value-of select="$field-separator"/>
      <!-- <xsl:value-of select="@formatted" />-->
        <xsl:value-of select="@rel_formatted"/>
        <xsl:value-of select="$field-separator"/>
    </xsl:template>
</xsl:stylesheet>