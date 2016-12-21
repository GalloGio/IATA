({
	doInit : function(component, event, helper) {
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