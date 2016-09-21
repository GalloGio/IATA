({
	getRelatedBMAList : function(component) {
		var requestedBMAType = component.get("v.displayType");
		var action;

		// select the action to execute
		if (requestedBMAType == "Division") {
				action = component.get("c.getDivisionBMAs");
		} else {
				action = component.get("c.getBMAs");
		}

		action.setParams({
				"accountId": component.get("v.accountId")
		});

		//Set up the callback
		var self = this;
		action.setCallback(this, function(actionResult) {
				component.set("v.boardMonitoredActivities", actionResult.getReturnValue());
		});
		$A.enqueueAction(action);
	}
})