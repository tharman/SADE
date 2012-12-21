(:~ fetches static data for the page from a collection defined in config :)

module namespace static = "http://sade/static" ;

import module namespace sade = "http://sade" at "/apps/sade/core/main.xqm";
import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///apps/sade/core/modules/diagnostics/diagnostics.xqm";

declare function static:process-template($template-node as node(), $config as node()) as item()* {
    
    let $not-accepts := sade:param-value("not-accepts", $template-node, $config, "")
    
    let $show := util:eval('sade:param-value($not-accepts,$template-node, $config, "") eq ""')
    
    let $requested-page:=  sade:param-value("page",$template-node, $config, "welcome")
    let $static-dir:=  sade:config-value($config, "static.dir")
     
    let $page-path := concat($static-dir, $requested-page, ".xml")
    let  $page-data := if (doc-available($page-path)) then doc($page-path)
                else diag:diagnostics("general-error", concat("No page =", $requested-page, " at: ", $page-path))
    return if ($show) then $page-data else ()
};

declare function static:header($config as node()) as item()* {
    ()
};
