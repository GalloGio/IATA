({
    doInit: function(component, event, helper) {
        $A.get("event.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        component.set("v.emailPattern", '^[a-zA-Z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$');
        
        helper.isGuestUser(component);
        helper.loadEmptyCase(component);
    },
    
    renderPage : function (component, event, helper){
        var state = event.getParam("state");
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
            }
        }
    },
    
    handleClick : function(component, event, helper) {
        helper.submitCase(component);
    },
    
    checkSubject : function(component, event, helper) {
        var value = component.get("v.subject");
        if(value != ''){
            component.set("v.subjectMissing", false);
        }
    },
    
    checkOtherSubject : function(component, event, helper) {
        var value = component.get("v.otherSubject");
        if(value != ''){
            component.set("v.otherSubjectMissing", false);
        }
    }
})