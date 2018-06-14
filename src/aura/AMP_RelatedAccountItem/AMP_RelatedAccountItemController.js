({
    doInit: function(component, event, helper) {
        var relatedAccount = component.get("v.relatedAccount");
        
        if(relatedAccount.Id === undefined) {
            component.set("v.isEditMode", true);
        } else {
            component.set("v.isEditMode", false);
        }
        
    },
    switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        console.log('going into edit mode...');
    },
    HandleOwnershipError: function(component, event, helper) {
        var componentIndex = event.getParam("index");
        var accountRoleId = event.getParam("accountRoleId");
        //console.log('Index ' + component.get("v.index") + ' with account role Id ' + component.get("v.relatedAccount").Id + ' is treating error message ');
        
        if (componentIndex == component.get("v.index") && accountRoleId == component.get("v.relatedAccount").Id) {
            console.log('Index ' + component.get("v.index") + ' with account role Id ' + accountRoleId + ' is going into error mode... ');
            
            component.set("v.isEditMode", true);
            component.set("v.isError", true);
            component.set("v.errorMessage", event.getParam("errorMessage"));
        }
    },
    cancelEditMode : function(component, event, helper) {
        var relatedAccount = component.get("v.relatedAccount");
        if(relatedAccount.Id === undefined) {
            console.log('cancel add new  -> delete');
            var deleteAccountEvent = component.getEvent("deleteAccount");
            deleteAccountEvent.setParams({'accountRole' : relatedAccount});
            deleteAccountEvent.fire();
            // component.set("v.editMode", false);
        }
        component.set("v.isEditMode", false);
        // console.log('canceling edit mode...');
    },
    deleteItem : function(component, event, helper) {
        // Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list
        
        console.log('delete clicked...');
        var relatedAccount = component.get("v.relatedAccount");
        
        var deleteAccountEvent = component.getEvent("deleteAccount");
        deleteAccountEvent.setParams({'accountRole' : relatedAccount});
        deleteAccountEvent.fire();
        component.set("v.isEditMode", false);
    },
    clickSaveAccount : function(component, event, helper) {
        
        var relatedAccount = component.get("v.relatedAccount");
        
        var index = component.get("v.index");
        var updateEvent = component.getEvent("updateAccount");
        updateEvent.setParams({ "accountRole": relatedAccount, "index":index }).fire();
        
        component.set("v.isEditMode", false);
    },
    /**
     * Handler for receiving the updateLookupIdEvent event
     */
    handleAccountIdUpdate : function(cmp, event, helper) {
        // Get the Id from the Event
        var accountId = cmp.get("v.accountId");
        var ownerAccountId = event.getParam("sObjectId");
        
        var account = cmp.get("v.relatedAccount");
        if (cmp.get("v.displayType") == 'Owners') {
            account.Account__c = accountId;
            account.Owner_Account__c = ownerAccountId;
        } else {
            account.Account__c = ownerAccountId;
            account.Owner_Account__c = accountId;
        }
        // Set the Id bound to the View
        cmp.set("v.relatedAccount", account);
    },
    
    /**
     * Handler for receiving the clearLookupIdEvent event
     */
    handleAccountIdClear : function(cmp, event, helper) {
        // Clear the Id bound to the View
        var account = cmp.get("v.relatedAccount");
        if (cmp.get("v.displayType") == 'Owners') {
            account.Owner_Account__c = null;
        } else {
            account.Account__c = null;
        }
        
        // Set the Id bound to the View
        cmp.set("v.relatedAccount", account);
    }
})