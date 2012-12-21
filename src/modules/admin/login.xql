xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=html5 media-type=text/html";

(: Für das Login und Logout :)
let $_user := request:get-parameter("user",())
let $_pass := request:get-parameter("pass",())

let $loggedIn := if (session:exists())
                 then (true())
                 else (
                    if ($_user and $_pass)
                    then (
                       session:set-max-inactive-interval(28800),
                       xmldb:login('/db/admin', $_user, $_pass, true())
                    )
                    else (false())
                 )

let $url := if ($loggedIn) 
            then concat('/exist/rest/db/sade/modules/admin/dashboard.xql', '?=', session:get-id())
            else ()

return
if ($loggedIn) 
then (response:redirect-to($url))
else (
<html>
    <head>
        <title>Login: SADE-Administration</title>
    </head>
    <body>
        <h1>Login: SADE-Administration</h1>
        <form action="login.xql">
            <label for="user">Benutzername</label>
            <input name="user" />
            <label for="pass">Passwort</label>
            <input name="pass" />
            <input type="submit" value="Login"/>
        </form>
    </body>
</html>
)