xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace sade = "http://bbaw.de/sade";
declare option exist:serialize "method=xhtml media-type=text/xml"; 

let $projectid := request:get-parameter("projectid", "")
let $existingProjects := <ul> { for $x in xmldb:get-child-collections('/db/projects/')
                         return
                         <li>{$x}</li>
                         } </ul>


let $isLoggedIn := xmldb:login("/db/sade/modules/admin/kickstrap", "admin", "")

let $createCollection :=   (xmldb:create-collection('/db/projects/', $projectid),
                            xmldb:copy('/db/projects/ai-test/static', concat('/db/projects/', $projectid)),
                            xmldb:copy('/db/projects/ai-test/index.xql', concat('/db/projects/', $projectid)))

return
if ($existingProjects//li/contains(./data(.), $projectid) and $projectid) 
then ($createCollection)
else (<html>FEHLER!!!</html>)
