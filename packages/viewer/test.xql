xquery version "1.0";
declare namespace sade = "http://sade" ;
import module namespace viewer = "http://sade/viewer" at "viewer.xqm";

let $conf := <config xmlns="http://sade">
                <data path="/apps/sade/projects/textgrid/data/xml"/>
                <viewer xslt="/apps/sade/modules/teixslt/xml/tei/stylesheet/xhtml2/tei.xsl"/>      
            </config>
            
    let $docname := 'h6h6.0'

    let $doc := doc(concat($conf//sade:data/@path, '/',  $docname ))
    let $xsl := doc($conf//sade:viewer/@xslt)

return
viewer:xslt($conf, $docname)

