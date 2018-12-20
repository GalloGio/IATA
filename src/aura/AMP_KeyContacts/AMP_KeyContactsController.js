({
	doInit: function(component, event, helper) {
        var action = component.get("c.getKeyContactsWrapped");
        var accountId = component.get("v.accountId");
        action.setParams({
                     "AccountId": accountId
                 });
                 action.setCallback(this, function(a) {
                         component.set("v.contacts", a.getReturnValue());
                 });
        $A.enqueueAction(action);
        helper.getReportId(component);
	},
    showPopup : function(component, event, helper) {
        component.set("v.showPopup", true);
    },
    hidePopup : function(component, event, helper) {
        component.set("v.showPopup", false);
    }
})