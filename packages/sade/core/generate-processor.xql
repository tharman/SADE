import module namespace gen =  "http://sade/gen" at "xmldb:exist:///db/sade/core/generate-processor.xqm";

declare option exist:serialize "method=text media-type=text/text";
 
let $config :=  doc("/db/sade/projects/default/config.xml")/*
return xmldb:store("/db/sade/core", "processor.xql",gen:generate-processor($config))

