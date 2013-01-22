<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" version="2.0">
    <!-- 
<purpose> generate a view for a values-list (index scan) </purpose>
<params>
<param name=""></param>
</params>
<history>
	<change on="2012-02-06" type="created" by="vr">from values2view.xsl, from model2view.xsl</change>
		
</history>

<sample >
<sru:scanResponse xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0/">
<sru:version>1.2</sru:version>
   <sru:terms path="//div[@type='diary-day']/p/date/substring(xs:string(@value),1,7)">
        <sru:term>
        <sru:value>1903-01</sru:value>
        <sru:numberOfRecords>30</sru:numberOfRecords>
        </sru:term>
        <sru:term>
        <sru:value>1903-02</sru:value>
        <sru:numberOfRecords>28</sru:numberOfRecords>
        </sru:term>
        <sru:term>
        <sru:value>1903-03</sru:value>
        <sru:numberOfRecords>31</sru:numberOfRecords>
        </sru:term>
   </sru:terms>
   <sru:extraResponseData>
        <fcs:countTerms>619</fcs:countTerms>
    </sru:extraResponseData>
    <sru:echoedScanRequest>
        <sru:scanClause>diary-month</sru:scanClause>
        <sru:maximumTerms>100</sru:maximumTerms>
    </sru:echoedScanRequest>        
 <sru:scanResponse>
 
</sample>
-->
    <xsl:import href="../commons_v2.xsl"/>


    <!-- <xsl:param name="size_lowerbound">0</xsl:param>
<xsl:param name="max_depth">0</xsl:param>
<xsl:param name="freq_limit">20</xsl:param>
<xsl:param name="show">file</xsl:param> -->
    <xsl:param name="sort">x</xsl:param>
    <!-- s=size|n=name|t=time|x=default -->
    <xsl:param name="name_col_width">50%</xsl:param>
    <xsl:param name="list-mode">table</xsl:param>

    <!-- <xsl:param name="mode" select="'htmldiv'" />     -->
    <xsl:param name="title" select="concat('scan: ', $scanClause )"/>

    <!--
<xsl:param name="detail_uri_prefix"  select="'?q='"/> 
-->
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>
    <xsl:param name="scanClause" select="/sru:scanResponse/sru:echoedScanRequest/sru:scanClause"/>
    <xsl:param name="scanClause-array" select="tokenize($scanClause,'=')"/>
    <xsl:param name="index" select="$scanClause-array[1]"/>
    <xsl:param name="filter" select="$scanClause-array[2]"/>
    <xsl:template name="continue-root">
        <div> <!-- class="cmds-ui-block  init-show" -->
            <xsl:if test="$format = 'htmlpage'">
                <xsl:call-template name="header"/>
            </xsl:if>
            <div class="content">
                <xsl:apply-templates select="/sru:scanResponse/sru:terms"/>
            </div>
        </div>
    </xsl:template>
    
    <!-- <sru:extraResponseData>
        <fcs:countTerms>619</fcs:countTerms>
        </sru:extraResponseData>
        <sru:echoedScanRequest>
        <sru:scanClause>diary-month</sru:scanClause>
        <sru:maximumTerms>100</sru:maximumTerms>        
        </sru:echoedScanRequest> -->
    <xsl:template name="header">
        <xsl:variable name="countTerms" select="/sru:scanResponse/sru:extraResponseData/fcs:countTerms"/>
        <xsl:variable name="start-item" select="'TODO:start-item=?'"/>
        <xsl:variable name="maximum-items" select="/sru:scanResponse/sru:echoedScanRequest/sru:scanClause"/>
        
        <!--  <h2>MDRepository Statistics - index values</h2>  -->
        <div class="header">
            <xsl:attribute name="data-countTerms" select="$countTerms"/>
            <xsl:attribute name="start-item" select="$start-item"/>
            <xsl:attribute name="maximum-items" select="$maximum-items"/>
            <!--<xsl:value-of select="$title"/>-->
            <form>
                <input type="text" name="index" value="{$index}"/>
                <input type="text" name="scanClause" value="{$filter}"/>
                <input type="hidden" name="operation" value="scan"/>
                <input type="hidden" name="x-format" value="{$format}"/>
                <input type="hidden" name="x-context" value="{$x-context}"/>
                <input type="submit" value="suchen"/>
            </form>
            <xsl:value-of select="count(//sru:terms/sru:term)"/> out of <xsl:value-of select="$countTerms"/> Terms
            
        </div>
    </xsl:template>
    
    <!-- 
sample data:        
        <sru:term>
        <sru:value>cartesian</sru:value>
        <sru:numberOfRecords>35645</sru:numberOfRecords>
        <sru:displayTerm>Carthesian</sru:displayTerm>
        <sru:extraTermData></sru:extraTermData>
        </sru:term>
    -->
    <xsl:template match="sru:terms">
<!--        <xsl:variable name="index" select="my:xpath2index(@path)"/>-->
        <xsl:choose>
            <xsl:when test="$list-mode = 'table'">
                <table>
                    <xsl:apply-templates select="sru:term"/>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:apply-templates select="sru:term"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sru:term">
        <xsl:variable name="depth" select="count(ancestor::sru:term)"/>
        <xsl:variable name="href">
            <!--                        special handling for special index -->
            <xsl:choose>
                <xsl:when test="$index = 'fcs.resource'">
                    <xsl:value-of select="utils:formURL('explain', $format, sru:value)"/>
                </xsl:when>
                <!-- TODO: special handling for cmd.collection? -->
                <!--<xsl:when test="$index = 'cmd.collection'">
                    <xsl:value-of select="utils:formURL('explain', $format, sru:value)"/>
                </xsl:when>-->
                <xsl:otherwise>
                    <xsl:value-of select="utils:formURL('searchRetrieve', $format, concat($index, '%3D%22', sru:value, '%22'))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="link">
            <span>
                <xsl:value-of select="for $i in (1 to $depth) return '- '"/>
                <a class="value-caller" href="{$href}">  <!--target="_blank"-->
                    <xsl:value-of select="(sru:displayTerm, sru:value)[1]"/>
                </a>
            </span>
            <xsl:apply-templates select="sru:extraTermData/diagnostics"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$list-mode = 'table'">
                <tr>
                    <td align="right" valign="top">
                        <xsl:value-of select="sru:numberOfRecords"/>
                    </td>
                    <td>
                        <xsl:copy-of select="$link"/>
                    </td>
                </tr>
                <xsl:apply-templates select="sru:extraTermData/sru:terms/sru:term"/>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:copy-of select="$link"/>
                    <span class="note"> |<xsl:value-of select="sru:numberOfRecords"/>|</span>
                    <ul>
                        <xsl:apply-templates select="sru:extraTermData/sru:terms/sru:term"/>
                    </ul>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>