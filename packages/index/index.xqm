module namespace index = "http://sade/index" ;

import module namespace diag =  "http://www.loc.gov/zing/srw/diagnostic/" at  "xmldb:exist:///db/sade/core/modules/diagnostics/diagnostics.xqm";

declare namespace sade = "http://sade" ;
declare variable $index:transform := doc('/db/sade/modules/index/index2view.xsl');


declare function index:process-template($template-node as node(), $config as node()) as item()* {
    
    let $index := doc(xs:string($config//sade:index/@path))
    let $result :=if ($index) then 
            transform:transform($index,$index:transform, 
            <parameters><param name="format" value="treetable"/>									
			</parameters>)
             else 
                diag:diagnostics("unsupported-param-value", concat("index=", xs:string($config//sade:index/@path)))                
              
    return
      <div><h2>Index</h2>
        { $result }  
      </div>
};


declare function index:header($config as node()) as item()* {
    
    let $header := <header>
                <link href="{$sade:baseurl}modules/index/style/treetable/jquery.treeTable.css" rel="stylesheet" type="text/css" ></link>,
                <script src="{$sade:baseurl}modules/index/scripts/jquery-treeTable/jquery.treeTable.js" type="text/javascript"></script>
               <script type="text/javascript">
                		$(function(){{
                		      console.log("calling treetable2");
                			$("#index-treetable").treeTable();
                		}});
                </script>                
                </header>
    return $header/*
};