(:~ this is the invocation script
it only sets the right project's config 
and passes to main module.
:)

import module namespace sade =  "http://sade" at "xmldb:exist:///db/sade/core/main.xqm";
declare option exist:serialize "method=xhtml media-type=text/html"; 

let $project :=  request:get-parameter("project", "default")
let $config := doc(concat("/db/sade/projects/", $project, "/config.xml"))
  
return sade:main($config, $project)