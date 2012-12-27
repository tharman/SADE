module namespace app="http://sade/app";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
(:
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic"
    at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace fcs = "http://clarin.eu/fcs/1.0" at "/db/cr/fcs.xqm";
import module namespace repo-utils = "http://aac.ac.at/content_repository/utils" at  "/db/cr/repo-utils.xqm";
:)

 (:
 obsoleted by templates:init()
declare 
    %templates:wrap
function app:init($node as node(), $model as map(*), $project as xs:string?) {
        let $project-config-path := concat($config:projects-dir, $project, "/config.xml")
        let $project-resolved := if (doc-available($project-config-path)) then $project else "no such project"
        let $project-config := if (doc-available($project-config-path)) then doc($project-config-path) else ()
        return map { "config" := $project-config 
        }
};
:)
 (:   <p>{$project}</p>:)
 
        (:    <p>exist:root {request:get-attribute("$exist:root")}<br/>
        exist:resource {request:get-attribute("$exist:resource")}<br/>
        exist:path {request:get-attribute("$exist:path")}<br/>
        exist:controller {request:get-attribute("$exist:controller")}<br/>
        exist:prefix {request:get-attribute("$exist:prefix")}<br/>
        get-uri {request:get-uri()}<br/>
        config:app-root {$config:app-root}<br/>
        
</p>:)


declare 
    %templates:wrap
function app:title($node as node(), $model as map(*)) {
(:    $model("config")//param[xs:string(@key)='project-title']:)
config:param-value($model, 'project-title')
(:    <p>exist:root {request:get-attribute("$exist:root")}<br/>
        exist:resource {request:get-attribute("$exist:resource")}<br/>
        exist:path {request:get-attribute("$exist:path")}<br/>
        exist:controller {request:get-attribute("$exist:controller")}<br/>
        exist:prefix {request:get-attribute("$exist:prefix")}<br/>
        get-uri {request:get-uri()}<br/>
        config:app-root {$config:app-root}<br/>
        
</p>:)
};