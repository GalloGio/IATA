({
	doInit: function (component, event, helper) {
		helper.getAccount(component);
	},
	viewAccountDetails: function (component, event, helper) {
		let urlToGo = "/" + component.get("v.accountId");
		window.open(urlToGo, "_parent");
	},
	viewAccountTeam: function (component, event, helper) {
		let urlToGo = "/acc/accteammemberlist.jsp?rlid=RelatedAccountSalesTeam&id=" + component.get("v.accountId");
		let urlMethod = "_blank";
		if (component.get("v.UIThemeDescription") != "Theme3") {
			urlToGo = "/lightning/r/Account/" + component.get("v.accountId") + "/related/AccountTeamMembers/view";
			urlMethod = "_parent";
		}
		window.open(urlToGo, urlMethod);
	},
});
