({
	doInit: function(component, event, helper) {
		var issue = component.get("v.issue");

		if(issue.Id === undefined) {
			component.set("v.editMode", true);
		} else {
			component.set("v.editMode", false);
		}

	},
	// delete : function(component, evt, helper) {
  //   var issue = component.get("v.issue");
  //   var deleteEvent = component.getEvent("deleteIssue");
  //   deleteEvent.setParams({ "issue": issue }).fire();
	// },
	switchToEditMode : function(component, event, helper) {
	component.set("v.editMode", true);
			console.log('going into edit mode...');
	},
	cancelEditMode : function(component, event, helper) {
	component.set("v.editMode", false);
			console.log('canceling edit mode...');
	},
	deleteItem : function(component, event, helper) {
	// Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

			console.log('delete clicked...');
			var issue = component.get("v.issue");

			var deleteIssueEvent = component.getEvent("deleteIssue");
			deleteIssueEvent.setParams({'issue' : issue});
			deleteIssueEvent.fire();
			component.set("v.editMode", false);
	},
	/**
	 * Handler for receiving the updateLookupIdEvent event
	 */
	handleSourceIdUpdate : function(cmp, event, helper) {
			// Get the Id from the Event
			var contactId = event.getParam("sObjectId");

			var issue = cmp.get("v.issue");
			issue.AM_Source__c = contactId;
			// Set the Id bound to the View
			cmp.set("v.issue", issue);
	},

	/**
	 * Handler for receiving the clearLookupIdEvent event
	 */
	handleSourceIdClear : function(cmp, event, helper) {
			// Clear the Id bound to the View
			var contact = cmp.get("v.relatedContact");
			contact = null;
			cmp.set("v.relatedContact", contact);

			// Set the Id bound to the View
			var issue = cmp.get("v.issue");
			issue.AM_Source__c = null;
			// issue.AM_Source__r.Name = '';
			// Set the Id bound to the View
			cmp.set("v.issue", issue);
	},
	cancelEdit : function(component, event, helper) {
		var issue = component.get("v.issue");
		console.log(issue.Id);
		if(issue.Id === undefined) {
			console.log('delete');
			var deleteIssueEvent = component.getEvent("deleteIssue");
			deleteIssueEvent.setParams({'issue' : issue});
			deleteIssueEvent.fire();
			component.set("v.editMode", false);
		}
		component.set("v.editMode", false);
	},
	clickSaveIssue : function(component, event, helper) {

		var issue = component.get("v.issue");
		console.log(JSON.stringify(issue));
		var index = component.get("v.index");
		var status = component.find("status").get("v.value");
		var levelOfImportance = component.find("levelOfImportance").get("v.value");
		// var source = component.get("v.relatedContact");

		console.log(status);
		console.log(levelOfImportance);
		issue.Status__c = status;
		issue.AM_Level_of_importance__c = levelOfImportance;
		// issue.AM_Source__c = source.Id;

		var updateEvent = component.getEvent("updateIssue");
		updateEvent.setParams({ "issue": issue, "index":index }).fire();


		component.set("v.editMode", false);

	},
	showMore : function(component, event, helper) {
		var details = component.find("details");
		$A.util.removeClass(details, 'slds-truncate');
		$A.util.addClass(details, 'popup');

		var showMore = component.find("show-more-button");
		$A.util.addClass(showMore, 'hidden');
		var showLess = component.find("show-less-button");
		$A.util.removeClass(showLess, 'hidden');
		$A.util.addClass(showLess, 'popup-button');
	},
	showLess : function(component, event, helper) {
		var details = component.find("details");
		$A.util.addClass(details, 'slds-truncate');
		$A.util.removeClass(details, 'popup');

		var showMore = component.find("show-more-button");
		$A.util.removeClass(showMore, 'hidden');
		var showLess = component.find("show-less-button");
		$A.util.addClass(showLess, 'hidden');
		$A.util.removeClass(showLess, 'popup-button');
	},

	jsLoaded: function(component, event, helper) {
	}
})