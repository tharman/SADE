xquery version "1.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "core/config.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


(:let $params := text:groups($exist:path, '^([^/]+)*/([^/]+)$'):)
let $params := tokenize($exist:path, '/')

 let $project :=  if (config:project-exists($params[2])) then $params[2] 
                  else if (config:project-exists(request:get-parameter('project',"default"))) then 
                            request:get-parameter('project',"default") 
                  else "default" 
 let $project-config :=  config:project-config($project) 
 let $config := map { "config" := $project-config}
 let $template-id := config:param-value($config,'template')
 
 let $file-type := tokenize($exist:resource,'\.')[last()]
 (: remove project from the path to the resource  needed for web-resources (css, js, ...) :)
 let $rel-path := if (contains($exist:path,$project )) then substring-after($exist:path, $project) else $exist:path
 
return         
if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <forward url="{$exist:controller}/{$config:templates-dir}{$template-id}/{$exist:resource}"/>
      <view>
        <forward url="{$exist:controller}/core/view.xql" >
            <add-parameter name="project" value="{$project}"/>
            <add-parameter name="exist-path" value="{$exist:path}"/>
            <add-parameter name="exist-resource" value="{$exist:resource}"/>
        </forward>
    	<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/core/view.xql"/>
		</error-handler>
	   </view>
    </dispatch>
(: Requests for js, css are resolved via our special resolver 
<forward url="{concat('/sade/templates/', $template-id, '/', $rel-path )}" />
:)
else if ($file-type = ('js', 'css', 'png', 'jpg')) then
    let $path := config:resolve-template-to-uri($config, $rel-path)
    return <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$path}" />        
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
