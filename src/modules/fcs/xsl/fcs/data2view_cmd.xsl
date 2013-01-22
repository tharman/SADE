<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cmd="http://www.clarin.eu/cmd/" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:util="http://aac.ac.at/content_repository/utils" version="2.0" exclude-result-prefixes="exist">

<!-- 
 stylesheet for custom formatting of CMD-records (inside a FCS/SRU-result).
-->
    <xsl:variable name="resourceref_limit" select="10"/>
    <xsl:template match="cmd:ResourceProxyList" mode="record-data">
        <xsl:choose>
            <xsl:when test="count(cmd:ResourceProxy) &gt; 1">
                <div class="resource-links">
                    <label>references </label>
                    <xsl:value-of select="count(cmd:ResourceProxy[cmd:ResourceType='Metadata'])"/>
                    <label> MDRecords, </label>
                    <xsl:value-of select="count(cmd:ResourceProxy[cmd:ResourceType='Resource'])"/>
                    <label> Resources</label>
                    <xsl:if test="count(cmd:ResourceProxy) &gt; $resourceref_limit">
                        <br/>
                        <label>showing first </label>
                        <xsl:value-of select="$resourceref_limit"/>
                        <label> references. </label> 
                            <!--   <s><a href="{concat($default_prefix, my:encodePID(./ancestor::CMD/Header/MdSelfLink))}">see more</a></s> -->
<!--                            <s><a href="{my:formURL('record', 'htmlpage', my:encodePID(./ancestor::cmd:CMD/cmd:Header/MdSelfLink))}">see more</a></s>-->
                    </xsl:if>
                    <ul class="detail">
                        <xsl:apply-templates select="cmd:ResourceProxy[position() &lt; $resourceref_limit]" mode="record-data"/>
                    </ul>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:apply-templates mode="record-data"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="cmd:ResourceProxy" mode="record-data">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="cmd:ResourceType='Resource'">
                    <xsl:value-of select="cmd:ResourceRef"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="util:formURL('record', 'htmlpage', util:encodePID(ResourceRef))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="class" select=" if (cmd:ResourceType='Resource') then 'external' else 'internal'"/>
        <li>
            <span class="label">
                <xsl:value-of select="cmd:ResourceType"/>: </span>
            <a class="{$class}" href="{$href}" target="_blank">
                <xsl:value-of select="cmd:ResourceRef"/>
            </a>
        </li>
    </xsl:template>
    <xsl:function name="util:encodePID">
        <xsl:param name="pid"/>
        <xsl:value-of select="encode-for-uri(replace(replace($pid,'/','%2F'),'\.','%2E'))"/>
    </xsl:function>
    <xsl:function name="util:formURL">
        <xsl:param name="action"/>
        <xsl:param name="format"/>
        <xsl:param name="q"/>
        <xsl:variable name="param_q">
            <xsl:if test="$q != ''">
                <xsl:value-of select="concat('&amp;query=',$q)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="param_repository">
            <xsl:if test="$x-context != ''">
                <xsl:value-of select="concat('&amp;repository=',$x-context)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="param_startRecord">
            <xsl:if test="$startRecord != ''">
                <xsl:value-of select="concat('&amp;startRecord=',$startRecord)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="param_maximumRecords">
            <xsl:if test="$maximumRecords != ''">
                <xsl:value-of select="concat('&amp;maximumRecords=',$maximumRecords)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$action=''">
                <xsl:value-of select="concat($base_url, '/?q=', $q, '&amp;x-context=', $x-context)"/>
            </xsl:when>
            <xsl:when test="$q=''">
                <xsl:value-of select="concat($base_url, '/',$action, '/', $format)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$action='record'">
                        <xsl:value-of select="concat($base_url, '/',$action, '/', $format, '?query=', $q, $param_repository)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($base_url, '/',$action, '/', $format, '?query=', $q, $param_repository, $param_startRecord, $param_maximumRecords)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>