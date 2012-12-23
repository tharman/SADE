(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://exist-db.org/xquery/apps/config";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
(:        substring-before($modulePath, "/modules"):)
        substring-before($modulePath, "/core")
;

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare %templates:wrap function config:app-description($node as node(), $model as map(*)) as text() {
    $config:repo-descriptor/repo:description/text()
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
  (:  let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return :)
    (:{
                for $attr in ($expath/@*, $expath/*, $repo/*)
                where $attr/string() != ""
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }:)
        <table class="table table-bordered table-striped">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            <tr>
                <td>system:get-module-load-path():</td>
                <td>{system:get-module-load-path()}</td>
            </tr>
            
            
        </table>
};

(:~
 : 
 :
 :)
 
 declare function config:param-keys($config as map(*)*) as xs:string* {

    let $config := $config("config")
    
    for $key in distinct-values($config//param/xs:string(@key))
        order by $key
        return $key
    
};


declare function config:param-value($node as node()*, $config as map(*)*, $module-key as xs:string, $function-key as xs:string, $param-key as xs:string) as item()* {

    let $node-id := $node/xs:string(@id)
    let $config := $config("config")
    
    let $param-request := request:get-parameter($param-key,'')
    let $param-container := $config//container[@key=$node-id]/function[xs:string(@key)=concat($module-key, ':', $function-key)]/param[xs:string(@key)=$param-key]
    let $param-function := $config//function[xs:string(@key)=concat($module-key, ':', $function-key)]/param[xs:string(@key)=$param-key]
    let $param-module := $config//module[xs:string(@key)=$module-key]/param[xs:string(@key)=$param-key]
    let $param-global:= $config//param[xs:string(@key)=$param-key][parent::config]
    
    let $param := if ($param-request != '') then $param-request
                        else if (exists($param-container)) then $param-container 
                        else if (exists($param-function)) then $param-function
                           else if (exists($param-module)) then $param-module
                              else if (exists($param-global)) then $param-global
                              else ""
    
    let $param-value := if ($param instance of text() or $param instance of xs:string) then $param
                           else if (exists($param/@value)) then $param/xs:string(@value)
                           else if (exists($param/*)) then $param/*
                           else $param/text()
                           
   return $param-value
    
};

declare function config:param-value($config as map(*), $param-key as xs:string) as item()* {
    config:param-value((),$config,'','',$param-key)
};