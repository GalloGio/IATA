({
	doInit: function (component, event, helper) {
		helper.getAccount(component);
	},
	viewAccountDetails: function (component, event, helper) {
		let theUrl = "/lightning/r/Account/" + component.get("v.accountId") + "/view";
		helper.openUrlOnSubTab(component, theUrl);
	},
	viewAccountTeam: function (component, event, helper) {
		let theUrl = "/lightning/r/Account/" + component.get("v.accountId") + "/related/AccountTeamMembers/view";
		helper.openUrlOnSubTab(component, theUrl);
	},
});
