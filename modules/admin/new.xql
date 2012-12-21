xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace sade = "http://bbaw.de/sade";
declare option exist:serialize "method=xhtml media-type=text/xml";

let $id := request:get-parameter("id", "general")
let $lang := request:get-parameter("lang", "en")
let $project := request:get-parameter("project", "")

let $language := doc(concat('resources/lang/', $lang, '.xml'))//sade:lang

return 
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:sade="http://bbaw.de/sade">
    <head>
        <title>SADE - Scalable Architecture for Digital Editions</title>
        <link rel="stylesheet" type="text/css" href="resources/css/newproject.css" />
        <link rel="stylesheet" type="text/css" href="resources/css/font-awesome.css" />
            <xf:model>
            <xf:instance>
                <data xmlns="">
                    <projectname/>
                    <projectid/>
                </data>
             </xf:instance>
            <!-- Daten an generateproject.xql übergeben -->
            <xf:submission id="save" method="get" action="/exist/rest/db/sade/modules/admin/generateproject.xql">
                <xf:toggle case="notsaved" ev:event="xforms-submit-error" />
                <xf:toggle case="saved" ev:event="xforms-submit-done" /> 
            </xf:submission>
            <!-- Beschriftungen laden -->
            <xf:instance src="/exist/rest/db/sade/modules/admin/resources/lang/{$lang}.xml" id="lang" />
            <!-- Weitere Instanzen -->
        </xf:model>
        <!-- Warnung beim Verlassen der Seite deaktivieren -->
        <script type="text/javascript" src="resources/betterform_ext.js" defer="defer">&#160;</script>
    </head>
    <body>
        <div id="container">
            <div id="head">
              <h1>{$language/sade:dashboard/sade:sade/data(.)}<br />{$language/sade:dashboard/sade:title/data(.)}</h1>
                <div id="langmenu">
                    <a href="?lang=en" title="English">EN</a> |
                    <a href="?lang=de" title="Deutsch">DE</a> |
                    <a href="?lang=fr" title="Français">FR</a>
                </div>
            </div>               
                <div id="content">
                    <h1>
                        <xf:value ref="instance('lang')/sade:lang[@id='{$lang}']/sade:meta/sade:h"/>
                    </h1>
                    <xf:input ref="projectname">
                        <xf:label ref="instance('lang')/sade:lang[@id='{$lang}']/sade:newproject/sade:name/sade:title"/>
                        <xf:hint ref="instance('lang')/sade:lang[@id='{$lang}']/sade:newproject/sade:name/sade:hint"/>
                        <xf:alert ref="instance('lang')/sade:lang[@id='{$lang}']/sade:general/sade:requiredField"/>
                    </xf:input>
                    <xf:input ref="projectid">
                        <xf:label ref="instance('lang')/sade:lang[@id='{$lang}']/sade:newproject/sade:id/sade:title"/>
                        <xf:hint ref="instance('lang')/sade:lang[@id='{$lang}']/sade:newproject/sade:id/sade:hint"/>
                        <xf:alert ref="instance('lang')/sade:lang[@id='{$lang}']/sade:general/sade:requiredField"/>
                    </xf:input>
                    <!-- Speicherschaltfläche -->
                    <xf:submit submission="save">
                        <xf:label ref="instance('lang')/sade:lang[@id='{$lang}']/sade:newproject/sade:submit"/>
                    </xf:submit>
                </div>
           <div id="footer">
                <p>SADE - Scalable Architecture for Digital Editions is a project of TELOTA, Berlin-Brandenburg Academy of Sciences and Humanities. SADE uses various open source software: e.g. eXistdb, digilib and betterForm. Go to http://sade.bbaw.de/ for details.
                    SADE comes with ABSOLUTELY NO WARRANTY; click for details. This is free software, and you are welcome to redistribute it under certain conditions; click for details. Obstructing the appearance of this notice is prohibited by law.</p>
            </div>
        </div>
    </body>
</html>

