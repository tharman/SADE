

import module namespace docs="http://exist-db.org/xquery/docs" at "/db/apps/sade/modules/gendocs/scan.xql";



return docs:load-fundocs("/db/apps/sade", "/db/apps/sade/modules/gendocs")
