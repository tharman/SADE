xquery version "1.0";
module namespace diag  = "http://www.loc.gov/zing/srw/diagnostic/";


(:declare variable $diag:msgs := doc('/db/sade/core/modules/diagnostics/diagnostics.xml');:)
declare variable $diag:msgs := doc('diagnostics.xml');

declare function diag:diagnostics($key as xs:string, $param as xs:string) as item()? {
    
    let $diag := 
	       if (exists($diag:msgs//diag:diagnostic[@key=$key])) then
	               $diag:msgs//diag:diagnostic[@key=$key]
	           else $diag:msgs//diag:diagnostic[@key='general-error']
	   return
	       <diagnostics>
	           { util:eval(util:serialize($diag,())) }
	       </diagnostics>	   
};