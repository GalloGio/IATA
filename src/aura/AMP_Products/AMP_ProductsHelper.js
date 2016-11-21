({
	getCanView : function(component) {
		var action;
        action = component.get("c.canViewSalesfigures");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            // console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.canRead", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
	},
	getServices : function(component) {
		var action = component.get("c.getAccountServices");
		var accountId = component.get("v.accountId");

		action.setParams({
				"accountId": accountId
			});
			action.setCallback(this, function(a) {
				 var services = a.getReturnValue();
				 var state = a.getState();

				 if (component.isValid() && state === "SUCCESS") {
					component.set("v.AccountServices", services);
				 }
				 else if (state === "ERROR") {}
			});
			$A.enqueueAction(action);
	}
})