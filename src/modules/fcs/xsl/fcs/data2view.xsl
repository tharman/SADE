<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:kwic="http://clarin.eu/fcs/1.0/kwic" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" version="2.0" exclude-result-prefixes="xs sru exist tei fcs">

    <!-- 
        <purpose> provide more specific handling of sru-result-set recordData</purpose>
        <params>
        <param name=""></param>
        </params>
        <history>	
        <change on="2011-11-14" type="created" by="vr">based on cmdi/scripts/xml2view.xsl</change>	
        </history>
    -->
<!--    <xsl:include href="data2view_cmd.xsl"/>-->
    <xsl:import href="../amc/dataset2view.xsl"/>
    <xsl:include href="data2view_tei.xsl"/>
<!--    <xsl:include href="../stand_weiss.xsl"/>-->
   
   
<!-- default starting-point -->
    <xsl:template match="sru:recordData" mode="record-data">
        <xsl:apply-templates select="*" mode="record-data"/>
    </xsl:template>
    
<!-- default fallback: display the xml-structure-->
    <xsl:template match="*" mode="record-data">
        <xsl:variable name="overrides">
            <xsl:apply-imports/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$overrides">
                <xsl:copy-of select="$overrides"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="format-xmlelem"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

 <!-- hide meta-information about the record from output-->
    <xsl:template match="sru:recordSchema|sru:recordPacking" mode="record-data"/>
    <xsl:template match="sru:recordIdentifier | sru:recordPosition" mode="record-data"/>
    
<!-- kwic match -->
    <xsl:template match="exist:match" mode="record-data">
        <span class="hilight match">
  <!--            <xsl:apply-templates select="*" mode="record-data"/>-->
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    

<!-- FCS-wrap -->
    <xsl:template match="fcs:Resource" mode="record-data">
        
        <!-- this is quite specialized only for the navigation-ResourceFragments! -->
        <div class="navigation">
            <xsl:apply-templates select=".//fcs:ResourceFragment[@type][not(fcs:DataView)]" mode="record-data"/>
        </div>
        
        <!-- currently reduced to processing only DataView-kwic 
        but we should make this generic (don't restrict by type, just continue processing the record-data) -->
        <xsl:apply-templates select=".//fcs:DataView" mode="record-data"/>
    </xsl:template>
    <xsl:template match="fcs:DataView" mode="record-data">
           <!-- don't show full view if, there is kwic, title-view is called separately, and  -->
        <xsl:if test="not((@type='full' and parent::*/fcs:DataView[@type='kwic']) or @type='title')">
            <div class="data-view {@type}">
                <xsl:apply-templates mode="record-data"/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="fcs:DataView[@ref][not(@ref='')]" mode="record-data">
        <div class="data-view {@type}">
            <a href="{@ref}">
                <xsl:value-of select="@type"/>
            </a>
        </div>
    </xsl:template>
    
 <!-- better hide the fullview (the default view is too much)
        TODO: some more condensed view -->
<!--    <xsl:template match="fcs:DataView[@type='full']" mode="record-data"/>-->
<!--  this would be to use, if including a stylesheet without mode=record-data (like aac:stand.xsl)       
    <xsl:template match="fcs:DataView[@type='full']/*" mode="record-data">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
-->
    <xsl:template match="fcs:ResourceFragment[@type]" mode="record-data">
        <a href="{@ref}&amp;x-format={$format}" rel="{@type}" class="{@type}">
            <xsl:value-of select="@pid"/>
        </a>
    </xsl:template>
    

 <!-- handle generic metadata-fields -->
    <xsl:template match="fcs:f" mode="record-data">
        <span class="label">
            <xsl:value-of select="@key"/>: </span>
        <span class="value">
            <xsl:value-of select="."/>
        </span>; 
    </xsl:template>
    <xsl:template match="kwic:kwic" mode="record-data">
        <div class="kwic-line">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>        
    
 <!--
     handle KWIC-DataView:
     <c type="left"></c><kw></kw><c type="right"></c>
     WATCHME: temporarily accepting both version (fcs and kwic namespacEe)
 -->
    <xsl:template match="kwic:c|fcs:c" mode="record-data">
        <span class="context {@type}">
            <xsl:apply-templates mode="record-data"/>
        </span>
        <xsl:if test="following-sibling::*[1][local-name()='c']">
            <br/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="kwic:kw|fcs:kw" mode="record-data">
        <xsl:text> </xsl:text>
        <span class="kw hilight">
            <xsl:apply-templates mode="record-data"/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    
    <!-- ************************ -->
    <!-- named templates starting -->
    <xsl:template name="getTitle">
        <xsl:choose>
            <xsl:when test=".//fcs:DataView[@type='title']">
                <xsl:value-of select=".//fcs:DataView[@type='title']"/>
            </xsl:when>
            <xsl:when test=".//date/@value">
                <xsl:value-of select=".//date/@value"/>
            </xsl:when>
            <xsl:when test=".//tei:persName">
                <xsl:value-of select=".//tei:persName"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="inline">
        <xsl:variable name="elem-link">
            <xsl:call-template name="elem-link"/>
        </xsl:variable>
        <xsl:variable name="inline-content">
            <!--<xsl:choose>
                <xsl:when test="*">
                    <xsl:for-each select="*" >
                    <xsl:apply-templates select="*" mode="record-data"></xsl:apply-templates>
                     </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>-->                    
                    <!--            <xsl:value-of select="."/>-->            
                    <!-- umständliche lösung to get spaces between children elements -->
            <xsl:for-each select=".//text()">
                        <!--<xsl:value-of select="."/>
                            <xsl:text> </xsl:text>-->
                <xsl:choose>
                    <xsl:when test="parent::exist:match">
                                <!--                        <xsl:value-of select="name(.)"/>-->
                        <xsl:apply-templates select="parent::exist:match" mode="record-data"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>        
            <!--    </xsl:otherwise>
            </xsl:choose>-->
        </xsl:variable>
        <xsl:variable name="class">
            <xsl:for-each select="descendant-or-self::*">
                <xsl:value-of select="name()"/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="inline-elem">
            <xsl:choose>
                <xsl:when test="not($elem-link='')">
                    <a href="{$elem-link}">
                        <span class="{$class}">
                            <xsl:copy-of select="$inline-content"/>
                        </span>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span class="{$class}">
                        <xsl:copy-of select="$inline-content"/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="inline-wrap">
            <xsl:if test="descendant-or-self::*/@*">
                <div class="attributes" style="display:none;">
                    <table>
                        <xsl:for-each-group select="descendant-or-self::*" group-by="name()">
                            <tr>
                                <td colspan="2">
                                    <xsl:value-of select="name()"/>
                                </td>
                            </tr>
                    
<!--                        <xsl:apply-templates select="@*" mode="format-attr"/>-->
                            <tr>
                                <td>
                                    <xsl:for-each select="current-group()">
                                        <table style="float:left">
                                            <xsl:for-each select="@*">
                                                <tr>
                                                    <td class="label">
                                                        <xsl:value-of select="name()"/>
                                                    </td>
                                                    <td class="value">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </table>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </xsl:for-each-group>
                    </table>
                </div>
            </xsl:if>
            <xsl:copy-of select="$inline-elem"/>
        </span>
    </xsl:template>
</xsl:stylesheet>