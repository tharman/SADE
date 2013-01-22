<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0" exclude-result-prefixes="xs" version="1.0">
    <xsl:param name="user"/>

    <!-- baseUrl for constructing
        //sru:baseUrl
    -->
    <xsl:param name="title" select="''"/>
    <xsl:param name="base_url" select="''"/>
    <!--<xsl:param name="base_url">http://clarin.aac.ac.at/exist7/rest/db/content_repository</xsl:param>
        <xsl:param name="base_dir">http://corpus3.aac.ac.at/cs/</xsl:param>-->
    <xsl:param name="scripts_url" select="''"/>
    <!-- http://clarin.aac.ac.at/exist7/rest/db/content_repository/scripts</xsl:param> -->
    <xsl:param name="site_logo" select="concat($scripts_url, 'style/logo_c_s.png')"/>
    <xsl:param name="site_name">Repository</xsl:param>
    
    <!-- following are needed in in commons_v1.xsl (formURL) and in html_snippets.xsl, therefore they need to be defined here
        (but only as default, so we could move them, because actually they pertain only to result2view.xsl -->
    <xsl:param name="format" select="'htmlpagelist'"/> <!-- table|list|detail -->
    <xsl:param name="q" select="/sru:searchRetrieveResponse/sru:echoedSearchRetrieveRequest/sru:query"/>
    <xsl:param name="x-context" select="/sru:searchRetrieveResponse/sru:echoedSearchRetrieveRequest/fcs:x-context"/>
    <xsl:param name="startRecord" select="/sru:searchRetrieveResponse/sru:echoedSearchRetrieveRequest/sru:startRecord"/>
    <xsl:param name="maximumRecords" select="/sru:searchRetrieveResponse/sru:echoedSearchRetrieveRequest/sru:maximumRecords"/>
    <xsl:param name="numberOfRecords" select="/sru:searchRetrieveResponse/sru:numberOfRecords"/>
    <xsl:param name="numberOfMatches" select="/sru:searchRetrieveResponse/sru:extraResponseData/fcs:numberOfMatches"/>
    <xsl:param name="mode" select="'html'"/>
    <xsl:param name="scanClause" select="''"/>
    <xsl:param name="contexts_url" select="concat($base_url,'?operation=scan&amp;scanClause=fcs.resource&amp;sort=text&amp;version=1.2&amp;x-format=xml')"/>
    <xsl:param name="mappings-file" select="''"/>
    <xsl:variable name="context-param" select="'x-context'"/>
    <xsl:variable name="mappings" select="document($mappings-file)/map"/>
    <xsl:variable name="context-mapping" select="$mappings//map[@key][xs:string(@key) = $x-context]"/>
    <xsl:variable name="default-mapping" select="$mappings//map[@key][xs:string(@key) = 'default']"/>
</xsl:transform>