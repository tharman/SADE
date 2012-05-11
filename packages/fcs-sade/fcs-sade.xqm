xquery version "1.0";
(:~ this module bridges to the cr-xq/fcs.xqm module 

@see https://github.com/vronk/corpus_shell/tree/master/fcs/wrapper/cr-xq
:)


module namespace fcsm = "http://clarin.eu/fcs/1.0/sade-module";

import module namespace request="http://exist-db.org/xquery/request";

import module namespace sade =  "http://sade" at "/db/sade/core/main.xqm";
import module namespace fcs  = "http://clarin.eu/fcs/1.0" at "/db/cr/fcs.xqm";
(:import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "../../core/modules/diagnostics/diagnostics.xqm";:)
import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///db/sade/core/modules/diagnostics/diagnostics.xqm";
import module namespace repo-utils =  "http://aac.ac.at/content_repository/utils" at  "/db/cr/repo-utils.xqm";

(:~ main call-back function invoked by the template-processing script
it mimiques the main-function of fcs-module, 
but reads the parameters also from config and template, not just from the http-request.

TODO: checks some special parameters, to decide if the request-parameters apply to given template-node, 
and if to show at all given template-node under given parameters
this is not module specific, so needs to be moved into the generic logic 
:)
declare function fcsm:process-template($template-node as node(), $config as node()) as item()* {
     
     let $q := sade:param-value("q", $template-node, $config, ""),
     $query := sade:param-value("query", $template-node, $config, $q),    
        (: if query-parameter not present, NO DEFAULT operation, otherwise 'searchRetrieve'         :)
    $operation := if ($query eq "") then sade:param-value("operation", $template-node, $config, "", true())
                        else sade:param-value("operation", $template-node, $config, $fcs:searchRetrieve , false()),
    
    $current-template := request:get-parameter("current-template", ""),
    (: check if this is the template, the parameters apply to 
    or if no current-template-parameter assume search as default view:)
    $is-current := ($current-template = $template-node/xs:string(@id) or ($current-template="" and $operation = $fcs:searchRetrieve )),

    $scanClause := sade:param-value("scanClause", $template-node, $config, "")

let $not-accepts := sade:param-value("not-accepts", $template-node, $config, "")
let $show := util:eval('sade:param-value($not-accepts,$template-node, $config, "") eq ""')

     return if ($show) then
                    if ($operation eq sade:param-value("accepts.operation", $template-node, $config, "")) then
(:                //if ($view eq $template-node/xs:string(@id)) then :)
                     (:and starts-with ($scanClause, sade:param-value("accepts.scanClause", $template-node, $config, ""))):)           
                   fcsm:process-specific($template-node, $config, $is-current)
                    else ()
               else ()
       
}; 
     
(:~
@param $is-current flag: true, if current node is the one the request-params apply to (determined by view-parameter)
                   in that case, the request-parameters are regarded, otherwise the defaults are used. 
:)     
 declare function fcsm:process-specific($template-node as node(), $config as node(), $is-current as xs:string) as item()* {
 
 
 (: accept "q" as synonym to query-param; "query" overrides:)
    let $q := sade:param-value("q", $template-node, $config, "", $is-current),
    $query := sade:param-value("query", $template-node, $config, $q, $is-current),    
        (: if query-parameter not present, 'explain' as DEFAULT operation, otherwise 'searchRetrieve' :)
    $operation :=  if ($query eq "") then sade:param-value("operation", $template-node, $config, $fcs:explain, $is-current)
                    else sade:param-value("operation", $template-node, $config, $fcs:searchRetrieve, $is-current),
    $x-format := sade:param-value("x-format", $template-node, $config, $repo-utils:responseFormatHTML, $is-current),
    $x-context := sade:param-value("x-context", $template-node, $config, "", $is-current),
    (:
    $query-collections := 
    if (matches($collection-params, "^root$") or $collection-params eq "") then 
      $cr:collectionRoot
    else
		tokenize($collection-params,','),
        :)
(:      $collection-params, :)
  $max-depth as xs:integer := xs:integer(sade:param-value("maxdepth", $template-node, $config, 1,$is-current))

  let $result :=
      (: if ($operation eq $cr:getCollections) then
		cr:get-collections($query-collections, $format, $max-depth)
      else :)
      if ($operation eq $fcs:explain) then
          fcs:explain($x-context, $config)		
      else if ($operation eq $fcs:scan) then
(:		let $scanClause := sade:param-value("scanClause", $template-node, $config, ""),:)
      let $index := sade:param-value("index", $template-node, $config, "",$is-current),
          $scanClause-param := sade:param-value("scanClause", $template-node, $config, "",$is-current),
		$scanClause := if ($index ne '' and  not(starts-with($scanClause-param, $index)) ) then 
		                     concat( $index, '=', $scanClause-param)
		                  else
		                     $scanClause-param,

		$start-term := sade:param-value("startTerm", $template-node, $config, 1,$is-current),
		$response-position := sade:param-value("responsePosition", $template-node, $config, 1,$is-current),
		$max-terms := sade:param-value("maximumTerms", $template-node, $config, 50,$is-current),
	    $max-depth := sade:param-value("x-maximumDepth", $template-node, $config, 1,$is-current),
		$sort := sade:param-value("sort", $template-node, $config, 'text',$is-current)
		 return fcs:scan($scanClause, $x-context, $start-term, $max-terms, $response-position, $max-depth, $sort, $config) 
        (: return fcs:scan($scanClause, $x-context) :)
	  else if ($operation eq $fcs:searchRetrieve) then
        if ($query eq "") then diag:diagnostics("param-missing", "query")
        else 
      	 let $cql-query := $query,
			$start-item := sade:param-value("startRecord", $template-node, $config, 1,$is-current),
			$max-items := sade:param-value("maximumRecords", $template-node, $config, 50,$is-current),	
			$x-dataview := sade:param-value("x-dataview", $template-node, $config, repo-utils:config-value($config, 'default.dataview'),$is-current)
            (: return cr:search-retrieve($cql-query, $query-collections, $format, xs:integer($start-item), xs:integer($max-items)) :)
            return fcs:search-retrieve($cql-query, $x-context, xs:integer($start-item), xs:integer($max-items), $x-dataview, $config)
    else 
      diag:diagnostics("unsupported-operation", $operation)
     
     let $current-template := sade:param-value("current-template", $template-node, $config, "", false())
   return  repo-utils:serialise-as($result, $x-format, $operation, $config,
            <parameters>
                <param name="current-template" value="{$current-template}"/>
             </parameters>
             )
(:return $template-node:)

};


declare function fcsm:header($config as node()) as item()* {
    ()
};