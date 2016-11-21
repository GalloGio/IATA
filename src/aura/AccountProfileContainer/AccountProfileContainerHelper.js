({
	//Fetch the accounts from the Apex controller
    getAccount: function(component) {
        var action = component.get("c.getAccount");
        action.setParams({
            "accountId": component.get("v.accountId")
        });
        
        //Set up the callback
        action.setCallback(this, function(actionResult) {
            component.set("v.account", actionResult.getReturnValue());            
            //console.log('callback: acc = ' + JSON.stringify(actionResult.getReturnValue()));
            
            var acc = component.get("v.account");
            console.log('acct Id: ' + acc.Id);
        });
        $A.enqueueAction(action);
    }   
})