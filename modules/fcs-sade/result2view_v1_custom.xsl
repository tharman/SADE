<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/" xmlns:saxon="http://saxon.sf.net/" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" xmlns:exsl="http://exslt.org/common" version="1.0" exclude-result-prefixes="saxon xs exsl diag sru fcs">
<!--   
    <purpose> customization of the default fcs-result2view for sade</purpose>
<history>  
<change on="2012-04-20" type="created" by="vr">based on fcs-xsl/result2view_v1.xsl</change>	
</history>
--> 
    <!-- FIXME: very fragile! the referencing of the base stylesheet has to be solved more reliably/flexibly -->
    <xsl:import href="../../../../db/cr/xsl/result2view_v1.xsl"/>
    <xsl:param name="contexts_url" select="concat($base_url,'?operation=scan&amp;scanClause=fcs.resource&amp;sort=text')"/>
    <xsl:param name="current-template"/>
    <xsl:template name="continue-root">
        <xsl:for-each select="sru:searchRetrieveResponse">
            <xsl:apply-templates select="sru:diagnostics"/>
            <div>
                <h2>Suche</h2>
                <!-- TODO: indexes - as auto-complete! -->
                <form id="query-input" action="{$base_url}" method="get">
                    <input type="hidden" name="x-format" value="{$format}"/>
                    <input type="hidden" name="maximumRecords" value="10"/>
                    <input type="hidden" name="current-template" value="{$current-template}"/>
                    <input type="text" id="input-simplequery" name="query" value="{$q}" class="queryinput active"/>
                    <input type="submit" value="suchen" id="submit-query"/>
                    <br/>
    <!--                    <xsl:call-template name="result-paging"></xsl:call-template>-->
                </form>
                <div class="result-header ui-state-active">
                    <span class="value">
                        <xsl:value-of select="sru:echoedSearchRetrieveRequest/sru:startRecord"/>
                    </span>
                    <span class="label"> bis </span>
                    <span class="value">
                        <xsl:value-of select="(sru:echoedSearchRetrieveRequest/sru:startRecord + sru:extraResponseData/fcs:returnedRecords - 1)"/>
                    </span>
                    <span class="label"> von </span>
                    <span class="value">
                        <xsl:value-of select="$numberOfRecords"/>
                    </span>
                    <span class="label"> Einträgen ( </span>
                    <span class="value">
                        <xsl:value-of select="$numberOfMatches"/>
                    </span>
                    <span class="label"> Treffer)</span>
                    <xsl:call-template name="prev-next"/>
                </div>
                <xsl:apply-templates select="sru:records" mode="list"/>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="sru:records" mode="list">
        <div class="result-body">
            <table class="ui-widget-content">
                <tbody>
                    <xsl:apply-templates select="sru:record" mode="list"/>
                </tbody>
            </table>
        </div>
    </xsl:template>
</xsl:stylesheet>