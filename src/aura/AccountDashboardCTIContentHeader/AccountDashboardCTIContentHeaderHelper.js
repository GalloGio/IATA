({
	getAccount: function (component) {
		var action = component.get("c.getAccountHeader");
		action.setParams({
			accountId: component.get("v.accountId"),
		});

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				component.set("v.record", response.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},
	openUrlOnSubTab: function (component, theUrl) {
		var workspaceAPI = component.find("workspaceAccount");
		if (workspaceAPI != undefined) {
			workspaceAPI.openSubtab({
				url: theUrl,
				focus: true,
			});
		}
	},
});
