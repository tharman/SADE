
            $(document).ready(function(){
                var opts = {
                    interactionMode : 'embedded',
                    //scalerBaseUrl : 'http://digilib.biblhertz.it/digilib04/servlet/Scaler',
                    //showRegionNumbers : false,
                    //autoRegionLinks : true
                    };
                var $div = $('div.digilib');
                $div.digilib(opts);

                // $('div.digilib').each(function(){
                //    console.log($(this).data('digilib').settings);
                //    });
            });
