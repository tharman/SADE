module namespace navi = "http://sade/navigation" ;

declare namespace sade = "http://sade";

(: create a navigation :)
declare function navi:create($projectname as xs:string, $uri as xs:string, $container as xs:string) as node(){
    let $conf := doc(concat("/db/sade/projects/", $projectname, "/config.xml"))
    let $base-path := $conf//sade:base-path
    let $naviconf := $conf//sade:container[@ref = $container]/sade:module[@ref = 'navigation']/sade:param[@name = 'navi-content']
    let $dir := $naviconf//sade:navigation/@dir
    let $style := $naviconf//sade:navigation/@style
    (: go through the levels :)
    let $nav := <ul class="nav nav-{if ($style = "pills") then data($style) else "tabs"} {if ($dir = "vertical") then "nav-stacked" else ()}">
                  {navi:createLevel($naviconf//sade:navigation/sade:list/sade:item, $uri)}
                </ul>
    return $nav
        
};

declare function navi:createLevel($navi as node(), $uri as xs:string) as node()+{
    for $item in $navi
    let $link := $item/data(@link)
    let $path := tokenize($uri, "/")
    let $last := $path[last()]
    let $active := if ($link = $last) then "active" else ()
    order by $item/@n ascending
    return
        (: dropdown or simple entry :)
        if ($item/sade:list)
        then <li class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                    {data($item/@label)}
                    <b class="caret"></b>
                </a>
                <ul class="dropdown-menu">
                    {navi:createLevel($item/sade:list/sade:item, $uri)}
                </ul>
             </li>
        else <li>
                {if ($active) then attribute class {$active} else ()}
                <a href="{if ($item/@link) then $item/@link else '#'}">{data($item/@label)}</a>
             </li>
};

(: create a breadcrumb :)
declare function navi:create-breadcrumb($projectname as xs:string, $uri as xs:string) as node(){
    let $conf := doc(concat("/db/sade/projects/", $projectname, "/config.xml"))
    let $base-path := $conf//sade:base-path
    let $path := substring-after($uri, concat($base-path, "/"))
    let $steps := tokenize($path, "/")
    let $numSteps := count($steps)
    return
    <ul class="breadcrumb">
        <li><a href="#">Home</a> <span class="divider">/</span></li>
        {
            for $step at $pos in $steps
            let $active := if ($pos = $numSteps) then "active" else ()
            return <li>
                    {if ($active) then attribute class {$active} else()} 
                     <a href="#">{$step}</a> {if ($pos != $numSteps) then <span class="divider"></span> else ()}
                   </li>
            
        }
    </ul>
};


