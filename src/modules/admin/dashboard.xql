xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace sade = "http://bbaw.de/sade";
declare option exist:serialize "method=xhtml media-type=text/xml"; 

let $id := request:get-parameter("id", "general")
let $lang := request:get-parameter("lang", "en")

let $language := doc(concat('resources/lang/', $lang, '.xml'))//sade:lang

let $projects := for $x in collection('/db/projects/')//sade:SADE_project
                return
                <div xmlns="http://www.w3.org/1999/xhtml" class="kachel project">
                    <a class="imga" href="admin.xql?id=general&amp;project={$x//sade:pid}&amp;lang={$lang}">
                        <i class="icon-folder-close">{$x/sade:meta/sade:project_name}</i>
                    </a>
                </div>
                

return
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>SADE - Scalable Architecture for Digital Editions</title>
        <link rel="stylesheet" type="text/css" href="resources/css/dashboard.css" />
        <link rel="stylesheet" type="text/css" href="resources/css/font-awesome.css" />
    </head>
    <body>
        <div id="container">
            <div id="head">
                <h1>{$language/sade:dashboard/sade:sade}<br />{$language//sade:dashboard/sade:title}</h1>
                <div id="langmenu">
                    <a href="?lang=en" title="English">EN</a> |
                    <a href="?lang=de" title="Deutsch">DE</a> |
                    <a href="?lang=fr" title="Français">FR</a>
                </div>
            </div>
            <div id="content">

                
                {$projects}
                
                <div class="kachel newproject">
                    <a class="imga" href="new.xql?lang={$lang}">
                        <i class="icon-plus-sign"><br />{$language/sade:dashboard/sade:newproject}</i>
                    </a>
                </div>
                <div class="kachel doc">
                    <a class="imga" href="">
                        <i class="icon-file"><br />{$language/sade:dashboard/sade:doc}</i>
                    </a>
                </div>
            </div>
            <div id="footer">
                <p>SADE - Scalable Architecture for Digital Editions is a project of TELOTA, Berlin-Brandenburg Academy of Sciences and Humanities. SADE uses various open source software: e.g. eXistdb, digilib and betterForm. Go to http://sade.bbaw.de/ for details.
                    SADE comes with ABSOLUTELY NO WARRANTY; click for details. This is free software, and you are welcome to redistribute it under certain conditions; click for details. Obstructing the appearance of this notice is prohibited by law.</p>
            </div>
        </div>
    </body>
</html>