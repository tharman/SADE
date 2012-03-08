module namespace sade = "http://sade";

import module namespace sp =  "http://sade/processing" at  "xmldb:exist:///db/sade/core/processor.xql";
import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///db/sade/modules/diagnostics/diagnostics.xqm";

declare variable $sade:baseurl := "/exist/rest/db/sade/";

declare function sade:init-process($config as node()) as item()* {

    let $template-path := xs:string($config//sade:template/@path)
    (: TODO: add diagnostics doc-available :) 
    let $template := doc($template-path)
    return sade:process ($template/*, $config)

};

declare function sade:process($nodes as node()*, $config as node()) as item()* {
  for $node in $nodes     
    return  typeswitch ($node)              
        case text() return $node                
        case element(div) return sp:process-template($node, $config)
        default return sade:process-default($node, $config )

    };

declare function sade:process-default($node as node(), $config as node()) as item()* {
  (: xml comments have no node name :)
  if($node/name() ne '' ) then
    element {$node/name()} {($node/@*, sade:process($node/node(), $config ))} 
  else $node
  (: <div class="default">{$node/name()} </div> :)  
 };

declare function sade:process-module($module as xs:string, $config as node()) as item()* {

    let $template-path := xs:string($config//sade:template/@path)    
    let $template := <div id="{$module}" class="module"> </div>
    return sp:process-template ($template, $config)

};

declare function sade:html-output($content as node(), $config as node()) as item()* {
             
    let $wrapped := <html><head>{sp:header($config)}</head><body>{$content}</body></html>      
    return  $wrapped
    
};

declare function sade:header  ($config as node()) as item()* {

     let $header := <header>
                        <title>SADE - default project</title>
                        <link rel="stylesheet" type="text/css" href="{$sade:baseurl}templates/default/sade.css" media="all" ></link>
                        <script src="{$sade:baseurl}templates/default/scripts/jquery/jquery.min.js" type="text/javascript"></script>
                        <script src="{$sade:baseurl}templates/default/scripts/jquery/jquery-ui.min.js" type="text/javascript"></script>
               </header>
    return $header/*

};
