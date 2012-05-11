<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" version="2.0">
    <!--   
        <purpose> customization of the default fcs-scan2view for sade</purpose>
        <history>  
        <change on="2012-05-02" type="created" by="vr">based on fcs-xsl/scan2view.xsl</change>	
        </history>
    --> 
    <!-- FIXME: very fragile! the referencing of the base stylesheet has to be solved more reliably/flexibly -->
    <xsl:import href="../../../../db/cr/xsl/scan2view.xsl"/>
    <xsl:param name="current-template"/>
    <xsl:param name="list-mode">list</xsl:param>
    <xsl:template name="header">
        <xsl:variable name="countTerms" select="/sru:scanResponse/sru:extraResponseData/fcs:countTerms"/>
        <xsl:variable name="start-item" select="'TODO:start-item=?'"/>
        <xsl:variable name="maximum-items" select="/sru:scanResponse/sru:echoedScanRequest/sru:scanClause"/>
        <div class="header">
            <xsl:attribute name="data-countTerms" select="$countTerms"/>
            <xsl:attribute name="start-item" select="$start-item"/>
            <xsl:attribute name="maximum-items" select="$maximum-items"/>
            <!--<xsl:value-of select="$title"/>-->
            <form>
                <input type="hidden" name="index" value="{$index}"/>
                <input type="text" name="scanClause" value="{$filter}"/>
                <input type="hidden" name="current-template" value="{$current-template}"/>
                <input type="hidden" name="operation" value="scan"/>
                <input type="hidden" name="x-format" value="{$format}"/>
                <input type="hidden" name="x-context" value="{$x-context}"/>
                <input type="submit" value="filtern"/>
            </form>
            <div class="note">
                <xsl:value-of select="count(//sru:terms/sru:term)"/> von <xsl:value-of select="$countTerms"/> Einträgen</div>
        </div>
    </xsl:template>
</xsl:stylesheet>