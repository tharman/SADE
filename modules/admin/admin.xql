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

let $configfile:= concat('/db/projects/', $project, '/static/config.xml')

let $formular := transform:transform(<nocontent></nocontent>, doc('formular.xsl'), <parameters><param name="lang" value="{$lang}" /><param name="id" value="{$id}" /></parameters>)

let $nav :=   <div id="nav">
                <ul> 
                    { (if ($id='general') then (<li class="active"><a href="?id=general&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:general/text()}</a></li>)
                    else (<li><a href="?id=general&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:general/text()}</a></li>),
                
                    if ($id='design') then (<li class="active"><a href="?id=design&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:design/text()}</a></li>)
                    else (<li><a href="?id=design&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:design/text()}</a></li>), 
                
                    if ($id='pages' or $id='edition' or $id='description'or $id='imprint') 
                        then (<li><a href="?id=pages&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:pages/text()}</a>
                                    <ul>
                                        {( 
                                        if ($id='edition') then (<li class="active"><a href="?id=edition&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:edition/text()}</a></li>)
                                        else (<li><a href="?id=edition&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:edition/text()}</a></li>),
                                        if ($id='description') then (<li class="active"><a href="?id=description&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:description/text()}</a></li>)
                                        else (<li><a href="?id=description&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:description/text()}</a></li>),
                                        if ($id='imprint') then (<li class="active"><a href="?id=imprint&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:imprint/text()}</a></li>)
                                        else (<li><a href="?id=imprint&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:imprint/text()}</a></li>)
                                        )}
                                    </ul>
                                </li>) 
                        else (<li><a href="?id=pages&amp;project={$project}&amp;lang={$lang}">{$language//sade:general/sade:nav/sade:pages/text()}</a></li>)) } 
                    </ul>
                </div>
                
let $instances := if (contains($id, 'design')) then (<xf:instance xmlns="" src="/exist/rest/db/sade/modules/admin/kickstrap/Kickstrap/themes" id="themes" />)
                  else ()
                  
let $bind :=    (
                if (contains($id, 'general')) then (
                    <xf:bind id="name" nodeset="/sade:SADE_project/sade:meta/sade:project_name" required="true()" constraint="string-length(.) > 0" />
                ) else (),
                if (contains($id, 'design')) then (
                    (: Datentyp muss definiert werden, sonst funktioniert Uploadfeld nicht :)
                    <xf:bind nodeset="/sade:SADE_project/sade:design/sade:footer/sade:img" type="xs:anyURI" />
                 ) else ()
                )
                
return 
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:sade="http://bbaw.de/sade">
    <head>
        <title>{$language/sade:dashboard/sade:sade/text()}: {doc($configfile)/sade:SADE_project/sade:meta/sade:project_name}</title>
        <link rel="stylesheet" type="text/css" href="resources/css/font-awesome.css" />
        <link rel="stylesheet" type="text/css" href="resources/css/adminpanel.css" />
        <xf:model id="data">
            <!-- Daten der config.xml laden -->
            <xf:action ev:event="xforms-ready">
                <xf:send submission="read"/>
            </xf:action> 
            <xf:instance id="sade_config" src="/exist/rest{$configfile}" />
            <xf:submission id="read" method="get" replace="instance" instance="sade_config" action="/exist/rest{$configfile}">
                <xf:toggle case="none" ev:event="xforms-submit-done" />
            </xf:submission>
            <!-- Geänderte Daten in config.xml schreiben -->
            <xf:submission id="save" method="put" replace="none" action="/exist/webdav{$configfile}">
                <!-- Fälle für Erfolg/Fehler beim Übermitteln -->
                <xf:toggle case="notsaved" ev:event="xforms-submit-error" />
                <xf:toggle case="saved" ev:event="xforms-submit-done" /> 
            </xf:submission>
            <!-- Beschriftungen laden -->
            <xf:instance src="/exist/rest/db/sade/modules/admin/resources/lang/{$lang}.xml" id="lang" />
            <!-- Weitere Instanzen -->
            {$instances}
            {$bind}
        </xf:model>
        <!-- Warnung beim Verlassen der Seite deaktivieren -->
        <script type="text/javascript" src="resources/betterform_ext.js" defer="defer">&#160;</script>
        </head>
    <body>
        <div id="container">
            <div id="head">
                <h1><a href="/exist/rest/db/projects/{$project}/index.xql" target="_blank" title="{$language/sade:general/sade:showWebsite}">{doc($configfile)/sade:SADE_project/sade:meta/sade:project_name}</a></h1>
                <h2><a href="dashboard.xql?lang={$lang}">{$language/sade:dashboard/sade:sade/text()} - {$language/sade:dashboard/sade:title/text()}</a></h2>
                <div id="langmenu">
                    <a href="?id={$id}&amp;project={$project}&amp;lang=en" title="English">EN</a> |
                    <a href="?id={$id}&amp;project={$project}&amp;lang=de" title="Deutsch">DE</a> |
                    <a href="?id={$id}&amp;project={$project}&amp;lang=fr" title="Français">FR</a>
                </div>
            </div>
            {$nav}
            <div id="content">
                <!-- Erfolgs- oder Fehlermeldung nach dem Speichern --> 
                <xf:switch>
                    <xf:case id="saved">
                        <p class="saved">{$language/sade:general/sade:submit_success/text()}</p>
                    </xf:case>
                    <xf:case id="notsaved">
                        <p class="savefailed">{$language/sade:general/sade:submit_error/text()}</p>
                    </xf:case>
                    <xf:case id="none">
                    </xf:case>
                </xf:switch>
                <!-- Formular aus formular.xsl -->
                {$formular}
                <!-- Speicherschaltfläche -->
                <xf:submit submission="save">
                    <xf:label ref="instance('lang')/sade:lang[@id='{$lang}']/sade:general/sade:submit"/>
                </xf:submit>
            </div>
        </div>
    </body>
</html>

