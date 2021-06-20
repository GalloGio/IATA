({
	toggleSpinner: function (cmp) {
		var spinner = cmp.find("cases-spinner");
		$A.util.toggleClass(spinner, "slds-hide");
	},
	initTable: function (component) {
		component.set("v.columnsCases", [
			{ title: "Contact", fieldname: "contactName", sortable: true },
			{ title: "Case Type", fieldname: "caseTypeImg", sortable: false },
			{ title: "Channel", fieldname: "caseChannel", sortable: true },
			{ title: "Case", fieldname: "caseNumber", sortable: true },
			{ title: "Subject", fieldname: "caseSubject", sortable: false },
			{ title: "Date", fieldname: "caseDate", sortable: false },
			{ title: "Resol. Time", fieldname: "caseResolTime", sortable: false },
			{ title: "Owner", fieldname: "caseOwnerName", sortable: true },
		]);
	},
	loadCases: function (component, helper) {
		var action = component.get("c.getAccountCases");
		var accountId = component.get("v.accountId");
		var contactId = component.get("v.contactId");
		helper.toggleSpinner(component);
		action.setParams({ accountId: accountId, contactId: contactId });
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				var result = response.getReturnValue();
				component.set("v.dataCases", result);
				component.set("v.filteredDataCases", result);
				helper.toggleSpinner(component);
			} else {
				helper.toggleSpinner(component);
			}
		});

		$A.enqueueAction(action);
	},
});
