var windowID = 0;

var bindEvents = function(scope){
    $("#newWindow").click(function(){
        loadContent();
    });
    
    /*
     $("#homeLink").click(function(){
     location.reload();
     });
     */
    $("#searchButton").click(function(){
        $("#searchResults").load("/exist/rest/db/telota/xquery/search.xql", {
            query: $("#tags").val()
        }, function(){
            $(".docLink").click(function(scope){
                loadContent($(this).attr("href"), $(this).attr("name"));
                return false;
            });
        });
    });
    
    $("a.examples", scope).click(function(){
        $("#desk").load(this.href, {}, function(){
            SyntaxHighlighter.highlight();
            //bindEvents();
        });
        return false;
    });
    
    $("a.browseIndexLink").click(function(){
        $("#desk").load($(this).attr("href"), {}, function(){
            $(".docLink").click(function(scope){
                loadContent($(this).attr("href"));
                return false;
            });
        });
        return false;
    });
    
    $("#indexButton").click(function(){
        $("#indexTabDiv").load("/exist/rest/db/telota/xquery/getIndex.xql", {
            'xpath': $("#indexXpath").val()
        }, function(){
            $(".docLink").click(function(scope){
                loadContent($(this).attr("href"));
                return false;
            });
        })
    });
    
    

    var options = {
        //target: '#uploadform',
        url: '/exist/rest/db/telota/xquery/uploadDocuments.xql',
        success: function(){
            //alert("ping: "+responseText);
			loadUserXML();
			loadDocumentsAndIndexes();
        }
    };

    $("#uploadform").ajaxForm(options);
 /*
   $("#uploadform").ajaxForm(function(options){
        alert("done: " + responseText);
		loadUserXML();
    });
*/
    
}


$(document).ready(function(){
    $('body').layout({
        applyDefaultStyles: false,
        resizable: true,
        slidable: true,
        spacing_open: 3,
        togglerLength_open: 20,
        fxName: "slide",
        fxSpeed: "slow",
        east__size: "300",
        west__size: "200",
        west__onopen: function(){
            showAccordion();
        }
    });
    

    loadUserXML();
    showAccordion();
    $("#tabs").tabs().find(".ui-tabs-nav").sortable({
        axis: 'x'
    });
    $("#tags").autocomplete({
        source: "/exist/rest/db/telota/xquery/index.xql"
    });
    
    bindEvents();
    
    loadDocumentsAndIndexes();

    
    
});

function showAccordion(){
    $("#accordion").accordion({
        header: "h3",
        collapsible: true,
        autoHeight: false
    });
}

function loadDocumentsAndIndexes(){
    $("#documentsDiv").load("/exist/rest/db/telota/xquery/loadDocumentsTOC.xql", {}, function(){
        $(".docLink").click(function(scope){
            loadContent($(this).attr("href"));
            return false;
        });
    });
}

function loadContent(xml, qString){
    var url = "/exist/rest/db/telota/xquery/loadContent.xql";
    var userXML = $('#xmlFiles :selected').text();
    var xslt = $('#xsltFiles :selected').text();
    var css = $('#cssFiles :selected').text();
    
    if (xml == undefined) {
        xml = "/db/user/xml/" + userXML;
    }
    
    if (qString == undefined) {
        qString = "";
    }
    
    if (xslt == "" || xslt == "TEI P5 - XHTML") {
        xslt = "/db/tei/xhtml2/tei.xsl";
    }
    else {
        xslt = "/db/user/xslt/" + xslt;
    }
    
    if ($("#radio1:checked").val() == "newWindow") {
        windowID++;
        $('<div id="window' + windowID + '"></div>').window({
            dock: 'dock',
            width: 600,
            title: xml + ' - ' + xslt
        });
        
        //        $("#window" + windowID).load(url, {
        //            xml: xml,
        //            xslt: xslt
        //        });
        $.ajax({
            url: url,
            data: {
                xml: xml,
                xslt: xslt,
                qString: qString
            },
            success: function(response, status, xhr){
                var ct = xhr.getResponseHeader("content-type");
                //                alert(ct);
                if (ct == "application/pdf") {
                    url2 = url + "?xml=" + xml + "&xslt=" + xslt;
                    //$("#desk").html('<object type="application/pdf" data="'+url2+'" width="500" height="650" ></object>');
                    $("#window" + windowID).html('<embed src="' + url2 + '" width="99%" height="99%">');
                }
                else {
                    $("#window" + windowID).html(response);
                    applyCSS(css);
                }
            }
        });
    }
    else {
        $.ajax({
            url: url,
            data: {
                xml: xml,
                xslt: xslt,
                qString: qString
            },
            success: function(response, status, xhr){
                var ct = xhr.getResponseHeader("content-type");
                //                alert(ct);
                if (ct == "application/pdf") {
                    url2 = url + "?xml=" + xml + "&xslt=" + xslt;
                    //$("#desk").html('<object type="application/pdf" data="'+url2+'" width="500" height="650" ></object>');
                    $("#desk").html('<embed src="' + url2 + '" width="99%" height="99%">');
                }
                else {
					//alert(response);
                    $("#desk").html(response);
                    applyCSS(css);
                }
            }
        });
    }
    
    
}

function loadUserXML(){
    var url = "/exist/rest/db/telota/xquery/loadUserXML.xql";
    $("#xmlFiles").load(url, {
        type: "xml"
    });
    $("#xsltFiles").load(url, {
        type: "xslt"
    }, function(){
        /*
$("#xsltFiles option:first-child").before("<option>TEI P5 - XHTML</option>")
        $("#xsltFiles option:first-child").select();
*/
    });
    $("#cssFiles").load(url, {
        type: "css"
    }, function(){
        // TODO Standard-CSS laden?
    });
    /*
    
    
     
    
    
     
    
    
     $.ajax({
    
    
     
    
    
     
    
    
     url: "/css",
    
    
     
    
    
     
    
    
     success: function(response, status, xhr){
    
    
     
    
    
     
    
    
     var o = "";
    
    
     
    
    
     
    
    
     $(response).find('a[href$=".css"]').each(function(index){
    
    
     
    
    
     
    
    
     o = o + "<option>" + $(this).text() + "</option>";
    
    
     
    
    
     
    
    
     });
    
    
     
    
    
     
    
    
     $("#cssFiles").html(o);
    
    
     
    
    
     
    
    
     }
    
    
     
    
    
     
    
    
     });
    
    
     
    
    
     
    
    
     */
    
    
}


function applyCSS(url){
    $("link#userCSS").remove();
    $("head").append('<link id="userCSS" type="text/css" href="/exist/rest/db/user/css/' + url.trim() + '" rel="stylesheet" />');
}


