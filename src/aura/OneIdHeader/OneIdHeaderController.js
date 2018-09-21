({
     doInit : function(component, event, helper) {
        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();

        var langPickerOpts = [
            { value: "en_US", label: "English" },
            { value: "es", label: "Español" },
            { value: "ko", label: "Korean" },
            { value: "zh_CN", label: "Chinese (Simplified)" },
            { value: "pt_BR", label: "Portuguese (Brazilian)" },
            { value: "fr", label: "French" },
            { value: "ja", label: "Japanese" },
            { value: "it", label: "Italian" },
            { value: "de", label: "German" },
            { value: "th", label: "Thai" },
            { value: "in", label: "Indonesian" },
            { value: "vi", label: "Vietnamese" },
            { value: "ar", label: "Arabic" },
            { value: "ru", label: "Russian" },
            { value: "tr", label: "Turkish" }
        ];
        component.set("v.langPickerOptions", langPickerOpts);

        var parser = document.createElement('a');
        parser.href = component.get("v.url");
        var params = parser.search.substring(1);
        if(~params.indexOf('language')) {
            var paramList = params.split('&');
            for(var p in paramList){
                if(~paramList[p].indexOf('language')) component.set("v.selectedLanguage", paramList[p].split('=')[1]);
            }
        }

        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
 
    renderPage : function (component, event, helper) {
        var state = event.getParam("state");

        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
            }
        }
        
        component.set("v.loaded", true);
    },
   
    langPickerChange : function(c) {
        var search = location.search;
        var param = new RegExp('language=[^&$]*', 'i');
        if(~search.indexOf('language')){
            search = search.replace(param, 'language='+c.get("v.selectedLanguage"));
        }else{
            if(search.length > 0) search += '&';
            search += 'language='+c.get("v.selectedLanguage");
        }

        location.search = search; 

    }
})
