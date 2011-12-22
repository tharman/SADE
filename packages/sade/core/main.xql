import module namespace sade =  "http://sade" at "xmldb:exist:///db/sade/core/main.xqm";

declare namespace sp = "http://sade/processing";

declare option exist:serialize "method=html media-type=text/html"; 

(: let $template := <html><sp:template name="index" /></html>  :)

let $config := doc("/db/sade/projects/default/config.xml")

(:return xs:string($config//sade:template/@path):)

 return sade:init-process($config) 