({
    doInit: function(component, event, helper) {
        var canEdit = component.get("c.getCanEdit");
        canEdit.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var vals = response.getReturnValue();
                component.set("v.canEdit", vals[0]);
            }
            else {

            }
                });
        $A.enqueueAction(canEdit);
    },

    switchToEditMode: function(component, event, helper) {
        var account = component.get("v.account");
        component.set("v.SanctionNotice", account.SanctionNotice__c);
            component.set("v.isEditMode", true);
    },

    cancelEditMode : function(component, event, helper) {
            component.set("v.account.SanctionNotice__c",component.get("v.SanctionNotice"));
            component.set("v.isEditMode", false);
            },

    save : function(component, event, helper) {
            var save = component.get("c.saveRecord");
            save.setParams({
                 "recordDetail": component.get("v.account")
            });
            $A.enqueueAction(save);
            component.set("v.isEditMode", false);
    },

	backToSeach : function(component, event, helper) {
		// fire the event for the dispatcher component
        var AccountIdSelectedEvent = component.getEvent("AccountIdSelected");
        AccountIdSelectedEvent.setParams({ "accountId": null}).fire();
	}
})
