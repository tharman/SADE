/**
 * @class QueryInput
 * generate a customizable query_input UI, a input form with fields/widgets based on settings
 * options: multiple params/fields, 
 * indexes, different widgets
 *
 * dependencies: jQuery, jquery-ui: slider, autocomplete
 
 * @author vronk, Andy Basch
 * @version 2013-01-17
 */


/* we could make it a class (instead of jQuery plugin)
       function QueryInput(elem,s) */ 
       
// jQuery closure 
(function($) {

$.fn.QueryInput = function (options)
{
   /** the dom-element to generate the query input in */
   var elem=this;
    
    /** main variable holding all the settings for qi, especially also all params and their allowed values, and their current value
      * it is constructed here by merging the default and the user options passed as parameter to .QueryInput()
      */
   var settings = $.extend(true, {}, defaults, options);
    blendInParams(settings.params, getUrlParams(location.search))  
  
   // makes the settings publicly available as .data("qi")
   elem.data("qi",settings); 
   init(settings);   

  function init(s) {
    //empty the target element - TODO:optional
    elem.html('');
    generateWidgets(s.params, elem);
  }
    
  /** run through the params and generate the widget for every param */
  function generateWidgets (params, trg_container) {
        
        $(trg_container).append("<form />");
        var form = $(trg_container).find("form");
        
     //   var inputs = {};
        
      for ( var key in params ) {
         var param = params[key];
        // if input already exists - fill it with the default value
        if ($('#' + settings.input_prefix + key).length) {
            $('#' + settings.input_prefix + key).value = param.value;   
         } else if (trg_container)  {
            var label= param.label ? param.label : key;
            var new_input_label = param.label=='' ? '' : "<label>" + label+ "</label>";
            var new_input, new_widget=null;
            
            switch (param.widget) {
                case "text":
                  new_input = genText(key, param);    
                  break;
                case "submit":
                  new_input = genSubmit (key, param);    
                  break;
                case "selectone":
                  new_input = genCombo(key, param);    
                  break;
                case "autocomplete":
                  new_input = genAutocomplete (key, param);    
                  break;
                case "slider":
                 [new_input,new_widget] = genSlider(key, param);    
                  break;
                default:
                  console.log("no such widget: " + param.widget); 
              }    
                  
         // set initial value
         $(new_input).val(param.value)
                     .data("key", key)
                     .attr("id", settings.input_prefix + key)
                     .data("param-object", param);
             
        /* update settings and widgets upon value-change */
        new_input.change(function () {
                   setParamValue(this);
             });
                   
            $(form).append(new_input_label, new_input, new_widget);
           // inputs.push(key, new_input_label, new_input, new_widget]);
            
         }
       }   
    }
/*
    function formatForm(inputs) {
      for ( var key in inputs ) {
      
      }
        <table>
        </table>
    }
*/
    function genText(key, param_settings) {
         
        var input = $("<input />");
         $(input).attr("name",key);
         
        return input;
    }
    
    function genSubmit(key, param_settings) {
         
        var input = $("<input type='submit'/>");
         $(input).attr("name",key);
         $(input).attr("value",param_settings.label);
        return input;
    }
        
    /** generating out own comboboxes, because very annoying trying to use some of existing jquery plugins (easyui.combo, combobox, jquery-ui.autocomplete) */ 
    function genCombo (key, param_settings) {
    
        var select = $("<select id='widget-" + key + "' />")
            select.attr("id", settings.input_prefix + key)
        param_settings.values.forEach(function(v) { $(select).append("<option value='" + v +"' >" + v + "</option>") });
        return select;
    }

    /** generate autocomplete */ 
    function genAutocomplete (key, param_settings) {
        
        var input = $("<input />");
         $(input).attr("name",key)
        
        if (param_settings.static_source) {
              //var scanURL = settings.fcs_source +  param_settings.index
              var scanURL = param_settings.static_source.replace('&amp;','&','g');
              // if static source - try to retrieve the data 
              $.getJSON(scanURL, function(data) {
                    param_settings.source = data.terms
                    $(input).autocomplete(param_settings);
                  //  console.log($(input).autocomplete("option","source").length);
              });
        
             //param_settings.source = fcsScan;
        } else {
            $(input).autocomplete(param_settings);
        }
         
        return input;
    }

    function fcsScan(request, response) {
        response( $.ui.autocomplete.filter(
                          scan.terms, request.term ) );
  					// extractLast( request.term )
    }
         
    /** generate a slider based on settings
        @returns an array of two elements: actual input-element with value and a div-container for the slider widget
    */
    function genSlider (key, param_settings) {

        var new_input = $("<input />");
            new_input.attr("id", settings.input_prefix + key)
                 .val(param_settings.value)
                 .attr("size", 3);
      
        var new_widget = $("<div class='widget-" + param_settings.widget + "'></div>")
                         .attr("id", "widget-" + key)
                         .css(settings.slider_style)
                         .slider( param_settings)
                
                        // set both-ways references between the input-field and its slider - necessary for updating 
                        .data("related-input-field",new_input)
                        .data("related-widget",new_widget);
                     
            new_widget.bind( "slidechange", function(event, ui) {
                $(this).data("related-input-field").val(ui.value);
                // update the settings-object, but with the (updated) value of the related input-field
                setParamValue($(this).data("related-input-field"));
            });
            
            /* update the widget upon input value-change (updating the settings-value is handled in the general part */
            new_input.bind("change", function () {
                   var related_widget = $(this).data("related-widget");
                   if ( $(related_widget).hasClass("widget-slider")) {$(related_widget).slider("option", "value", $(this).val()); }
             });
             
           return [new_input,new_widget]; 
    } 
    
    
    /** gets the current value for a parameter
        accepting settings as reliable source of current value
        i.e. changes in input have to change the .value in settings.
        This is assured by calling setParamValue upon input-change.
        @public by calling: $(elem).data("qi").getParamValue(param_key);
    */
    settings.getParamValue = function(key) {
         if (this.params[key])  {
            return this.params[key].value
         } else {
            return ""
         }
    }

    /** update the current value in settings */
    function setParamValue(input_object) {
        var param_object = $(input_object).data("param-object");
        param_object.value= $(input_object).val();
        var key = $(input_object).data("key");
        var value = settings.params[key].value;
       
        // callback:
        settings.onValueChanged.call( input_object,value );
        return value    
    }

    
    /** get params from the uri */
    function getUrlParams(url)
    {
      var urlParams = {};
      if (url != undefined)
      {
        var match;
        var pl     = /\+/g;  // Regex for replacing addition symbol with a space
        var search = /([^&=]+)=?([^&]*)/g;
        var decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); };
    
        var query  = "";
        var qmPos = url.indexOf('?');
        if (qmPos != -1)
          query = url.substr(qmPos + 1);
        else
          query = url;
    
        while (match = search.exec(query))
           urlParams[decode(match[1])] = decode(match[2]);
      }
    
      return urlParams;
    }

    function blendInParams(settings_params, params) {
       
       for ( var key in settings_params ) {
            if (params[key]) {settings_params[key].value=params[key]; }      
       }
    }


// }   
 
}     // end $.fn.QueryInput

    
    // could expose the defaults: $.fn.QueryInput.defaults =
    //{q:{label:"Query", widget:"text"}, submit:{value:"Search", widget:"submit"}}
    var defaults = {params: {},
                    input_prefix:"input-",
                    slider_style:{width:"80px", display:"inline-block", "font-size": "70%",  margin: "6px 12px 0 2px"},
                    onValueChanged : function() {},
                    fcs_source: "http://193.170.82.207:8680/exist/apps/sade/amc/fcs?operation=scan&x-format=json&scanClause="
                    };
    
    /* TODO: add defaults for widgets, like:
     widgets: {slider: {style:{width:"80px", display:"inline-block", "font-size": "70%",  margin: "6px 12px 0 2px"}}},
    */

})(jQuery, this);

