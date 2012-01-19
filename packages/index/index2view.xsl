<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my="myFunctions" version="1.0">
<!-- 
<purpose> convert xml to html-list-snippet</purpose>
<params>
<param name=""></param>
</params>
<history>
	<change on="2011-12-31" type="created" by="vr">based on collection2view.xsl</change>		
</history>
<sample> result
	<ul id="browser" class="filetree treeview">
		<li><span class="folder">Folder 1</span>
			<ul>
				<li><span class="folder">Item 1.1</span>
					<ul>
</sample>
-->

    <!--    <xsl:import href="cmd_commons.xsl"/>-->

<!-- <xsl:output method="xml" />  -->
    <xsl:param name="max_depth">0</xsl:param>
    <xsl:param name="sort">name</xsl:param> <!-- s=size|n=name|t=time -->
    <xsl:param name="style_dir"/>
    <xsl:param name="basedir">../..</xsl:param>
    <xsl:param name="format"/>
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>
    <xsl:param name="title">Index: <xsl:value-of select="/*/@root"/>
    </xsl:param>
    <xsl:template name="callback-header">
        <style type="text/css">
		#collectionstree { margin-left: 10px; border: 1px solid #9999aa; border-collapse: collapse;}
		.number { text-align: right; }
		td { border-bottom: 1px solid #9999aa; padding: 1px 4px;}
		.treecol {padding-left: 1.5em;}
		table thead {background: #ccccff; font-size:0.9em; }
		table thead tr th { border:1px solid #9999aa; font-weight:normal; text-align:left; padding: 1px 4px;}
}  
	</style>
        <script type="text/javascript">
		$(function(){
			$("#indextreetable").treeTable();
		});
	</script>
    </xsl:template>
    
<!--  this is temporary - instead of common root cool in commons.xsl   -->
    <xsl:template match="/">
        <xsl:call-template name="continue-root"/>
    </xsl:template>
    <xsl:template name="continue-root">
        <h1>
            <xsl:value-of select="$title"/>
        </h1>
        <xsl:choose>
            <xsl:when test="$format='treetable'">
                <div id="index-view">
                    <table id="index-treetable">
                        <thead>
                            <tr>
                                <th class="treecol">Name</th>
                                <th>Count (visible) Subcoll</th>
                                <th>Count Resources</th>
                                <th>Handle</th>
                            </tr>
                        </thead>
                        <xsl:apply-templates select="*" mode="detail">
                            <xsl:sort order="ascending" select="@n"/>
                        </xsl:apply-templates>
                    </table>
                </div>
            </xsl:when>
            <xsl:otherwise>
    	 		<!-- <div>
    	 		 -->
                <ul class="treeview">
                    <xsl:apply-templates select="*">
                        <xsl:sort order="ascending" select="@n"/>
                    </xsl:apply-templates>
                </ul>
				<!-- </div>
				 -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- treeview -->
    <xsl:template match="*">
        <xsl:variable name="lv" select="count(ancestor::*)"/>
        <xsl:variable name="root" select="/*/@root"/>
        <xsl:choose>
            <xsl:when test="($lv&gt;0) or $root='root'">
                <li>
<!--                    <a href="{my:formURL('record','htmldetail', @handle )}">-->
                    <a href="{@n}">
                        <xsl:value-of select="@n"/>
                    </a>
                    <xsl:if test="* and ($lv&lt;$max_depth or $max_depth=0)">
                        <ul>
                            <xsl:choose>
                                <xsl:when test="$sort='s'">
                                    <xsl:apply-templates select="*">
                                        <xsl:sort order="descending" select="@cnt" data-type="number"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="*">
                                        <xsl:sort order="ascending" select="@n"/>
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ul>
                    </xsl:if>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="* and ($lv&lt;$max_depth or $max_depth=0)">
                    <xsl:choose>
                        <xsl:when test="$sort='s'">
                            <xsl:apply-templates select="*">
                                <xsl:sort order="descending" select="@cnt" data-type="number"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort order="ascending" select="@n"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="detail">
        <xsl:param name="parentid" select="'c-'"/>
        <xsl:variable name="lv" select="count(ancestor::*)"/>
        <xsl:variable name="cid">
            <xsl:choose>
                <xsl:when test="$lv=0">
                    <xsl:value-of select="concat($parentid,position())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($parentid,'-', position())"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- TODO: dynamic -->
        <tr id="{$cid}">
            <xsl:if test="$lv!=0">
                <xsl:attribute name="class" select="concat('child-of-',$parentid)"/>
            </xsl:if>
            <td class="treecol">
                <xsl:value-of select="@n"/>
            </td>
            <td class="number">
                <xsl:value-of select="count(.//*)"/>
            </td>
            <td class="number">
                <xsl:value-of select="@cnt"/>
            </td>
            <td>
                <xsl:value-of select="@handle"/>
            </td>
        </tr>
        <xsl:if test="* and ($lv&lt;$max_depth or $max_depth=0)">
            <xsl:choose>
                <xsl:when test="$sort='s'">
                    <xsl:apply-templates select="*" mode="detail">
                        <xsl:with-param name="parentid" select="$cid"/>
                        <xsl:sort order="descending" select="@cnt" data-type="number"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*" mode="detail">
                        <xsl:with-param name="parentid" select="$cid"/>
                        <xsl:sort order="ascending" select="@n"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>