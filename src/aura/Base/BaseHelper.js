({
    getParam: function(component, event, helper){ 
        
        if(event.getParam("state") == "fetch"){
            var c = component.get("v.checked");
                    
            if(!c){                
                var paramsMap = this.createObject(window.location.search.substring(1).toString());

                if(!paramsMap.serviceName) paramsMap.serviceName = '';

                //this is works for RelayState=service=name AS PART of the start URL (FRED)
                var str = decodeURIComponent(paramsMap.startURL);
                if(paramsMap.serviceName == '' && str && str.indexOf('RelayState') > 0 && str.indexOf('serviceName=') > 0){
                    var temp = str.split('serviceName=')[1];
                    paramsMap.serviceName = temp.substring(0, temp.indexOf('&'));
                }
                
                component.set("v.url", window.location.toString());                
                component.set("v.paramsMap", paramsMap);
                component.set("v.checked", true);

                // Load config from service bundle object if any
                this.getConfig(component);
            }

            $A.get("e.c:oneIdURLParams").setParams({
                "state" : "answer",
                "url" : component.get("v.url"),
                "paramsMap" : component.get("v.paramsMap")
            }).fire();
            
        }
    },

    createObject: function(urlParamEncoded){         
        var paramsMap = JSON.parse((urlParamEncoded == '') ? '{}' : decodeURIComponent('{"' + urlParamEncoded.replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"') + '"}') );        
        return paramsMap;
    },

    getConfig: function(component) { 
        var paramsMap = component.get("v.paramsMap");
        if(paramsMap.serviceName != undefined) {
            var action = component.get("c.loadConfig");
            action.setParams({
                "serviceName": paramsMap.serviceName
            });
            action.setCallback(this, function(a) {
                var config = a.getReturnValue();
                if(config != null) {
                    paramsMap.serviceConfig = config;
                    component.set("v.paramsMap", paramsMap);
                    }
                    // Sent event to other components aftter loading service object config
                    $A.get("e.c:oneIdURLParams").setParams({
                        "state" : "answer",
                        "url" : component.get("v.url"),
                        "paramsMap" : component.get("v.paramsMap")
                    }).fire();
            
            });
            $A.enqueueAction(action);
        }
    }

})