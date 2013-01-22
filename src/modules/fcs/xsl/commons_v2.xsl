<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:utils="http://aac.ac.at/content_repository/utils" version="2.0">
    
    <!-- 
        <purpose>generic functions for SRU-result handling</purpose>
        <history>
        <change on="2012-02-04" type="created" by="vr">convenience wrapper to commons_v1.xsl in XSLT 2.0</change>
        <change on="2011-12-04" type="created" by="vr">based on cmd_functions.xsl but retrofitted back to 1.0</change>
        </history>        
    -->
    <xsl:import href="commons_v1.xsl"/>
    <xsl:template name="contexts-doc">
        <xsl:copy-of select="if (doc-available($contexts_url)) then doc($contexts_url) else ()"/>
    </xsl:template>
 
    <!--
        convenience-wrapper to formURL-template
        shall be usable to form consistently all urls within xsl 
    -->
    <xsl:function name="utils:formURL">
        <xsl:param name="action"/>
        <xsl:param name="format"/>
        <xsl:param name="q"/>
        <xsl:call-template name="formURL">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="format" select="$format"/>
            <xsl:with-param name="q" select="$q"/>
            <!-- CHECK: possibly necessary   <xsl:with-param name="repository" select="$repository" /> -->
        </xsl:call-template>
    </xsl:function>        
  
   <!--
    convenience wrapper function to xml-context-template;
    delivers the ancestor path
    -->
    <xsl:function name="utils:xmlContext">
        <xsl:param name="child"/>
        <xsl:call-template name="xml-context">
            <xsl:with-param name="child" select="$child"/>
        </xsl:call-template>
    </xsl:function>
  
<!--
   convenience wrapper function to dict-template;
-->
    <xsl:function name="utils:dict">
        <xsl:param name="key"/>
        <xsl:value-of select="utils:dict($key, $key)"/>
    </xsl:function>
    <xsl:function name="utils:dict">
        <xsl:param name="key"/>
        <xsl:param name="fallback"/>
        <xsl:call-template name="dict">
            <xsl:with-param name="key" select="$key"/>
            <xsl:with-param name="fallback" select="$fallback"/>
        </xsl:call-template>
    </xsl:function>
</xsl:stylesheet>