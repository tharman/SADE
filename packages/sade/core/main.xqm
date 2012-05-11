(:~ This is the main module of SADE_modules governing the processing of the templates
: @name SADE main  
: @since 2011-12-20 
:)
module namespace sade = "http://sade";

import module namespace sp =  "http://sade/processing" at  "xmldb:exist:///db/sade/core/processor.xql";
import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///db/sade/modules/diagnostics/diagnostics.xqm";

(:declare default element namespace "http://sade";:)


(:~ main entry point 
parametrized by config (all further processing is guided by the settings in config)

@param $config project specific configuration
@param $project - string identifying the project, serves only for diagnostics, the project-specific config should already be in the $config-param
@param $view - (read from HTTP-request) allows to select different layout configurations (mapped to different templates

@returns the full xhtml-page
:)
declare function sade:main($config as node(), $project as xs:string) as item()* {  

  let $module :=  request:get-parameter("module", "")
  let $view :=  request:get-parameter("view", "index")

(:return xs:string($config//sade:template/@path):)
    return if (exists($config)) then
        if ($module eq "") then
            sade:html-output(sade:init-process($config, $view), $config)
           else
            sade:html-output(sade:process-module($module, $config), $config)
       else
        diag:diagnostics("unsupported-param-value", concat("project=", $project))
};
 
(:~  fetches correct page-template depending on template.dir (in config) and the $view-param
: evaluates it to resolve xquery-code and only then sends it for processing module-processing 
:)
declare function sade:init-process($config as node(), $view as xs:string) as item()* {

    (: get the correct page-template depending on template.dir (in config) and the $view-param :)
    let $page-template := concat(sade:config-value($config, 'template.dir'), 'page_', $view, '.xml')
    (: default: page_index.xml :)
    let $default-page-template := concat( sade:config-value($config, 'template.dir'), 'page_index.xml')    
    
    let $template := if (doc-available($page-template)) then doc($page-template) 
        else if (doc-available($default-page-template)) then doc($default-page-template)
        else diag:diagnostics("general-error", concat("No template found! template.dir/view=", $page-template))
    
    (: this is to first evaluate the template - i.e. resolve all variables :)
    let $templatex := util:serialize($template, ())
    (: and only then continue with the resolution of dynamic parts / modules :)
    return sade:process (util:eval($templatex)/*, $config)
  
};


(:~ recursively traverse the nodes of the template
switch to specific processing when element(div), otherwise continue default processing
:)
declare function sade:process($nodes as node()*, $config as node()) as item()* {
  for $node in $nodes     
    return  typeswitch ($node)              
         case text() return sade:process-string($node, $config)                                
        case element(div) return sp:process-template($node, $config)
        case comment() return $node
        default return sade:process-default($node, $config )

    };

(:~ default processing when traversing the template: copy node and continue processing with the child nodes  
:)
declare function sade:process-default($node as node(), $config as node()) as item()* {
  element {$node/name()} {($node/@*, sade:process($node/node(), $config ))}  
};

(:~ allows for special handling of text()-nodes.
Was meant to util:eval() the strings, but this has been obsoleted by whole template being evald before processing !
:)
declare function sade:process-string($node as node(), $config as node()) as item()* {
  $node  
 };

(:~ by-pass function, if one wants to process only one module :) 
declare function sade:process-module($module as xs:string, $config as node()) as item()* {

    let $template-path := xs:string($config//sade:template/@path)    
    let $template := <div id="{$module}" class="module"> </div>
    return sp:process-template ($template, $config)

};

(:~ provides the html-wrapper :)
declare function sade:html-output($content as node(), $config as node()) as item()* {
             
    let $wrapped := <html><head>{sp:header($config)}</head><body>{$content}</body></html>      
    return  $wrapped

};

(:~ delivers the default html-head
: plus fetches the html-head snippet of the template (as given by config)
: it is called by sp:header(), next to the callbacks of the modules.
: i.e. individual modules can add their stuff via callback-function
:)
declare function sade:header($config as node()) as item()* {
      
      let $baseurl := sade:config-value($config, 'webscripts.prefix')
      let $template-htmlhead := sade:get-snippet($config, 'html-head') 
     let $header := <header>
                          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                         <title>{sade:config-value($config, 'sitename')}</title>                        
                    </header>
                          (:     OLD 
                             <title>{sade:param-value($config, 'sitename')}</title>
                        <link rel="stylesheet" type="text/css" href="{$baseurl}templates/default/sade.css" media="all" ></link>
                        <script src="{$baseurl}templates/default/scripts/jquery/jquery.min.js" type="text/javascript"></script>
                        <script src="{$baseurl}templates/default/scripts/jquery/jquery-ui.min.js" type="text/javascript"></script>:)
    return ($header/*, $template-htmlhead/*)

};



(:~ try to get a value for a key 
only regard configuration :)
declare function sade:config-value($config as node(), $key as xs:string) as xs:string* {
  $config//sade:property[@key=$key]
};

(:~ tries to get a param-value from either: request, template-node or config (in that order)  
returns a string-value based on the key
it has to get the config to read data from as param. (to avoid global variables)

if even no appropriate property found in config, $default is returned

@param $request-flag shall the request-parameter be considered?

WATCHME!: the functionality overlaps with cr/repo-utils:config-value() (but namespace issues) 
:)
declare function sade:param-value($key as xs:string, $template-node as node()*, $config as node(), $default, $request-flag as xs:boolean) as item()*  {
    let $request-value := request:get-parameter($key, "")
    let $template-node-value := $template-node//sade:param[xs:string(@key)=$key]
    let $config-value := ($config//sade:property[xs:string(@key)=$key]|$config//property[xs:string(@key)=$key])
    return if (not($request-value = "") and $request-flag) then $request-value  
        else if (exists($template-node-value)) then $template-node-value/text()
        else if (exists($config-value)) then $config-value/text()
        else $default
};

declare function sade:param-value($key as xs:string, $template-node as node()*, $config as node(), $default) as item()*  {
    sade:param-value($key, $template-node, $config, $default, true())
};

(:~ get a html-snippet from the template/snippets-file based on the $key-param matching the @id of the element in the file 
:)
declare function sade:get-snippet($config as node(), $key as xs:string) as item()* {
    let $snippets-path := concat(sade:config-value($config, 'template.dir'), 'snippets.xml')
    (: this is fetched, so that the variable can be used in the snippets :)
    let $webscripts-prefix := sade:config-value($config, 'webscripts.prefix')
    let $snippets-doc := doc($snippets-path)
    let $snippet := $snippets-doc//*[@id=$key]
    (: util:serialize is to allow dynamic content in the snippets to be easily resolved (by util:eval) :)        
    return if (exists($snippet)) then util:eval(util:serialize($snippet, ())) else ()     
};
