({
	doInit : function(component, event, helper) {

		var action = component.get("c.getObjectives");

		action.setParams({
				"accountId": component.get("v.accountId")
		});
		//Set up the callback
		var self = this;
		action.setCallback(this, function(actionResult) {
				component.set("v.activities", actionResult.getReturnValue());
		});
		$A.enqueueAction(action);
	}
})
