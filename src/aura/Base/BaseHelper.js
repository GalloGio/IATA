({
	getParam: function(component, event, helper){ 
        console.info("Event received params ");
        
        if(event.getParam("state") == "fetch"){
            var c = component.get("v.checked");        
            if(!c){
                var urlParameters = decodeURIComponent(window.location.search.substring(1)).toString(); // Right part after base URL
                var paramsMap = JSON.parse('{"' + urlParameters.replace(new RegExp('"', 'g'), '\\"').replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"') + '"}'); 
                
                component.set("v.url", urlParameters);
                component.set("v.paramsMap", paramsMap);
                component.set("v.checked", true);
               
            }
            
            $A.get("e.c:oneIdURLParams").setParams({
                "state" : "answer",
                "url" : component.get("v.url"),
                "paramsMap" : component.get("v.paramsMap")
            }).fire();
        }
    }
})