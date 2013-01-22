<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" version="1.0" exclude-result-prefixes="xs sru fcs">

<!-- 
<purpose>pieces of html wrapped in templates, to be reused by other stylesheets</purpose>
<history>
	<change on="2011-12-05" type="created" by="vr">copied from  cr/html_snippets reworked back to xslt 1.0</change>
</history>

-->
    <xsl:import href="params.xsl"/>
    <xsl:template name="html-head">
        <title>
            <xsl:value-of select="$title"/>
        </title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <link href="{$scripts_url}/style/jquery/clarindotblue/jquery-ui-1.8.5.custom.css" type="text/css" rel="stylesheet"/>
        <link href="{$scripts_url}/style/cmds-ui.css" type="text/css" rel="stylesheet"/>
        <link href="{$scripts_url}/style/cr.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" src="{$scripts_url}/js/jquery-1.6.2.js"/>
        <!--        <xsl:if test="contains($format,'htmljspage')">
            <link href="{$base_dir}/style/jquery/jquery-treeview/jquery.treeview.css" rel="stylesheet"/>        
            </xsl:if>-->
    </xsl:template>
    <xsl:template name="page-header">
        <div class="cmds-ui-block" id="titlelogin">
            <div id="logo">
                <a href="{$base_url}">
                    <img src="{$site_logo}" alt="{$site_name}"/>
                </a>
                <div id="site-name">
                    <xsl:value-of select="$site_name"/>
                </div>
            </div>
            <div id="top-menu">
                <div id="user">
                    <xsl:variable name="link_toggle_js">
                        <xsl:call-template name="formURL">
                            <xsl:with-param name="format">
                                <xsl:choose>
                                    <xsl:when test="contains($format,'htmljspage')">htmlpage</xsl:when>
                                    <xsl:otherwise>htmljspage</xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="contains($format,'htmljspage')">
                            <a href="{$link_toggle_js}"> none js </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="{$link_toggle_js}"> js </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$user = ''">
                            <a href="workspace.jsp">    login</a>
                        </xsl:when>
                        <xsl:otherwise>
							User: <b>
                                <xsl:value-of select="$user"/>
                            </b>
                            <a href="logout.jsp">    logout</a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <a target="_blank" href="static/info"> docs</a>
                </div>
                <div id="notify" class="cmds-elem-plus note">
                    <div id="notifylist" class="note"/>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="query-input">
    
	<!-- QUERYSEARCH - BLOCK -->
        <div class="cmds-ui-block init-show" id="querysearch">
            <div class="header ui-widget-header ui-state-default ui-corner-top">
                Search
            </div>
            <div class="content" id="query-input">
                <!-- fill form@action with <xsl:call-template name="formURL"/> will not work, 
                        because the parameter have to be encoded as input-elements  not in the form-url  
                    -->
                <form id="searchretrieve" action="{$base_url}" method="get">
                    <input type="hidden" name="x-format" value="{$format}"/>
                    <table class="cmds-ui-elem-stretch">
                        <tr>
                            <td colspan="2">
                                <label>Context</label>
                                <xsl:call-template name="contexts-select"/>
                                <input type="text" id="input-simplequery" name="query" value="{$q}" class="queryinput active"/>
                                <div id="searchclauselist" class="queryinput inactive"/>
                            </td>
                            <td>
                                <input type="submit" value="submit" id="submit-query"/>
                                <br/>
                                <span id="switch-input" class="cmd"/>
                                <label>Complex query</label>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">                                    
                                        
							<!--  selected collections  -->
							<!-- <label>Collections</label><br/>-->
                                <div id="collections-widget" class="c-widget"/>
                            </td>
                            <td valign="top">
                                <xsl:call-template name="result-paging"/>
                            </td>
                            <td/>
                        </tr>
                    </table>
                </form>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="result-paging">
        <span class="label">from:</span>
        <span>
            <input type="text" name="startRecord" class="value start_record paging-input">
                <xsl:attribute name="value">
                    <xsl:value-of select="$startRecord"/>
                </xsl:attribute>
            </input>
        </span>
        <span class="label">max:</span>
        <span>
            <input type="text" name="maximumRecords" class="value maximum_records paging-input">
                <xsl:attribute name="value">
                    <xsl:choose>
                        <xsl:when test="number($numberOfRecords) &gt; 0 and number($numberOfRecords) &lt; number($maximumRecords)">
                            <xsl:value-of select="$numberOfRecords"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$maximumRecords"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </input>
        </span>
        <input type="submit" value="" class="cmd cmd_reload"/>
    </xsl:template>
    <xsl:template name="prev-next">
        <xsl:variable name="prev_startRecord">
            <xsl:choose>
                <xsl:when test="number($startRecord) - number($maximumRecords) &gt; 0">
                    <xsl:value-of select="format-number(number($startRecord) - number($maximumRecords),'#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="next_startRecord">
            <xsl:choose>
                <xsl:when test="number($startRecord) + number($maximumRecords) &gt; number(numberOfRecords)">
                    <xsl:value-of select="$startRecord"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(number($startRecord) + number($maximumRecords),'#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="link_prev">
            <xsl:call-template name="formURL">
                <xsl:with-param name="startRecord" select="$prev_startRecord"/>
                <xsl:with-param name="maximumRecords" select="$maximumRecords"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="prev-disabled">
            <xsl:if test="$startRecord = '1'">disabled</xsl:if>
        </xsl:variable>
        <xsl:variable name="link_next">
            <xsl:call-template name="formURL">
                <xsl:with-param name="startRecord" select="$next_startRecord"/>
                <xsl:with-param name="maximumRecords" select="$maximumRecords"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="next-disabled">
            <xsl:if test="number($startRecord) + number($maximumRecords) &gt;= number(numberOfRecords)">disabled</xsl:if>
        </xsl:variable>
        <span class="result-navigation prev-next">
            <a class="internal prev {$prev-disabled}" href="{$link_prev}">
                <span class="cmd cmd_prev"/>
            </a>
            <a class="internal next {$next-disabled}" href="{$link_next}">
                <span class="cmd cmd_next"/>
            </a>
        </span>
    </xsl:template>
    <xsl:template name="query-list">
<!-- QUERYLIST BLOCK -->
        <div id="querylistblock" class="cmds-ui-block">
            <div class="header ui-widget-header ui-state-default ui-corner-top">
                <span>QUERYLIST</span>
            </div>
            <div class="content" id="querylist"/>
        </div>
    </xsl:template>
    <xsl:template name="detail-space">
        <div id="detailblock" class="cmds-ui-block">
            <div class="header ui-widget-header ui-state-default ui-corner-top">
                <span>DETAIL</span>
            </div>
            <div class="content" id="details"/>
        </div>
    </xsl:template>
    <xsl:template name="public-space">
        <div id="public-space" class="cmds-ui-block">
            <div class="header">
                <span>Public Space</span>
            </div>
            <div id="serverqs" class="content"/>
        </div>
    </xsl:template>
    <xsl:template name="user-space">
        <div class="cmds-ui-block init-show" id="user-space">
            <div class="header">
                <span>Personal Workspace</span>
            </div>
            <div id="userqs" class="content">
                <div id="userquerysets">
                    <label>Querysets</label>
                    <select id="qts_select"/>
				<!--  <button id="qts_add" class="cmd cmd_add" >Add</button> -->
                    <span id="qts_add" class="cmd cmd_add"/>
                    <span id="qts_delete" class="cmd cmd_del"/>
                </div>
                <label>name</label>
                <input type="text" id="qts_input"/>
                <span id="qts_save" class="cmd cmd_save"/>
                <div id="userqueries"/>
            </div>
            <div id="userbs" class="content">
                <div id="bookmarksets">
                    <label>Bookmarksets</label>
                    <select id="bts_select"/>
                    <span id="bts_add" class="cmd cmd_add"/>
                    <span id="bts_delete" class="cmd cmd_del"/>
                    <span id="bts_publish" class="cmd cmd_publish"/>
                </div>
                <label>name</label>
                <input type="text" id="bts_input"/>
                <span id="bts_save" class="cmd cmd_save"/>
                <div id="bookmarks"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>