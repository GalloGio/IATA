({
    //Fetch the owner / subsidiary accounts from the Apex controller
    getRelatedAccountList: function(component) {
        var requestedAccountType = component.get("v.displayType");
        var action;

        // select the action to execute
        if (requestedAccountType == "Owners") {
            action = component.get("c.getOwners");
        } else {
            action = component.get("c.getSubsidiaries");
        }
        action.setParams({
            "AccountId": component.get("v.accountId")
        });

        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            //console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.relatedAccounts", actionResult.getReturnValue().amsAccountRoleList);
        });
        $A.enqueueAction(action);
    },
    getCanEdit: function(component) {
        var action;

        action = component.get("c.getCanEdit");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            // console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.canEdit", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})