xquery version "3.0";

import module namespace config="http://exist-db.org/xquery/apps/config" at "../../core/config.xqm";
import module namespace fcsm = "http://clarin.eu/fcs/1.0" at "/db/cr/fcs.xqm";


let $project := request:get-parameter("project","")
let $config := config:config($project) 
					
return fcsm:repo($config)					

