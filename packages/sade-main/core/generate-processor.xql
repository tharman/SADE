import module namespace gen =  "http://sade/gen" at "xmldb:exist:///apps/sade/core/generate-processor.xqm";

declare option exist:serialize "method=text media-type=text/text";
 
let $config :=  doc("/apps/sade-projects/default/config.xml")/*
let $generated-code := gen:generate-processor($config)
return xmldb:store("/apps/sade/core", "processor.xql", $generated-code)

