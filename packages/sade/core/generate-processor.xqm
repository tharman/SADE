module namespace gen =  "http://sade/gen";

declare namespace sade = "http://sade";

declare variable $gen:cr := "&#13;";
declare variable $gen:modulename := "http://sade";
declare variable $gen:module-collection := "xmldb:exist:///db/sade/modules/";
 
declare function gen:generate-processor($config as element() ) as item()* {

let $modules := $config//sade:module

let $result :=
    <processor-code>
module namespace sp = "{$gen:modulename}/processing"; 
 declare namespace sade = "{$gen:modulename}";
   
  (: generate list of imported modules, module-name as namespace-prefix :)  
{ for $m in $modules 
    let $modulename := $m/@name
    let $namespace := $m/@ns  
  return concat("import module namespace ", $modulename, '= "', $namespace, '" at "', $gen:module-collection, $modulename, '/', $modulename , '.xqm";
  ')    
}     

(: dynamic processing of templates generated from the list of modules :)
declare function sp:process-template($template-node as node(), $config as node()) as item()* {{ {$gen:cr}

    let $div-id := xs:string($template-node/@id)
    (: look for a module to be positioned in this template-block :) 
    let $module := $config//sade:modules/sade:module[@position=$div-id]
    let $module-name := xs:string($module/@name)
    (: preserve the template-node together with its attributes 
        and put the processed content of module inside the template-node :)
    let $result := element {{$template-node/name()}} {{ ($template-node/@* , 
      { for $m in $modules
            let $modulename := $m/@name
        return concat("if ($module-name eq '", $modulename, "') then ", $modulename, ":process-template($module, $config) 
else " )
      } sade:process($template-node/node(), $config) 
            ) }}
      (: 
      switch ($template-name) {
       for $m in $modules
        let $modulename := $m/modulename/text()         
        return 
           ("case '", $modulename, "' return ", $modulename, ":process-template($template-node)
") } default return 
         sade:process-default($template-node)
      :)     
    
    return $result
    
  }};
</processor-code>

return $result/text()
};

