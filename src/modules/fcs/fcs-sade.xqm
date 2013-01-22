xquery version "3.0";

module namespace fcs="http://sade/fcs";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic"
    at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace fcsm = "http://clarin.eu/fcs/1.0" at "/db/cr/fcs.xqm";
import module namespace repo-utils = "http://aac.ac.at/content_repository/utils" at  "/db/cr/repo-utils.xqm";

declare namespace cmd = "http://www.clarin.eu/cmd/";

(:declare variable $app:SESSION := "shakespeare:results";:)
(:declare variable $fcs:config := repo-utils:config("/db/cr/conf/mdrepo/config.xml");:)

(:~
 : Execute a query and pass the result to nested template functions. This function returns
 : a map, not a node. The templating module recognizes this and will merge the map into
 : the current model, then continue processing any children of $node.
 :
 : The annotation %templates:wrap indicates that the current element (in $node) should be preserved.
 : The templating module copies the current element and its attributes, before processing
 : its children.
 :)
declare 
    %templates:wrap
    %templates:default("x-context","")
    %templates:default("x-dataview","kwic")
    %templates:default("x-format","html")
function fcs:query($node as node()*, $model as map(*), $query as xs:string?, $x-context as xs:string*, $x-dataview as xs:string*, $x-format as xs:string?, $base-path as xs:string?) {
    session:create(),
(:    let $hits := app:do-query($query, $mode):)       
(:    let $store := session:set-attribute($app:SESSION, $hits):)
    
    let $result := 
(:       fcs:search-retrieve($query, $x-context, xs:integer($start-item), xs:integer($max-items), $x-dataview, $config):)
       fcsm:search-retrieve($query, $x-context, 1, 10, $x-dataview, $model("config"))
    let $params := <parameters><param name="format" value="{$x-format}"/>
                  			         <param name="base_url" value="{$base-path}"/>
              			            <param name="x-context" value="{$x-context}"/>              			            
              			            <param name="x-dataview" value="{$x-dataview}"/>
                  </parameters>
                  (:<param name="base_url" value="{repo-utils:base-url($config)}"/>:)
                  
     return  repo-utils:serialise-as($result, $x-format, 'searchRetrieve', $model("config"), $params)
     
};


declare 
    %templates:wrap
    %templates:default("x-context","")
    %templates:default("x-format","html")
    %templates:default("start-term",1)
    %templates:default("max-terms",50)
    %templates:default("sort","size")
function fcs:scan($node as node()*, $model as map(*), $scanClause as xs:string, $start-term as xs:integer, $max-terms as xs:integer,  $sort as xs:string, 
$x-context as xs:string*, $x-format as xs:string?, $base-path as xs:string?) {
    
    let $result :=
            fcsm:scan($scanClause, $x-context, $start-term, $max-terms, 1, 1, $sort, $model("config"))
    
    let $params := <parameters><param name="format" value="{$x-format}"/>
                  			         <param name="base_url" value="{$base-path}"/>
              			            <param name="x-context" value="{$x-context}"/>             			            
    
                  </parameters>
     return  repo-utils:serialise-as($result, $x-format, 'scan', $model("config"), $params)
     
};



(:~ return number of documents in the data.path collection
:)
declare function fcs:count-records($node as node(), $model as map(*)) {

       let $data-path := repo-utils:config-value($model("config"),"data.path")
       return count(collection($data-path)/(cmd:CMD|CMD))
    
};

(:
declare function app:status($node as node(), $model as map(*)) {

let $count-records := app:count-records($node, $model)
       
let $logs := collection("/db/mdrepo-data/logs")/log

let $dataset_status := for $dataset in  distinct-values ($logs/xs:string(@dataset))
    let $last-updated := max ($logs[xs:string(@dataset)=$dataset]/xs:dateTime(translate(@start-time,' ','T')))
    let $count-files := $logs[xs:string(@dataset)=$dataset][xs:dateTime(translate(@start-time,' ','T'))=$last-updated]/xs:string(@count-files)
   return <dataset key="{$dataset}" last-updated="{$last-updated}" count-files="{$count-files}" />
   
   return 
        <div>
            <h3>Status</h3>        
        <table class="bordered" >
        <thead><tr><th>dataset</th><th>count records</th><th>last updated</th></tr></thead>
        {        
        for $dataset in $dataset_status
            return <tr><td>{$dataset/xs:string(@key)}</td><td class="number">{$dataset/xs:string(@count-files)}</td><td>{$dataset/xs:string(@last-updated)}</td>
                    </tr>
                  }
        <tr><td>total records</td><td class="number"><b>{$count-records}</b></td><td></td></tr>
        </table>
        </div>
    
};
:)