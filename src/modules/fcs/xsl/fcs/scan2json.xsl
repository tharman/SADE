<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" exclude-result-prefixes="#all" version="2.0">
    <!-- 
<purpose> generate a json object of the scanResponse </purpose>
<params>
<param name=""></param>
</params>
<result>
     {index:"$scanClause", count:"$countTerms",
      terms: [{label:"label1", value:"value1", count:"#number"}, ...]            
     }
</result>
<history>
<change on="2012-05-02" type="created" by="vr">based on scan2view.xsl </change>
<change on="2013-01-20" type="created" by="vr">based on scan2map.xsl </change>
		
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
    <xsl:output indent="yes" method="text" media-type="application/json" encoding="UTF-8"/>
    <xsl:param name="sort">x</xsl:param>
    <!-- s=size|n=name|t=time|x=default -->
    <xsl:param name="title" select="concat('scan: ', $scanClause )"/>
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>
    <xsl:param name="scanClause" select="/sru:scanResponse/sru:echoedScanRequest/sru:scanClause"/>
    <xsl:param name="index" select="$scanClause"/>
    <xsl:template match="/">
        <xsl:variable name="countTerms" select="/sru:scanResponse/sru:extraResponseData/fcs:countTerms"/>
        <xsl:variable name="countReturned" select="count(/sru:scanResponse//sru:term)"/>
        <xsl:text>{"index":"</xsl:text>
        <xsl:value-of select="$scanClause"/>
        <xsl:text>", "indexSize":"</xsl:text>
        <xsl:value-of select="$countTerms"/>
        <xsl:text>", "countReturned":"</xsl:text>
        <xsl:value-of select="$countReturned"/>
        <xsl:text>", </xsl:text>
        <xsl:apply-templates select="/sru:scanResponse/sru:terms"/>
        <xsl:text>}</xsl:text>
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
        <xsl:text>
"terms": [
</xsl:text>
        <xsl:apply-templates select="sru:term"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="sru:term">
        <xsl:text>{"value": "</xsl:text>
        <xsl:value-of select="translate(sru:value,'&#34;','')"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"label": "</xsl:text>
        <xsl:value-of select="translate((sru:displayTerm, sru:value)[1],'&#34;','')"/> |<xsl:value-of select="sru:numberOfRecords"/>
        <xsl:text>|", </xsl:text>
        <xsl:text>"count": "</xsl:text>
        <xsl:value-of select="sru:numberOfRecords"/>
        <xsl:text>"}</xsl:text>
        <xsl:if test="not(position()=last())">, </xsl:if>
        <xsl:apply-templates select="sru:extraTermData/sru:terms/sru:term"/>
    </xsl:template>
</xsl:stylesheet>