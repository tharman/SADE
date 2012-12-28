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

declare option exist:serialize "method=html5 media-type=text/html";

let $lookup :=function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()  
    }
} 
(: 
 : The HTML is passed in the request from the controller. 
 : (the controller cares for fetching the correct template-file based on project context)
 : Run it through the templating system and return the result.
 :)
 
let $template := request:get-data() 
    
return templates:apply($template, $lookup,  ())