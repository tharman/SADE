xquery version "3.0";

import module namespace docs="http://exist-db.org/xquery/docs" at "scan.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

declare option exist:serialize "method=json media-type=application/javascript";

let $isDba := xmldb:is-admin-user(xmldb:get-current-user())
return
    if ($isDba) then
        <response status="ok">
            <message>Scan completed! {docs:load-fundocs($config:app-root)}</message>
        </response>
    else
        <response status="failed">
            <message>You have to be a member of the dba group. Please log in using the dashboard and retry.</message>
        </response>