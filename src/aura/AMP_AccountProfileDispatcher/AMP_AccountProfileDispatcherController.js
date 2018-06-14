({
	setAccountId : function(component, event, helper) {
		var accountId = event.getParam("accountId");
        
        console.log('handling account Id selection in dispatcher; account Id: ' + accountId);
        
        component.set("v.accountId", accountId);
	}
})