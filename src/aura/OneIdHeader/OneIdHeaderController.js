({
    doInit : function(component, event, helper) {
        console.info('controller...');
        
        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        
        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
    renderPage : function (component, event, helper){
        var state = event.getParam("state");

        console.info("renderPage - state "+state);
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            console.info("renderPage - paramsMap ");
            console.info(event.getParam("paramsMap"));
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                component.set("v.customCommunity", true);
            }
        }
        
        component.set("v.loaded", true);
    }
})