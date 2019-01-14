({
	initialize : function(component, event, helper) {
		console.log("initialize");

		var urlparameter = helper.getUrlParameter(component);

		helper.getAppTerms(component);
	}
})