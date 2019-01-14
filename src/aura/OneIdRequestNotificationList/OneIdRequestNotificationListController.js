({
	initialize : function(component, event, helper) {
		console.log("initialize");
		helper.getUserApps(component);
	}
})