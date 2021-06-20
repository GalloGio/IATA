({
	init: function (component, event, helper) {
		helper.initTable(component);
		helper.loadContacts(component, helper);
	},
	search: function (component, event, helper) {
		helper.handleSearch(component);
	},
	sortContacts: function (component, event, helper) {
		if (event.target.dataset.sortable == "false") {
			return;
		}

		var currentSortField = component.get("v.sortField");
		var sortField = event.target.title;
		var ascOrder = true;

		if (currentSortField == sortField) {
			var currentOrder = component.get("v.ascOrder");
			ascOrder = !currentOrder;
		} else {
			component.set("v.sortField", sortField);
		}

		component.set("v.ascOrder", ascOrder);
		helper.sortRecords(component, event.target.dataset.fieldname, ascOrder);
	},
	showContactPortalServices: function (component, event, helper) {
		let contactSelected = event.getSource().get("v.text");
		component.set("v.contactIdSelected", contactSelected);
		// update Portal Services for the selected contact
		helper.getPortalServiceForContactId(component, contactSelected);
	},
	createNewCase: function (component, event, helper) {
		let contactSelected = component.get("v.contactIdSelected");
		if (contactSelected != null && contactSelected != "") {
			helper.createNewCaseForContactId(component, helper, contactSelected);
		} else {
			alert("Please select the Contact before create a New Case!");
		}
	},
	gotoAllContacts: function (component, event, helper) {
		let accountId = component.get("v.accountId");
		let urlToGo = "/003?rlid=RelatedContactList&id=" + accountId;
		let urlMethod = "_blank";
		if (component.get("v.UIThemeDescription") !== "Theme3") {
			urlToGo = "/lightning/r/" + accountId + "/related/Contacts/view";
			//urlMethod = "_parent";
		}
		window.open(urlToGo, urlMethod);
	},
});
