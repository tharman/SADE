import module namespace sade =  "http://sade" at "xmldb:exist:///db/sade/core/main.xqm";
import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///db/sade/modules/diagnostics/diagnostics.xqm";

declare namespace sp = "http://sade/processing";

declare option exist:serialize "method=xhtml media-type=text/html"; 

(:
let $template := <html><sp:template name="index" /></html>  :)


declare function local:main() as item()* {  
  
  let $project :=  request:get-parameter("project", "default")
  let $module :=  request:get-parameter("module", "")
    let $config := doc(concat("/db/sade/projects/", $project, "/config.xml"))

(:return xs:string($config//sade:template/@path):)
    return if (exists($config)) then
        if ($module eq "") then
            sade:init-process($config)
           else
            sade:html-output(sade:process-module($module, $config), $config)
       else
        diag:diagnostics("unsupported-param-value", concat("project=", $project))
};
 
 
 local:main()