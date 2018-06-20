({
    getParam: function(component, event, helper){ 
        console.info("Event received params ");
        
        if(event.getParam("state") == "fetch"){
            var c = component.get("v.checked");
                    
            if(!c){                
                console.log('getParam');
                var urlParamEncoded = window.location.search.substring(1).toString();                
                var urlParameters = decodeURIComponent(urlParamEncoded); // Right part after base URL   
                var paramsMap = {};
                paramsMap.serviceName = '';
                
                if(urlParameters != ''){                
                    var paramsMap = this.getParseUrl(urlParamEncoded,urlParameters);
                }
                
                if(paramsMap.serviceName == null && paramsMap.RelayState == null && urlParameters.indexOf('RelayState') < 0){                                    
                    if(paramsMap.startUrl == null){                                               
                        var paramsMapTemp = this.getParseUrl(urlParamEncoded,paramsMap.startUrl);                                                
                        paramsMap =  JSON.stringify(paramsMap).concat(JSON.stringify(paramsMapTemp));                        
                    }
                }
                
                
                if(urlParameters.indexOf('RelayState') > 0){                    
                    var pMap = JSON.stringify(paramsMap);                    
                    var pMapUnescape = unescape(pMap);
                    var getServiceName = pMapUnescape.split('serviceName=')[1];                    
                    var service = getServiceName.substring(0, getServiceName.indexOf('&'));                                                            
                    paramsMap.serviceName = service;                    
                }                
                
                component.set("v.url", urlParameters);                
                component.set("v.paramsMap", paramsMap);
                component.set("v.checked", true);

                // Load config from service bundle object if any
                this.getConfig(component, paramsMap);
                //component.set("v.checked", true);
            }

            $A.get("e.c:oneIdURLParams").setParams({
                "state" : "answer",
                "url" : component.get("v.url"),
                "paramsMap" : component.get("v.paramsMap")
            }).fire();
            
        }
    },

    getParseUrl: function(urlParamEncoded, urlParameters){         
        var paramsMap = JSON.parse((urlParameters == '') ? '{}' : decodeURIComponent('{"' + urlParamEncoded.replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"') + '"}') );        
        return paramsMap;
    },

    getConfig: function(component, paramsMap) { 
        console.log('config1'+paramsMap.serviceName);
        if(paramsMap.serviceName != undefined) {
            var action = component.get("c.loadConfig");
            action.setParams({
                "serviceName": paramsMap.serviceName
            });
            action.setCallback(this, function(a) {
                console.log('config2');
                var config = a.getReturnValue();
                console.log('config2a'+config);
                if(config != null) {
                     console.log('config3');
                    paramsMap.serviceConfig = config;
                    console.log('config'+config);
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