({
	backToSeach : function(component, event, helper) {
		// fire the event for the dispatcher component
        var AccountIdSelectedEvent = component.getEvent("AccountIdSelected");
        AccountIdSelectedEvent.setParams({ "accountId": null}).fire();
	}
})
