({
	toggleSpinner: function (cmp) {
		let spinner = cmp.find("contacts-spinner");
		$A.util.toggleClass(spinner, "slds-hide");
	},
	initTable: function (component) {
		component.set("v.columns", [
			{ title: "", fieldname: "contactId", sortable: false },
			{ title: "Name", fieldname: "contactName", sortable: false },
			{ title: "Type", fieldname: "contactType", sortable: false },
			{ title: "Status", fieldname: "status", sortable: false },
			{ title: "Title", fieldname: "title", sortable: false },
			{ title: "Email", fieldname: "email", sortable: false },
			{ title: "Phone", fieldname: "phone", sortable: false },
			{ title: "Last Activity Date", fieldname: "lastActivityDate", sortable: false },
		]);
		component.set("v.columnsPortalServices", [
			{ title: "Portal Service", fieldname: "contactName", sortable: false },
			{ title: "Access Status", fieldname: "status", sortable: false },
		]);
	},
	loadContacts: function (component, helper) {
		let action = component.get("c.getKeyContacts");
		let accountId = component.get("v.accountId");
		let contactId = component.get("v.contactId");
		if (contactId == "") {
			contactId = null;
		}
		helper.toggleSpinner(component);
		action.setParams({ accountId: accountId, contactId: contactId });
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				let result = response.getReturnValue();
				component.set("v.data", result);
				component.set("v.filteredData", result);
				if (contactId != null) {
					component.set("v.contactIdSelected", contactId);
					helper.getPortalServiceForContactId(component, contactId);
				}
				helper.toggleSpinner(component);
			} else {
				helper.toggleSpinner(component);
			}
		});

		$A.enqueueAction(action);
	},
	handleSearch: function (component) {
		let data = component.get("v.data");
		let term = component.find("search-contact").get("v.value");

		if (term) {
			let regex = new RegExp(term, "i");
			let results = data.filter((row) => regex.test(row.contactName) || regex.test(row.accountSite));
			component.set("v.filteredData", results);
		} else {
			component.set("v.filteredData", data);
		}

		this.resetSort(component);
	},
	resetSort: function (component) {
		component.set("v.sortField", "Name");
		component.set("v.ascOrder", true);
	},
	sortRecords: function (component, sortField, ascOrder) {
		let records = component.get("v.filteredData");
		records.sort(function (a, b) {
			let t1 = a[sortField].toLowerCase() == b[sortField].toLowerCase(),
				t2 = a[sortField].toLowerCase() > b[sortField].toLowerCase();
			return t1 ? 0 : (ascOrder ? -1 : 1) * (t2 ? -1 : 1);
		});

		component.set("v.filteredData", records);
	},
	getPortalServiceForContactId: function (component, contactSelected) {
		if (contactSelected !== undefined && contactSelected !== "") {
			let contactData = component.get("v.data");
			component.set("v.portalServicesForContact", null);
			for (let ctt of contactData) {
				if (ctt.contactId == contactSelected && ctt.portalServices != undefined && ctt.portalServices != null) {
					component.set("v.portalServicesForContact", ctt.portalServices);
					break;
				}
			}
		}
	},
	getNumberWithZeroPrefix: function (num) {
		if (num < 10) {
			num = "0" + num;
		}
		return num;
	},
	getDateTimeForSubject: function (component, helper) {
		let d = new Date();
		let year = d.getFullYear();
		let month = d.getMonth() + 1;
		let day = d.getDate();
		let hour = d.getHours();
		let min = d.getMinutes();
		let sec = d.getSeconds();
		month = helper.getNumberWithZeroPrefix(month);
		day = helper.getNumberWithZeroPrefix(day);
		hour = helper.getNumberWithZeroPrefix(hour);
		min = helper.getNumberWithZeroPrefix(min);
		sec = helper.getNumberWithZeroPrefix(sec);

		return year + "-" + month + "-" + day + " " + hour + ":" + min + ":" + sec;
	},
	openUrlOnSubTab: function (component, theUrl) {
		var workspaceAPI = component.find("workspaceContact");
		if (workspaceAPI != undefined) {
			workspaceAPI.openSubtab({
				url: theUrl,
				focus: true,
			});
		}
	},
	createNewCaseForContactId: function (component, helper, contactSelected) {
		if (contactSelected != "") {
			let accountId = component.get("v.accountId");
			let contactId = contactSelected;
			let url_new_case = "";
			let contactData = component.get("v.data");
			let contactDataSelected = null;
			let open_page_method = "_parent";
			let dateFinal = helper.getDateTimeForSubject(component, helper);
			let caseSubject = encodeURIComponent("Phone call received on the " + dateFinal);
			let caseDescription = encodeURIComponent("Phone call");
			let caseVisibleISSPortal = "true";
			let caseOrigin = "Phone";
			for (let ctt of contactData) {
				if (ctt.contactId == contactSelected) {
					contactDataSelected = ctt;
					break;
				}
			}

			url_new_case += "/lightning/o/Case/new?count=1&useRecordTypeCheck=1&defaultFieldValues=";
			url_new_case += "ContactId" + "%3D" + contactId;
			url_new_case += "%2C";
			url_new_case += "AccountId" + "%3D" + accountId;
			url_new_case += "%2C";
			url_new_case += "Region__c" + "%3D" + encodeURIComponent(contactDataSelected.AccountRegionName);
			url_new_case += "%2C";
			url_new_case += "BSPCountry__c" + "%3D" + encodeURIComponent(contactDataSelected.AccountCountryName);
			url_new_case += "%2C";
			url_new_case += "Origin" + "%3D" + caseOrigin;
			url_new_case += "%2C";
			url_new_case += "Subject" + "%3D" + caseSubject;
			url_new_case += "%2C";
			url_new_case += "Description" + "%3D" + caseDescription;
			url_new_case += "%2C";
			url_new_case += "Visible_on_ISS_Portal__c" + "%3D" + caseVisibleISSPortal;
			url_new_case += "%2C";
			url_new_case += "IATAcode__c" + "%3D" + contactDataSelected.accountIATACode;
			if (contactDataSelected.AccountTypeCustomer != "" && contactDataSelected.AccountTypeCustomer != undefined) {
				url_new_case += "%2C";
				url_new_case += "Type_of_customer__c" + "%3D" + encodeURIComponent(contactDataSelected.AccountTypeCustomer);
			}
			helper.openUrlOnSubTab(component, url_new_case);
		} else {
			alert("No Contact was selected! Please, choose one contact before create a new case.");
		}
	},
});
