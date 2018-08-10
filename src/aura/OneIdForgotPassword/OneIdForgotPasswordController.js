({
    handleForgotPassword: function (component, event, helpler) {
        helpler.handleForgotPassword(component, event, helpler);
    },
    onKeyUp: function(component, event, helpler){
    //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleForgotPassword(component, event, helpler);
        }
    },
    
    doInit : function(component, event, helper) {
        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        
        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
    renderPage : function (component, event, helper){
        var state = event.getParam("state");

        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                component.set("v.customCommunity", true);
            }
        }
        
        component.set("v.loaded", true);
    }
})