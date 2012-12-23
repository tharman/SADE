(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :
 : It also passes the dynamic resolver to the templating system, 
 : that allows it to resolve the module functions
 :)
xquery version "3.0";

(:import module namespace resolver="http://exist-db.org/xquery/resolver" at "resolver.xql";:)
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
   import module namespace app="http://sade/app" at "app.xql";  
   import module namespace test="http://sade/test" at "../modules/test/test.xqm";

declare variable $exist:resource external;

declare option exist:serialize "method=html5 media-type=text/html";


let $lookup :=function($functionName as xs:string, $arity as xs:int) {
    try {
         (:let $mod := util:import-module(
          xs:anyURI('http://exist-db.org/xquery/app'),
          'app',
          xs:anyURI('app.xql')
          ) :)
         (: 
          let $modules := <modules>
                            <module key="app" ns="http://exist-db.org/xquery/app" location="app.xql" />
                            <module key="test" ns="http://sade/test" location="../modules/test/test.xqm" />
                            </modules>
        for $module in $modules/module   
         let $mod := util:import-module(
          xs:anyURI($module/xs:string(@ns)), $module/xs:string(@key), xs:anyURI($module/xs:string(@location))
          )
          
        return :)
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()  
    }
} 
(:  :
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
 
 let $project-dir := "/db/apps/sade-projects/"
 let $templates-dir:= "/db/apps/sade/templates/"
 
let $project := if (request:get-parameter('project',"")="") then "default" else request:get-parameter('project',"")
let $exist-resource:= request:get-parameter('exist-resource',"index.html")
let $exist-path:= request:get-parameter('exist-path',"")

let $project-config-path := concat($project-dir, $project, "/config.xml")
let $project-config := if (doc-available($project-config-path)) then doc($project-config-path) else ()
let $model := map { "config" := $project-config}

(:let $template-id := config$project-config//property[xs:string(@key)='template']:)
let $template-id := config:param-value($model,'template')
let $template-path := concat($templates-dir,$template-id, "/", $exist-resource)
let $template := if (doc-available($template-path)) then doc($template-path) else () 
    
(:   let $content := doc("/db/apps/sade-projects/default/index.html")  :)
(: let $content := request:get-data() :)
(:   :let $model := map { "resolve" := doc("/db/apps/sade-projects/default/config.xml") } :)

    
(:return (request:get-uri(), " # ", $project," # ", $exist-path, " # ", $exist-resource) :)
(: return $project-config:)
return templates:apply($template, $lookup,  ())