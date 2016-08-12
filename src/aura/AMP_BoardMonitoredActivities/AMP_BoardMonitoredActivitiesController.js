({
	doInit : function(component, event, helper) {
		helper.getRelatedBMAList(component);

	},
	handleUpdateBMAs : function(component, event, helper) {
		var comment = event.getParam("comment");
		var index = parseInt(event.getParam("index"));


		console.log('update comment');
		var action = component.get("c.upsertComment");
		action.setParams({
		"comment": comment
		});
	 action.setCallback(this, function(response){
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					comment = action.getReturnValue();
						console.log('success');
						var bmas = component.get("v.boardMonitoredActivities");
						bmas[index].Comments__r[0] = comment; // replace the line with the one returned from the database
						component.set("v.boardMonitoredActivities", bmas);



				}
			 else if (state === "ERROR") {
								var errors = response.getError();
								if (errors) {
										if (errors[0] && errors[0].message) {
												console.log("Error message: " +
																 errors[0].message);
										}
								} else {
										console.log("Unknown error");
								}
						}
					 console.log(action.response);
		});

 	 $A.enqueueAction(action);
	}
})