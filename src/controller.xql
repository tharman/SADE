xquery version "1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


(:        <forward url="../../../sade-projects/default/index.html" />
<forward url="{$exist:controller}/../sade-projects/default/{$exist:resource}" />
(:                <set-attribute name="project-config" value="{$project-config}" />:)
:)
        
if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then
    let $params := text:groups($exist:path, '([^/]+)*/([^/]+)$')
    
    let $project := if ($params[2]) then $params[2] else 
                           if (not(request:get-parameter('project',"")="")) then request:get-parameter('project',"") 
                           else "default" 
return 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/core/view.xql" >
            <add-parameter name="project" value="{$project}"/>
            <add-parameter name="exist-path" value="{$exist:path}"/>
            <add-parameter name="exist-resource" value="{$params[3]}"/>

            
        </forward>
    	<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/core/view.xql"/>
		</error-handler>
    </dispatch>
(: Requests for javascript libraries are resolved to the file system :)
else if (contains($exist:path, "/libs/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/{substring-after($exist:path, '/libs/')}" absolute="yes"/>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
