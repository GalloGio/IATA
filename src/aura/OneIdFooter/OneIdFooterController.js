({
    doInit : function(component, event, helper) {
        console.info('controller...');
        
        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        
        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
    renderPage : function (component, event, helper){
        console.log('renderpage...');
        var state = event.getParam("state");

        console.info("renderPage - state "+state);
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            console.info("renderPage - paramsMap ");
            console.info(event.getParam("paramsMap"));
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                component.set("v.customCommunity", true);
                                
                var labelHelpLink = $A.getReference("$Label.c.OneId_" + servName + "_Troubleshooting_Link");
                var labelHelp = $A.getReference("$Label.c.OneId_" + servName + "_Troubleshooting");
                var labelTerms = $A.getReference("$Label.c.OneId_" + servName + "_Terms_Of_Use_Link");
                component.set("v.labelHelpLink", labelHelpLink);
                component.set("v.labelHelp", labelHelp);
                component.set("v.labelTermsOfUseLink", labelTerms);
            }
        }
        
        component.set("v.loaded", true);
    }
})