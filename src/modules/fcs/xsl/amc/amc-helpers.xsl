<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="myFunctions" xmlns:exsl="http://exslt.org/common" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" extension-element-prefixes="exsl xs" version="2.0">
    <xsl:import href="amc-params.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> 2012-09-28</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> m</xd:p>
            <xd:p>some helper functions for processing the solr-result (amc-viewer)</xd:p>
            <xd:p>params moved to amc-params.xsl [2012-12-10]</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:decimal-format decimal-separator="," grouping-separator="."/>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="number-format-dec">#.##0,##</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="number-format-default">#.###</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="number-format-plain">0,##</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>the base-link parameters encoded as url</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="base-link">
        <xsl:call-template name="base-link"/>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>store in a variable the params list as delivered by solr in the header of a response</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="params" select="//lst[@name='params']"/>
    <xd:doc>
        <xd:desc>
            <xd:p>access function to the params-list </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="my:params">
        <xsl:param name="param-name"/>
        <xsl:param name="default-value"/>
        <xsl:value-of select="if(exists($params/*[@name=$param-name])) then $params/*[@name=$param-name] else $default-value "/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>convenience format-number function, 
                if empty -&gt; 0, else if not a number return the string</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="my:format-number">
        <xsl:param name="number"/>
        <xsl:param name="pattern"/>
        <xsl:value-of select="             if (xs:string($number)='' or number($number) =0) then 0 else             if(number($number)=number($number)) then format-number($number,$pattern)              else $number"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>does the sub-calls </xd:p>
            <xd:p>uses XSLT-2.0 function: <xd:ref name="doc-available()" type="function"/>
            </xd:p>
        </xd:desc>
        <xd:param name="q">the query string; default is the query of the original result </xd:param>
        <xd:param name="link">url to retrieve; overrides the q-param</xd:param>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
        <xd:param name="q"/>
        <xd:param name="link"/>
    </xd:doc>
    <xsl:template name="subrequest">
        <xsl:param name="q" select="//*[contains(@name,'q')]"/>
        <xsl:param name="link" select="concat($baseurl, $base-link, 'q=', $q)"/>
        <xsl:message>DEBUG: subrequest: <xsl:value-of select="$link"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="doc-available($link)">
                <xsl:copy-of select="doc($link)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>WARNING: subrequest failed! <xsl:value-of select="$link"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>generates a link out of the param-list, but leaves out special parameters (q, qx, baseq, wt)</xd:p>
            <xd:p>used as base for subrequests</xd:p>
        </xd:desc>
        <xd:param name="params"/>
    </xd:doc>
    <xsl:template name="base-link">
        <xsl:param name="params" select="//lst[@name='params']"/>
        <xsl:apply-templates select="$params/*[not(@name='q')][not(@name='qx')][not(@name='baseq')][not(@name='wt')]" mode="link"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>(re)generates a link out of the param-list in the result</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="link">
        <xsl:variable name="link">
            <xsl:text>?</xsl:text>
            <xsl:apply-templates select="//lst[@name='params']" mode="link"/>
        </xsl:variable>
        <a href="{$link}">
            <xsl:value-of select="$link"/>
        </a>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/str" mode="link">
        <xsl:value-of select="concat(@name,'=',.,'&amp;')"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/arr" mode="link">
        <xsl:apply-templates mode="link"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/arr/str" mode="link">
        <xsl:value-of select="concat(../@name,'=',.,'&amp;')"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>in link-mode discard any text-nodes not handled explicitely</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()" mode="link"/>
    <xd:doc>
        <xd:desc>
            <xd:p>generate a tabled form out of the params</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="query-input" match="lst[@name='params']" mode="query-input">
        <form>
            <table border="0">
                <xsl:apply-templates mode="form"/>
            </table>
            <input type="submit" value="search"/>
            <xsl:call-template name="link"/>
        </form>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/str" mode="form">
        <tr>
            <td border="0">
                <xsl:value-of select="@name"/>:</td>
            <td>
                <input type="text" name="{@name}" value="{.}"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/arr" mode="form">
        <tr>
            <td border="0">
                <xsl:value-of select="@name"/>:</td>
            <td>
                <xsl:apply-templates mode="form"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lst[@name='params']/arr/str" mode="form">
        <input type="text" name="{../@name}" value="{.}"/>
        <br/>
    </xsl:template>
    <xsl:template match="text()" mode="query-input"/>
    <xsl:template match="text()" mode="form"/>
    <xd:doc>
        <xd:desc>
            <xd:p>flatten array to node-sequence</xd:p>
            <xd:p>solr delivers parameters differently depending on 
                if they are one (&lt;str name="param"&gt;value&lt;/str&gt;)
                or many (&lt;arr name="param"&gt;&lt;str&gt;value1&lt;/str&gt;&lt;str&gt;value2&lt;/str&gt;&lt;/arr&gt;)
            </xd:p>
            <xd:p>this is to generate a flat node-sequence out of both structures, 
                so that it can be traversed in the same way
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="arrayize">
        <xsl:choose>
            <xsl:when test="name(.)='arr'">
                <xsl:copy-of select="*"/>
            </xsl:when>
            <xsl:otherwise>
<!--                <xsl:copy-of select="exsl:node-set(.)" />-->
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>inverts the dataset, i.e. labels will get dataseries and vice versa</xd:p>
            <xd:p>needed mainly for AreaChart display.</xd:p>
        </xd:desc>
        <xd:param name="dataset"/>
    </xd:doc>
    <xsl:template match="dataset" mode="invert-old">
        <xsl:param name="dataset" select="."/>
        <dataset name="{@name}">
            <labels>
                <xsl:for-each select="dataseries">
                    <label>
                        <xsl:if test="@type">
                            <xsl:attribute name="type" select="@type"/>
                        </xsl:if>
                        <xsl:value-of select="@name"/>
                    </label>
                </xsl:for-each>
            </labels>
            <xsl:for-each select="labels/label">
                <xsl:variable name="curr_label_old" select="text()"/>
                <dataseries name="{$curr_label_old}">
                    <xsl:for-each select="$dataset//value[@label=$curr_label_old]">
                        <value label="{../@name}" formatted="{@formatted}">
                            <xsl:if test="../@type">
                                <xsl:attribute name="type" select="../@type"/>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </value>
                    </xsl:for-each>
                </dataseries>
            </xsl:for-each>
        </dataset>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>inverts the dataset, i.e. labels will get dataseries and vice versa</xd:p>
            <xd:p>needed mainly for AreaChart display.</xd:p>
            <xd:p>tries to cater for inconsistent structure (@key, @name, @label ...)
            once all data is harmonized (according to dataset.xsd), we can get rid of it</xd:p>
        </xd:desc>
        <xd:param name="dataset"/>
    </xd:doc>
    <!-- -->
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