({
	switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        var account = component.get("v.account");
        var accountOwnership = account.AM_Ownership_Type__c;

        if(JSON.stringify(accountOwnership).indexOf("Privately-held") != -1) {
            component.set("v.isPrivatelyHeld", true);
        }

        if(JSON.stringify(accountOwnership).indexOf("Publically-held") != -1) {
            component.set("v.isPublicallyHeld", true);
        }
        if(JSON.stringify(accountOwnership).indexOf("Goverment-held") != -1) {
           component.set("v.isGovermentHeld", true);
        }
    },
    cancelEditMode : function(component, event, helper) {
        component.set("v.isEditMode", false);
    },
    clickSaveAccount : function(component, event, helper) {
        var account = component.get("v.account");
        var accountOwnership = '';

        if(component.get("v.isPrivatelyHeld") == true) {
            accountOwnership += 'Privately-held';
        }
 		if(component.get("v.isPublicallyHeld") == true) {
            if(accountOwnership != '') accountOwnership += ';';
            accountOwnership += 'Publically-held';
        }
        if(component.get("v.isGovernmentHeld") == true) {
            if(accountOwnership != '') accountOwnership += ';';
            accountOwnership += 'Government-held';
        }
        console.log(accountOwnership);
        account.AM_Ownership_Type__c = accountOwnership;
        account.sobjectType = 'Account';
        console.log(JSON.stringify(account));
        var action = component.get("c.saveAccount");
        action.setParams({
            "accountToUpdate": account
        });
        action.setCallback(this, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                account = action.getReturnValue();
                console.log('success');
                component.set("v.account", account);

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));

            }
            console.log(action.response);
        });

        $A.enqueueAction(action);

        component.set("v.isEditMode", false);
    }

})
