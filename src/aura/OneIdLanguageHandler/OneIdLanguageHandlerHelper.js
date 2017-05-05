({
	//get user local language
    initialize: function(component) {
		console.log('initialize.Helper');

        var action = component.get('c.getSupportedLanguagesMap');
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var langMapp = response.getReturnValue();
				console.log('setCallback.result: '+JSON.stringify(langMapp));
				
                languageCurrent=this.getUrlParameterByName('language');
        		console.log('helper.initialize.languageCurrent='+languageCurrent);
                
                var opts = new Array();
                
                for (var key in langMapp){                
                    var opt = {};
                    opt.class='SelectLanguageOption';
                    opt.label=langMapp[key];
                    opt.value=key;
                    if (key==languageCurrent){
                        opt.selected="true"
                    }
                    
                    opts.push(opt);
                }

            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            else
            {
                console.log('helper.initialize.setCallback.NOTSUCCESS');
            }

            component.find("InputSelectLanguage").set("v.options", opts);
        });

        $A.enqueueAction(action);
    },

    //change user local language to given value
    changeLanguage: function(cmp, setlang) {
        
        var action = cmp.get("c.changeLanguage");
        action.setParams({
            newLanguage : setlang
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if (state === "SUCCESS") {
                var settedtLang = res.getReturnValue();
                console.log('changeLanguage.setCallback.result: '+JSON.stringify(settedtLang));
 
                var urlToReload=window.location.pathname+'?language='+settedtLang;
                //if (urlToReload.indexOf("\?")==-1){
                    //urlToReload=urlToReload+'?language='+settedtLang;
                //}
                //else{
                //    urlToReload=urlToReload+'&language='+settedtLang;
                //}
        		console.log('helper.changeLanguage.urlToReload: '+urlToReload);

                // similar behavior as an HTTP redirect
                //window.location.replace(urlToReload);
                
                // similar behavior as clicking on a link
                window.location.href = urlToReload;
                
                //window.location.reload(urlToReload);
            }
            //else if (cmp.isValid() && state === "INCOMPLETE") {
            else if (state === "INCOMPLETE") {
                // do something
                console.log("changeLanguage.setCallback.INCOMPLETE");
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("changeLanguage.setCallback.Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("changeLanguage.setCallbackUnknown error");
                }
            }
            else
            {
                console.log('changeLanguage.setCallback.NOTSUCCESS');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getUrlParameterByName : function (name, url) {
        if (!url) {
          url = window.location.href;
        }
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
	},

	readCookie : function readCookie(name) {
    	return (name = new RegExp('(?:^|;\\s*)' 
                              + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') 
                              + '=([^;]*)').exec(document.cookie)) && name[1];
    },



})