xquery version "1.0";

(: pre install.xql generated from exide, installs collection.xconf :)

import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;


declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: create target in /system/config :)
local:mkcol("/db/system/config", $target),

(: store all xconf files from packages /sysconf recursive to system configuration path, create subdirs :)
xdb:store-files-from-pattern(concat("/system/config", $target), concat($dir, "/sysconf"), "**/*.xconf", "text/xml", true()) 

