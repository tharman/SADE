module namespace viewer = "http://sade/viewer" ;
declare namespace sade = "http://sade" ;

declare variable $viewer:jquerybase := "/digitallibrary/jquery";

declare function viewer:process-template($template-node as node(), $config as node()) as item()* {
    
    let $item := request:get-parameter("viewer.item", "")
    let $format := request:get-parameter("viewer.format", "")
    
    
    return
        <div id="viewer"> {
            if(starts-with($format, "image/"))
                then
                <div id="digilib1" class="digilib">
                    <img src="http://localhost:8080/digitallibrary/servlet/Scaler?dw=400&amp;dh=400&amp;fn={$item}" />
                </div>
            else if(starts-with($format, "text/xml"))
                then
                    viewer:xslt($config, $item)
            else
                <strong>viewer here</strong>
        }
        </div>
    
};

declare function viewer:xslt($config as node(), $docname as xs:string) as item()* {

    let $doc := doc(concat($config//sade:data/@path, '/' ,$docname ))
    let $xsl := doc($config//sade:viewer/@xslt)
    
    let $html := transform:transform($doc, $xsl, <parameters/>)
    return $html
};

declare function viewer:header($config as node()) as item()* {
    let $header := <header>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.cookie.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.geometry.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.buttons.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.birdseye.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.regions.js"></script>
                        <script type="text/javascript" src="{$viewer:jquerybase}/jquery.digilib.pluginstub.js"></script>
                        <link rel="stylesheet" type="text/css" href="{$viewer:jquerybase}/jquery.digilib.css" />
                        
                        <script type="text/javascript" src="{$sade:baseurl}modules/viewer/digilib.embed.js" />
                        
                    </header>
    

    return $header/*
};

