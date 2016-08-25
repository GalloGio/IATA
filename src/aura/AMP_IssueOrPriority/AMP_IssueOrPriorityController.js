({
    doInit: function(component, event, helper) {
        var issue = component.get("v.issue");
        
        if(issue.Id === undefined) {
            component.set("v.isEditMode", true);
        } else {
            component.set("v.isEditMode", false);
        }
        
    },
    // delete : function(component, evt, helper) {
    //   var issue = component.get("v.issue");
    //   var deleteEvent = component.getEvent("deleteIssue");
    //   deleteEvent.setParams({ "issue": issue }).fire();
    // },
    switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        console.log('going into edit mode...');
    },
    cancelEditMode : function(component, event, helper) {
        var issue = component.get("v.issue");
        if(issue.Id === undefined) {
            console.log('cancel add new issue -> delete');
            var deleteIssueEvent = component.getEvent("deleteIssue");
            deleteIssueEvent.setParams({'issue' : issue});
            deleteIssueEvent.fire();
        }
        component.set("v.isEditMode", false);
    },
    deleteItem : function(component, event, helper) {
        // Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list
        
        console.log('delete clicked...');
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
        var status = component.find("status").get("v.value");
        var levelOfImportance = component.find("levelOfImportance").get("v.value");
        // var source = component.get("v.relatedContact");
        
        issue.Status__c = status;
        issue.AM_Level_of_importance__c = levelOfImportance;
        // issue.AM_Source__c = source.Id;
        
        var updateEvent = component.getEvent("updateIssue");
        updateEvent.setParams({ "issue": issue, "index":index }).fire();        
        
        component.set("v.isEditMode", false);        
    },
    showMore : function(component, event, helper) {
        var details = component.find("details");
        $A.util.removeClass(details, 'slds-truncate');
        $A.util.addClass(details, 'popup');
        
        var showMore = component.find("show-more-button");
        $A.util.addClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-button");
        $A.util.removeClass(showLess, 'slds-hide');
        $A.util.addClass(showLess, 'popup-button');
    },
    showLess : function(component, event, helper) {
        var details = component.find("details");
        $A.util.addClass(details, 'slds-truncate');
        $A.util.removeClass(details, 'popup');
        
        var showMore = component.find("show-more-button");
        $A.util.removeClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-button");
        $A.util.addClass(showLess, 'slds-hide');
        $A.util.removeClass(showLess, 'popup-button');
    },
    
    jsLoaded: function(component, event, helper) {
    }
})