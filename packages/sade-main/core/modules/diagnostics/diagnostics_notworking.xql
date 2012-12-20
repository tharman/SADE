xquery version "1.0";
declare namespace diag  = "http://www.loc.gov/zing/srw/diagnostic/";

let $diag:msgs := doc('/db/sade/modules/diagnostics/diagnostics.xml')

(: parameter resolution works when local XML, but not when fetched from file. ! :)

let $key  :="general-error"
let $param :="param-resolved"
let $s := <diagnostic xmlns="http://www.loc.gov/zing/srw/diagnostic/" key="unsupported-operation">
        <uri>info:srw/diagnostic/1/4</uri>
        <message>Unsupported operation</message>
        <details>{$param}</details>
    </diagnostic>

let $diag := $diag:msgs//diag:diagnostic[@key=$key]
return (util:eval("$s"), util:eval("$diag",false()))
(: tried to add the param explictely - no help
util:eval("$diag",false(), (xs:QName("param"), $param)) :)