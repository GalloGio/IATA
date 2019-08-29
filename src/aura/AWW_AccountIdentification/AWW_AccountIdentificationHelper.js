({
    getAccount : function(component) {
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "accountId": component.get("v.accountId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.record", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    },
    saveOtherTypeofSubsidiaries : function(component) {
        var action = component.get("c.saveAccountDetails");
        action.setParams({
            "accountDetails": component.get("v.record")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state", state);
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.record", response.getReturnValue());
                component.set('v.otherTypeofSubsidiariesToEdit',false);
            }
            var spinner = component.find('app-spinner');
            $A.util.addClass(spinner, 'slds-hide');
        });

        $A.enqueueAction(action);
    }
})