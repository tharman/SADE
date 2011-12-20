module namespace sade = "http://sade";

import module namespace sp =  "http://sade/processing" at  "xmldb:exist:///db/sade/core/processor.xql";


declare function sade:init-process($config as node()) as item()* {

    let $template-path := $config//template/@path
    let $template := doc($template-path)
    return sade:process ($template/*, $config)

};

declare function sade:process($nodes as node()*, $config as node()) as item()* {
  for $node in $nodes     
    return  typeswitch ($node)              
        case text() return $node        
        case attribute() return $node
        case element(div) return sp:process-template($node, $config)
        default return sade:process-default($node, $config )

    };

declare function sade:process-default($node as node(), $config as node()) as item()* {
  element {$node/name()} {sade:process($node/node(), $config )}
  (: <div class="default">{$node/name()} </div> :)  
 };
