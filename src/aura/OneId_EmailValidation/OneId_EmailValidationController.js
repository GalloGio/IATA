({
	checkTerms: function(component, event, helper) {
        // Check fields validity
        if (component.get("v.Terms") && helper.validateEmail(component)) {
            helper.checkUsername(component);
        }
    },

    renderPage : function (component, event, helper){
        // Get URL parameters
        var state = event.getParam("state");       
        if(state == "answer"){
            var invitationId = event.getParam("paramsMap").token; //Invitation ID
            // When someone receives an email from FRED with invitationID (created thru API by FRED in SF) 
            if(/\S/.test(invitationId) && invitationId != undefined){
                // email should be disabled
                component.find("email").set("v.disabled", true);
            }
        }
    }
})
