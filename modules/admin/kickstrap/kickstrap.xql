xquery version "1.0";

module namespace trigger="http://exist-db.org/xquery/trigger";
declare namespace sade = "http://bbaw.de/sade";
declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

declare function trigger:after-update-document($uri as xs:anyURI) {
let $theme := doc('/db/projects/ai-test/static/config.xml')/sade:SADE_project/sade:design/sade:theme/text()
let $theme.less :=  if (string-length($theme) < 1) 
                    then (<theme>
                        // load default bootstrap theme
                        // @import "Kickstrap/themes/amelia/variables.less";   
                        // @import "Kickstrap/themes/amelia/bootswatch.less";
                    </theme>)
                    else (
                        <theme>
                        @import "Kickstrap/themes/{$theme}/variables.less";   
                        @import "Kickstrap/themes/{$theme}/bootswatch.less";
                        </theme>)


let $isLoggedIn := xmldb:login("/db/sade/modules/admin/kickstrap", "admin", "")
let $ausgabe := xmldb:store("/db/sade/modules/admin/kickstrap", "theme.less", $theme.less/text())
return
()
};
