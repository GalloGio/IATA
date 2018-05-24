({
	getHostURL: function(component, event) {
        var vfOrigin = component.get("c.getHostURL");
        vfOrigin.setCallback(this, function(response) {
            console.log('response ' + response.getReturnValue());
            component.set("v.vfHost", 'https://' + response.getReturnValue());
        });
        $A.enqueueAction(vfOrigin);

    },

    getCommunityName: function(component, event) {
        var commName = component.get("c.getCommunityName");
        commName.setCallback(this, function(response) {
            console.log('getCommunityName response ' + response.getReturnValue());
            component.set("v.commName", response.getReturnValue());
        });
        $A.enqueueAction(commName);

    },

    notifyStepCompletion: function(component) {
        var cmpEvent = component.getEvent("StepCompletionNotification");
        cmpEvent.setParams({
            "stepNumber" : 1,
            "isComplete" : true,
             });
        cmpEvent.fire();
    },

    validateEmail :function(component) {
        var emailCmp = component.find("email");
        var emailValue = emailCmp.get("v.value");

        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        if($A.util.isEmpty(emailValue)) {
            emailCmp.set("v.errors", [{ message: $A.get("$Label.c.ISSP_EmailError")}]);
            // Reset checkbox if eamil is not valid
            component.set("v.Terms", false);
            return false;
        } else if(! emailValue.match(regExpEmailformat)) {
            emailCmp.set("v.errors", [{ message: $A.get("$Label.c.ISSP_AMS_Invalid_Email")}]);
            // Reset checkbox if eamil is not valid
            component.set("v.Terms", false);
            return false;
        } else {
            emailCmp.set("v.errors", [{message: null}]);
            return true;
        }
    },

    checkUsername :function(c) {
        var spinner = c.find("loading");
        $A.util.toggleClass(spinner, "slds-hide");

        var emailCmp = c.find("email");
        var emailValue = emailCmp.get("v.value");
        var action = c.get("c.checkIsUsernameIsAvailableInGlobalSalesforce");
        action.setParams({
            "email":emailValue
        });

        action.setCallback(this, function(a) {
            var isUserCanBeCreated = a.getReturnValue();

            if(isUserCanBeCreated){
                var country = c.get("v.userCountry");
                var vfOrigin = c.get('v.vfHost');
                var vfWindow = c.find("vfFrame").getElement().contentWindow;
                vfWindow.postMessage({ action: "alohaCallingCAPTCHA",country : country }, vfOrigin);
                emailCmp.set("v.errors", null);
            }else{
                emailCmp.set("v.errors", [{message: $A.get("$Label.c.OneId_Registration_UserExist")}]);
                c.set("v.Terms", false);
            }
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }
})