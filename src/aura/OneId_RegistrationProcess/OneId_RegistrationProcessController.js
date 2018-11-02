({
    doInit: function(c, e, helper) {
        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
		helper.getUserInformation(c);
    },
    jsLoaded: function(component, event, helper){
        // uses jquery to find the user IP and Country
        $.getJSON("https://jsonip.com/?callback=?", function (data) {     
            var action = component.get("c.findLocation");        
            action.setParams({"ipAddress" : data.ip});        
                
            action.setCallback(this, function(response) {   
                var state = response.getState();         
                if (state === "SUCCESS") {
                    component.set("v.userCountry",response.getReturnValue());                
                }            
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("IP Search: Error message: " + errors[0].message);
                        }
                    } else {
                        console.error("IP Search: Unknown error");
                    }
                }
            });        
            $A.enqueueAction(action);
        });
    },
    renderPage : function (c, e, helper){
        var state = e.getParam("state");       
        if(state == "answer"){

            var servName = e.getParam("paramsMap").serviceName;
            var invitationId = e.getParam("paramsMap").token; //Invitation ID

            if(/\S/.test(servName)){
                c.set("v.serviceName", servName);
                c.set("v.customCommunity", true);
            }

            // When a someone receives an email from FRED with invitationID (created thru API by FRED in SF) 
            if(/\S/.test(invitationId) && invitationId != undefined){
                console.log(invitationId);
                c.set("v.invitationId", invitationId);
                helper.loadInvitationInfo(c, invitationId);
                
            }

        }
    },
    section1 : function(cmp, evt, hlp) {
       hlp.openStep(cmp, 1);
   },

    section2 : function(cmp, evt, hlp) {
        if(cmp.get("v.stepCompletion")[1]) {
            hlp.openStep(cmp, 2);
        }
    },

    section3 : function(cmp, evt, hlp) {
        $A.get("e.c:OneId_RequestCompletionCheck_EVT").fire();
    },

    handleStepCompletion: function (cmp, evt, hlp){
        // stepCompletion hold an array reprention steps completion ex:[true, false, false] means step1 complete but not step 2 and 3
        var stepArray = [];
        stepArray = cmp.get("v.stepCompletion");
        var stepNumber = evt.getParam("stepNumber");
        var isComplete = evt.getParam("isComplete");
        stepArray[stepNumber] = isComplete;
        cmp.set("v.stepCompletion", stepArray);

        if(stepNumber != 3 && isComplete) hlp.openStep(cmp, (stepNumber+1));
        if(stepNumber == 3 && isComplete){
            $A.util.toggleClass(cmp.find("mainContainer"), "slds-hide");
            $A.util.toggleClass(cmp.find("registrationComplete"), "slds-hide");
        }

    }
})