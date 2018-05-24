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

        console.log('URL');
        console.warn(component.get("v.url"));
        if(component.get("v.url").length > 0) {
            var splitAfterlang = component.get("v.url").split('language=');
            if(splitAfterlang.length > 0) {
                var splitRemaining = splitAfterlang[1].split('&');
                if(splitRemaining.length > 0) {
                    component.set("v.selectedLanguage", splitRemaining[0]);
                }
            }
        }

        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
 
    renderPage : function (component, event, helper) {
        var state = event.getParam("state");

        console.info("renderPage - state "+state);
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            console.info("renderPage - paramsMap ");
            console.info(event.getParam("paramsMap"));
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                component.set("v.customCommunity", true);
                if(servName != null){
                  component.set("v.commName", servName);	    
                }
                
            }
        }
        
        component.set("v.loaded", true);
    },
   
    langPickerChange : function(c) {

        var param = new RegExp('language=[^&$]*', 'i');
        location.search = location.search.replace(param, 'language='+c.get("v.selectedLanguage"));

    }
})