<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="myFunctions" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" extension-element-prefixes="exsl xs" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> 2012-12-10</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> m</xd:p>
            <xd:p>params for amc-viewer</xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p>baseurl for the subrequests</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="baseurl" select="'http://193.170.82.207:8984/solr/select?'"/>
    <xd:doc>
        <xd:desc>
            <xd:p>if the base-data with the baseq cannot be retrieved (e.g. network-error) 
                this provides a link to the default base-data, which should be a cached version of an all-result (<code>*:*</code>) </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="default-base-data-path" select="'http://localhost:8985/solr/collection2/admin/file?file=/data-cache/stats_base.xml'"/>
    <xd:doc>
        <xd:desc>
            <xd:p>prefix for <xd:i>js</xd:i> and <xd:i>css</xd:i> scripts used in html-header</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="scripts-dir" select="'/solr/collection1/admin/file?file=/scripts/'"/>
    <xd:doc>
        <xd:desc>
            <xd:p>flag to invoke reldata even if no baseq-param was found</xd:p>
            <xd:p>tries to read from the result-header</xd:p>
            <xd:p>0|1</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="reldata" select="my:params('reldata',0)"/>
    <xd:doc>
        <xd:desc>
            <xd:p>multi-flag to indicate which parts of the view shall be rendered </xd:p>
            <xd:p>(default: all)</xd:p>
            <xd:p>recognized values: chart,table</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="parts" select="my:params('parts','chart, table')"/>
    <xd:doc>
        <xd:desc>
            <xd:p>optional string-list to restrict metrics processed from the <xd:a href="http://wiki.apache.org/solr/StatsComponent">stats-component</xd:a>
            </xd:p>
            <xd:p>allowed values:  min, max, sum, count, missing, sumOfSquares, mean, stddev </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="statsx_metrics" select="my:params('statsx.metrics',0)"/>
    <xd:doc>
        <xd:desc>
            <xd:p>a multiple of 10 to multiply the relative frequency, i.e. the quotient of absolute frequency of the query and the base-query, which is usually quite a small number</xd:p>
            <xd:p>million seems a good default</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="percentile-base" select="1000000"/>
    <xd:doc>
        <xd:desc>
            <xd:p>a multiple of 10 to round the relative frequency numbers</xd:p>
            <xd:p>100 yields two decimal places</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="decimal-base" select="100"/>
    <xd:doc>
        <xd:desc>
            <xd:p>a verbose description of the percentile-base, (to be displayed in the output, to explain the numbers)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="percentile-unit" select="'ppm articles'"/> <!-- ppm, % -->
</xsl:stylesheet>