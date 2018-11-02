({
    doInit: function(component, event, helper) {
        var issue = component.get("v.issue");
        var divisionValues = component.get("v.divisionValues");

        if(issue.Id === undefined) {
            component.set("v.isEditMode", true);
            helper.fillDivisionOptions(component, divisionValues, issue.Division__c);
        } else {
            component.set("v.isEditMode", false);
        }

        var importanceValues = [];
        importanceValues.push('High');
        importanceValues.push('Medium');
        importanceValues.push('Low');

        component.set("v.importanceValues", importanceValues);

        var statusValues = [];
		statusValues.push('Open');
		statusValues.push('Closed');
		statusValues.push('Out Of Scope');

		component.set("v.statusValues", statusValues);


    },
    // delete : function(component, evt, helper) {
    //   var issue = component.get("v.issue");
    //   var deleteEvent = component.getEvent("deleteIssue");
    //   deleteEvent.setParams({ "issue": issue }).fire();
    // },
    switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        console.log('going into edit mode...');

        var issue = component.get("v.issue");
        var status = issue.Status__c;
        var importance = issue.AM_Level_of_importance__c;
        console.log(JSON.stringify(issue));
        var levelOfImportanceValues = component.get("v.importanceValues");
        var statusValues = component.get("v.statusValues");
        // var source = component.get("v.relatedContact");
        if(status === undefined) status = statusValues[0];
        if(importance === undefined) importance = levelOfImportanceValues[0];
        component.set("v.status", status);
        component.set("v.importance", importance);
		// if(status === undefined) status = 'On Track';
		console.log(status);

        var divisionValues = component.get("v.divisionValues");
        var division = issue.Division__c;
        helper.fillDivisionOptions(component, divisionValues, division);

    },
    cancelEditMode : function(component, event, helper) {
        var issue = component.get("v.issue");
        if(issue.Id === undefined) {
            console.log('cancel add new issue -> delete');
            var deleteIssueEvent = component.getEvent("cancelAddIssue");
            deleteIssueEvent.setParams({'issue' : issue});
            deleteIssueEvent.fire();
        }
        component.set("v.isEditMode", false);
    },
    deleteItem : function(component, event, helper) {
        // Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

        console.log('delete OK clicked...');
        var issue = component.get("v.issue");

        var deleteIssueEvent = component.getEvent("deleteIssue");
        deleteIssueEvent.setParams({'issue' : issue});
        deleteIssueEvent.fire();
        component.set("v.isEditMode", false);
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

        if(issue.Id === undefined) {
            console.log('delete');
            var deleteIssueEvent = component.getEvent("deleteIssue");
            deleteIssueEvent.setParams({'issue' : issue});
            deleteIssueEvent.fire();
            component.set("v.isEditMode", false);
        }
        component.set("v.isEditMode", false);
    },
    HandleIssueOrPriorityError: function(component, event, helper) {
        var componentIndex = event.getParam("index");
        var issueId = event.getParam("issueId");
        //console.log('Index ' + component.get("v.index") + ' with account issue Id ' + component.get("v.issue").Id + ' is treating error message ');

        if (componentIndex == component.get("v.index") && issueId == component.get("v.issue").Id) {
            console.log('Index ' + component.get("v.index") + ' with account role Id ' + issueId + ' is going into error mode... ');

            component.set("v.isEditMode", true);
            component.set("v.isError", true);
            component.set("v.errorMessage", event.getParam("errorMessage"));
        }
	},
    clickSaveIssue : function(component, event, helper) {

        var issue = component.get("v.issue");
        var index = component.get("v.index");

        var status = component.find("statusList").get("v.value");
        console.log(status);
        var levelOfImportance = component.find("levelOfImportance").get("v.value");

         //division
        var division = component.find("divisionList").get("v.value");
        issue.Division__c = division;

        // if the picklists are not changed, the previous variables may be empty
        // so we take the first values of the lists
        var levelOfImportanceValues = component.get("v.importanceValues");
        var statusValues = component.get("v.statusValues");
        if(status === undefined) status = statusValues[0];
        if(levelOfImportance === undefined) levelOfImportance = levelOfImportanceValues[0];
        console.log(status);

        if(status !== undefined) issue.Status__c = status;
        if(levelOfImportance !== undefined) issue.AM_Level_of_importance__c = levelOfImportance;
        console.log('2 ' + JSON.stringify(issue));
        
        var updateEvent = component.getEvent("updateIssue");
        updateEvent.setParams({ "issue": issue, "index":index }).fire();

        component.set("v.isEditMode", false);
    }
})
