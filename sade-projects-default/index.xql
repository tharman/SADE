import module namespace admin = "http://sade/admin" at "/db/sade/modules/admin/main.xqm";
declare namespace sade = "http://bbaw.de/sade";             
declare option exist:serialize "method=html5 media-type=text/html";

let $configfile := document-uri(doc('static/config.xml'))

return
admin:main($configfile)