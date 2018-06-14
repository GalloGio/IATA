({
	handleAccountIdUpdate : function(component, event, helper) {
        // get the sleected account Id from the event fired by the lookup component
		var accountId = event.getParam("sObjectId");
        
        console.log('selected accountId: ' + accountId);
        
        // fire the event for the dispatcher component
        var AccountIdSelectedEvent = component.getEvent("AccountIdSelected");
        AccountIdSelectedEvent.setParams({ "accountId": accountId}).fire();
	}
})