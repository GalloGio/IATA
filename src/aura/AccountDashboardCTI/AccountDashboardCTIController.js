({
	doInit: function (component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		var accountId = myPageRef.state.c__accountId;
		var contactId = myPageRef.state.c__contactId;
		component.set("v.accountId", accountId);
		if (contactId != undefined) {
			component.set("v.contactId", contactId);
		}
		let workspaceAPI = component.find("workspace");
		if (workspaceAPI != undefined) {
			workspaceAPI.getFocusedTabInfo().then(function (response) {
				var focusedTabId = response.tabId;
				workspaceAPI.setTabLabel({
					tabId: focusedTabId,
					label: "Odigo Page",
				});
			});
		}

		var action = component.get("c.getUserAccessRights");

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				component.set("v.accessLevel", response.getReturnValue());
			}
		});

		$A.enqueueAction(action);
	},
});
