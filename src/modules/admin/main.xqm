module namespace admin = "http://sade/admin" ;
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sade = "http://bbaw.de/sade";             

declare function admin:main($configfile as xs:anyURI) as item()* {

let $conf := doc($configfile)/sade:SADE_project

let $fluid :=  if ($conf/sade:design/sade:fluid[contains(., 'true')]) 
                then ('-fluid')
                else ()

return
<html>
    <head>
        <!-- TODO title jeder Seite beim Zusammenbauen aus der conf auslesen -->
        <title>{$conf/sade:meta/sade:project_name/text()}</title>
        <!-- TODO Die folgenden Zeilen im Header in ein Standardmodul auslagern,
             das die Seiten zusammenbaut und bei der Gelegenheit die benötigten
             Komponenten einfügt! -->
        <link rel="stylesheet/less" type="text/css" href="/exist/rest/db/sade/modules/admin/kickstrap/kickstrap.less"/>
        <link rel="stylesheet" type="text/css" href="static/sade.css" />
        <script src="/exist/rest/db/sade/modules/admin/kickstrap/Kickstrap/js/less-1.3.0.min.js"> </script>
    </head>
    <body>
         <!--TODO Layout aus der conf auslesen -->
         <div class="container{$fluid}">
            <div class="row{$fluid}" id="header">
                <div class="span12 offset0">
                    <h1>{$conf/sade:meta/sade:project_name/text()}</h1>
                </div>
            </div>
            <div class="row{$fluid}" id="navigation">
                <div class="span12 offset0">
                    <div class="navbar ">
                        <div class="navbar-inner">
                            <div class="container-fluid">
                                <ul class="nav">
                                    <li class="active">
                                        <a href="index.xql">Home</a>
                                    </li>
                                    <li class="">
                                        <a href="edition.xql">Digitale Edition</a>
                                    </li>
                                    <li class="disabled">
                                        <a href="#">Help</a>
                                    </li>
                                </ul>
                            <!--<form class="navbar-search pull-right">
                                <input type="text" class="search-query" placeholder="Search"/>
                            </form>-->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row{$fluid}">
                <div class="span8 offset0">
                  <div class="hero-unit">
                    <h1>AvH Briefedition</h1>
                        <p>The Scalable Architecture for Digital Editions (SADE) gives you the opprtunity to
                            set up your own project within minutes!
                        </p>
                        <p>
                            <a class="btn btn-primary btn-large" href="admin/dashboard.xql">
                            Get started!
                            </a>
                        </p>
                  </div>
                </div>
            </div> 
            <div class="row{$fluid}" id="footer">
                <div class="container{$fluid}">
                    <p><a href="{$conf/sade:design/sade:footer/sade:url}"><img style="height: 100px" src="{$conf/sade:design/sade:footer/sade:img/replace(., '%5C', '/')}" /></a></p>
                </div>
            </div>
            <script src="admin/kickstrap/Kickstrap/js/jquery-1.7.1.min.js"> </script>
            <script src="admin/kickstrap/Kickstrap/js/kickstrap.min.js"> </script>
        </div>
    </body>
</html>

};