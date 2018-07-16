({
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

        //check if username is available (insert + rollback)
        var action = c.get("c.checkIsUsernameIsAvailableInGlobalSalesforce");
        action.setParams({
            "email":emailValue
        });

        action.setCallback(this, function(a) {
            var isUserCanBeCreated = a.getReturnValue();

            if(isUserCanBeCreated){
                //notify parent component that step is completed
                var e = c.getEvent("StepCompletionNotification");
                e.setParams({
                    "stepNumber" : 1,
                    "isComplete" : true,
                     });
                e.fire();

                emailCmp.set("v.errors", null);
                emailCmp.set("v.disabled", true);
                c.find("termsaccepted").set("v.disabled", true);
            }else{
                emailCmp.set("v.errors", [{message: $A.get("$Label.c.OneId_Registration_UserExist")}]);
                c.set("v.Terms", false);
            }
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }
})
