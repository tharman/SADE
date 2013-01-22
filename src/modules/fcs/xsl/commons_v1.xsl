<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:fcs="http://clarin.eu/fcs/1.0" version="1.0">

<!-- 
<purpose>generic functions for SRU-result handling</purpose>
<history>
	<change on="2011-12-04" type="created" by="vr">based on cmd_functions.xsl but retrofitted back to 1.0</change>
</history>

-->
<!--    <xsl:include href="params.xsl"/>-->
    <xsl:include href="html_snippets.xsl"/>

<!-- <xsl:param name="mode" select="'html'" /> -->
    <xsl:param name="dict_file" select="'dict.xml'"/>
    <xsl:variable name="dict">
        <dict/>
    </xsl:variable>
    <xsl:variable name="contexts">
        <xsl:call-template name="contexts-doc"/>
    </xsl:variable>
   
	<!-- common starting point for all stylesheet; cares for unified html-envelope
		and passes back to the individual stylesheets for the content (via template: continue-root) -->
    <xsl:template match="/">
		<!--<xsl:message>root_document-uri:<xsl:value-of select="$root_uri"/>
			</xsl:message>
			<xsl:message>format:<xsl:value-of select="$format"/>
			</xsl:message>-->
        <xsl:choose>
            <xsl:when test="contains($format,'htmlpage')">
                <xsl:call-template name="html"/>
            </xsl:when>
            <xsl:when test="contains($format,'htmljspage')">
                <xsl:call-template name="htmljs"/>
            </xsl:when>
            <xsl:when test="contains($format,'htmlsimple')">
                <xsl:call-template name="htmlsimple"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="continue-root"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="html">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html-head"/>
                <xsl:call-template name="callback-header"/>
            </head>
            <body>
                <xsl:call-template name="page-header"/>
                <h1>
                    <xsl:value-of select="$title"/>
                </h1>
                <xsl:call-template name="continue-root"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="htmljs">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html-head"/>
                <xsl:call-template name="callback-header"/>
            </head>
            <body>
                <xsl:call-template name="page-header"/>
                <h1>
                    <xsl:value-of select="$title"/>
                </h1>
                <xsl:call-template name="query-input"/>
                <xsl:call-template name="query-list"/>
                <xsl:call-template name="detail-space"/>
                <xsl:call-template name="public-space"/>
                <xsl:call-template name="user-space"/>
				<!--  <xsl:call-template name="continue-root"/>-->
            </body>
        </html>
    </xsl:template>
	
	<!-- a html-envelope for a simple (noscript) view -->
    <xsl:template name="htmlsimple">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:value-of select="$title"/>
                </title>
                <link href="{$scripts_url}/style/cmds-ui.css" type="text/css" rel="stylesheet"/>				
				<!-- <xsl:call-template name="callback-header"/> -->
            </head>
            <xsl:call-template name="page-header"/>
            <body>                
				<!-- <h1><xsl:value-of select="$title"/></h1> -->
                <xsl:call-template name="continue-root"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="callback-header"/>
    <xsl:template match="diagnostics">
        <div class="error">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="diag:diagnostic">
        <p>
            <xsl:value-of select="diag:message"/>
            <xsl:if test="diag:details"> (<xsl:value-of select="diag:details"/>)</xsl:if>
            <br/>
            <xsl:value-of select="diag:uri"/>
        </p>
    </xsl:template>
    <xsl:template name="contexts-doc">
        <xsl:copy-of select="document($contexts_url)"/>
    </xsl:template>
        
    <!-- generates a select-option list of available contexts  
    -->
    <xsl:template name="contexts-select">
        
<!--            DEBUG: contexts_url:<xsl:copy-of select="$contexts_url" />-->
        <select name="x-context">
            <xsl:if test="$contexts">
                <xsl:for-each select="$contexts//sru:terms/sru:term">
                    <xsl:variable name="ancestors-prefix">
                        <xsl:for-each select="ancestor::sru:term">
                            <xsl:text>.</xsl:text>
                        </xsl:for-each>
                    </xsl:variable>
                    <option value="{sru:value}">
                        <xsl:if test="sru:value/text() = $x-context">
                            <xsl:attribute name="selected">selected</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="concat($ancestors-prefix, sru:displayTerm)"/>
                    </option>
                </xsl:for-each>
            </xsl:if>
        </select>
    </xsl:template>
    
    	
	<!-- shall be usable to form consistently all urls within xsl 
	-->
    <xsl:template name="formURL">
        <xsl:param name="action" select="'searchRetrieve'"/>
        <xsl:param name="format" select="$format"/>
        <xsl:param name="q" select="$q"/>
        <xsl:param name="startRecord" select="$startRecord"/>
        <xsl:param name="maximumRecords" select="$maximumRecords"/>
        <xsl:variable name="param_q">
            <xsl:if test="$q != ''">
                <xsl:value-of select="concat('&amp;query=',$q)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="param_format">
            <xsl:if test="$format != ''">
                <xsl:value-of select="concat('&amp;x-format=',$format)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="param_x-context">
<!--            if action=explain, handle-q param as x-context-->
            <xsl:choose>
                <xsl:when test="$action='explain'">
                    <xsl:value-of select="concat('&amp;x-context=',$q)"/>
                </xsl:when>
                <xsl:when test="$x-context != '' ">
                    <xsl:value-of select="concat('&amp;x-context=',$x-context)"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
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
            <xsl:when test="$action='explain'">
                <xsl:value-of select="concat($base_url, '?operation=',$action, $param_x-context, $param_format)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($base_url, '?operation=',$action, $param_q, $param_x-context, $param_startRecord, $param_maximumRecords, $param_format)"/>
            </xsl:otherwise>
        </xsl:choose>                
         
        <!--        <xsl:choose>
            <xsl:when test="$action=''">
                <xsl:value-of select="concat($base_dir, '?q=', $q, '&repository=', $repository)"/>
            </xsl:when>
            <xsl:when test="$q=''">
                <xsl:value-of select="concat($base_dir, '/',$action, '/', $format)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$action='record'">
                        <xsl:value-of select="concat($base_dir, '/',$action, '/', $format, '?query=', $q, $param_repository)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($base_dir, '?operation=',$action, $param_q, $param_repository, $param_startRecord, $param_maximumRecords, $param_format)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
-->
    </xsl:template>
    
    <!-- add link to more information to a link using information from mappings  and some attribute (@key)-->
    <xsl:template name="elem-link">
        <xsl:param name="elem" select="."/>
        
        <!-- WATCHME: primitive matching on elem-name, let's see how far this gets us -->
        <xsl:variable name="index" select="$context-mapping//index[path = name($elem)][@link]"/>
        <xsl:if test="$index">
            <!-- we would need a dynamic evaluation to get the specific piece of data from the $elem 
                but let's try with some more trivial means -->
            <xsl:variable name="linking-value">
                <xsl:choose>
                    <xsl:when test="contains($index/@use,'@')">
                        <xsl:value-of select="$elem/@*[name()= substring-after($index/@use,'@')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$elem/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="concat($index/@link, $linking-value)"/>
        </xsl:if>
    </xsl:template>
    <xsl:template name="format-field">
        <xsl:param name="elems"/>
        <xsl:choose>
            <xsl:when test="$elems/*">
                <xsl:apply-templates select="$elems" mode="format-xmlelem"/>
            </xsl:when>
            <xsl:when test="count($elems) &gt; 1">
                <ul>
                    <xsl:for-each select="$elems">
                        <li>
                            <xsl:call-template name="format-value"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="format-value">
                    <xsl:with-param name="value" select="$elems"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="format-value">
        <xsl:param name="value" select="."/>
		<!-- cnt_value:<xsl:value-of select="count($value)" />  -->
        <xsl:choose>
            <xsl:when test="starts-with($value[1], 'http:') ">
                <a target="_blank" class="external" href="{$value}">
                    <xsl:value-of select="$value"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	<!--generic html-view for xml-elements 
	
	@param strict xs:boolean stay in format-xmlelem mode (or try to go back to mode=record-data)
	-->
    <xsl:template match="*" mode="format-xmlelem">
        <xsl:param name="strict"/>
<!--        <xsl:message>strict:<xsl:value-of select="$strict"/></xsl:message>        -->
        <xsl:if test=".//text() or @*">
            <xsl:variable name="has_text">
                <xsl:choose>
                    <xsl:when test="normalize-space(text()[1])='Unspecified'">unspecified</xsl:when>
                    <xsl:when test="not(normalize-space(.//text())='')">text</xsl:when>
                    <xsl:otherwise>empty</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="has_children">
                <xsl:choose>
                    <xsl:when test="*">has-children</xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="label-class">
                <xsl:choose>
                    <xsl:when test="*">block label</xsl:when>
                    <xsl:otherwise>inline label</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <div class="cmds-xmlelem {$has_children} value-{$has_text}">
                <span class="{$label-class}">
                    <xsl:value-of select="name()"/>:</span>
                <span class="value">
                    <xsl:call-template name="format-value">
                        <xsl:with-param name="value" select="text()[.!='']"/>
                    </xsl:call-template>
                </span>
                <xsl:if test="@*">
                    <div class="attributes">
                        <xsl:apply-templates select="@*" mode="format-attr"/>
                    </div>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$strict">
                        <xsl:apply-templates select="*" mode="format-xmlelem">
                            <xsl:with-param name="strict" select="$strict"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*" mode="record-data"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@*" mode="format-attr">
        <span class="inline label">@<xsl:value-of select="name()"/>: </span>
        <span class="value">
            <xsl:call-template name="format-value"/><!--<xsl:value-of select="." /> -->
        </span>
    </xsl:template>
	
	<!--  previously known as comppath -->
    <xsl:template name="xml-context">
        <xsl:param name="child"/>
        <xsl:variable name="collect">
            <xsl:for-each select="$child/ancestor::CMD_Component|$child/ancestor::Term">
                <xsl:value-of select="@name"/>.</xsl:for-each>
            <xsl:value-of select="$child/@name"/>
        </xsl:variable>
        <xsl:value-of select="$collect"/>
    </xsl:template>
    <xsl:template name="dict">
        <xsl:param name="key"/>
        <xsl:param name="fallback" select="$key"/>
        <xsl:choose>
            <xsl:when test="$dict/list/item[@key=$key]">
                <xsl:value-of select="$dict/list/item[@key=$key]"/>
            </xsl:when>
            <xsl:when test="$dict/list/item[.=$key]">
                <xsl:value-of select="$dict/list/item[.=$key]/@key"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$fallback"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>