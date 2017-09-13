/**
 * @description Javascript Helper for Language Handler
 *              lightning component
 *
 *
 * @creation  2017-04-04
 * @category  Helper
 * @package   LanguageHandler
 * @author    Paulo Bastos <paulo.bastos@rightitservices.com>
 * @copyright 2017 Rightit Services
 * @license   Copyright Rightit Services.
 *            All rights reserved.
 *            Reproduction in whole or part is
 *            prohibited without written consent of
 *            the copyright owner.
 * @link      http://www.rightitservices.com
 */
 ({
	/**
	* @description Initializes lightning component
    * Gets the Language list from server populates component "SelectLanguageOption" select list and
    *  v.Languages attribute. Sets the current language. and check for errors.
    *
	* @namespace lexrits
	* @method initialize
	* @param {Object} cmp - Related Component Object
	*/
    initialize: function(component) {
		console.log('initialize.Helper Begin');

        var action = component.get('c.getLanguageInfo');

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                 var jsonResult=JSON.parse(ret);
				console.log('setCallback.result: '+JSON.stringify(ret));

                var languagesList=jsonResult.languages;

                var languageCurrent=this.getUrlParameterByName('language');
                if (languageCurrent==null){
                    languageCurrent='en_US';
                }
                else{
                    languageCurrent=jsonResult.currentLanguage;
                }
        		console.log('helper.initialize.languageCurrent='+languageCurrent);

                //Set component view attribute list of languages
                component.set('v.Languages',languagesList);

                //set the new selected value on the component
                component.set('v.selectedValue', languageCurrent);

                //return the selected value
                console.log('helper.initialize. VALOR after component initialization: '+component.find("InputSelectLanguage").get("v.value"));
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
        });

        $A.enqueueAction(action);
        
        console.log('initialize.Helper END');
    },

    /**
	* @description Change site language for the given value
    *
	* @namespace lexrits
	* @method changeLanguage
	* @param {Object} cmp - Related Component Object
	* @param {String} setlang - new language code to be set
	*/
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
                /*
                if (urlToReload.indexOf("?")==-1){
                    urlToReload=urlToReload+'?language='+settedtLang;
                }
                else{
                    urlToReload=urlToReload+'&language='+settedtLang;
                }
                */
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

    /**
	* @description Gets parameter value from url
    *
	* @namespace lexrits
	* @method getUrlParameterByName
	* @param {String} name - Parameter name to extract from url
	* @param {String} url - url complete string from where to extract parameter
    *
    * @return {String} Prameter value found in given URL
	*/
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

	/**
	* @description Reads a given cookie
    *
	* @namespace lexrits
	* @method readCookie
	* @param {String} name - Cookie name to read
    *
    * @return {String} Cookie value
	*/
	readCookie : function readCookie(name) {
    	return (name = new RegExp('(?:^|;\\s*)' 
                              + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') 
                              + '=([^;]*)').exec(document.cookie)) && name[1];
    },



})