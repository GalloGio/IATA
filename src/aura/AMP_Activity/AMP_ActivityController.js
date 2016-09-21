({
    doInit : function(component, event, helper) {
        var activity = component.get("v.activity");
        
        if(activity.Id === undefined) {
            component.set("v.isEditMode", true);
        } else {
            component.set("v.isEditMode", false);
        }
    },
    switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        console.log('going into edit mode...');
    },
    cancelEditMode : function(component, event, helper) {
        var activity = component.get("v.activity");
        var index = component.get("v.index");
        
        if(activity.Id === undefined) {
            console.log('something');
            var deleteEvent = component.getEvent("deleteActivity");
            deleteEvent.setParams({ "issue": activity, "index":index }).fire();
            
        } else {
            
            component.set("v.isEditMode", false);
            console.log('canceling edit mode...');
        }
    },
    clickSaveActivity : function(component, event, helper) {
        
        var activity = component.get("v.activity");
        var status = component.find("status").get("v.value");
        activity.Status__c = status;
        
        var deadlineField = component.find("deadline");
        console.log(deadlineField.get("v.value"));
        if(deadlineField.get("v.value") === '') {
            deadlineField.set("v.errors", [{message:"Please enter a date" }]);
            
        } else {
            console.log(JSON.stringify(activity));
            var index = component.get("v.index");
            
            var updateEvent = component.getEvent("updateActivity");
            updateEvent.setParams({ "issue": activity, "index":index }).fire();
            
            component.set("v.isEditMode", false);
        }
        
    },
    HandleActivityError: function(component, event, helper) {
        var componentIndex = event.getParam("index");
        var activityId = event.getParam("activityId");
        console.log('Index ' + component.get("v.index") + ' with activity Id ' + component.get("v.activity").Id + ' is treating error message ');
        
        if (componentIndex == component.get("v.index") && activityId == component.get("v.activity").Id) {
            console.log('Index ' + component.get("v.index") + ' with activity Id ' + activityId + ' is going into error mode... ');
            
            component.set("v.isEditMode", true);
            component.set("v.isError", true);
            component.set("v.errorMessage", event.getParam("errorMessage"));
        }
	},
    deleteItem : function(component, event, helper) {
        // Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list
        
        console.log('delete clicked...');
        var activity = component.get("v.activity");
        console.log(JSON.stringify(activity));
        var index = component.get("v.index");
        
        var deleteEvent = component.getEvent("deleteActivity");
        deleteEvent.setParams({ "issue": activity, "index":index }).fire();
        
        component.set("v.isEditMode", false);
    },
    showMilestones : function(component, event, helper) {
        var activity = component.get("v.activity");
        var index = component.get("v.index");
        var showMilestonesEvent = component.getEvent("showMilestones");
        showMilestonesEvent.setParams({ "issue": activity, "index":index }).fire();
    },
    /**
	 * Handler for receiving the updateLookupIdEvent event
	 */
    handleAccountIssueIdUpdate : function(cmp, event, helper) {
        // Get the Id from the Event
        var activity = cmp.get("v.activity");
        var AccountIssueId = event.getParam("sObjectId");
        activity.Account_Issue_or_Priority__c = AccountIssueId;
        
        // Set the Id bound to the View
        cmp.set("v.activity", activity);
    },
    
    /**
	 * Handler for receiving the clearLookupIdEvent event
	 */
    handleAccountIssueIdClear : function(cmp, event, helper) {
        // Clear the Id bound to the View
        var activity = cmp.get("v.activity");
        activity.Account_Issue_or_Priority__c = null;
        // Set the Id bound to the View
        cmp.set("v.activity", activity);
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
    showMoreBenefits : function(component, event, helper) {
        var benefits = component.find("benefits");
        $A.util.removeClass(benefits, 'slds-truncate');
        $A.util.addClass(benefits, 'popup');
        
        var showMore = component.find("show-more-benefits-button");
        $A.util.addClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-benefits-button");
        $A.util.removeClass(showLess, 'slds-hide');
        $A.util.addClass(showLess, 'popup-button');
    },
    showLessBenefits : function(component, event, helper) {
        var benefits = component.find("benefits");
        $A.util.addClass(benefits, 'slds-truncate');
        $A.util.removeClass(benefits, 'popup');
        
        var showMore = component.find("show-more-benefits-button");
        $A.util.removeClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-benefits-button");
        $A.util.addClass(showLess, 'slds-hide');
        $A.util.removeClass(showLess, 'popup-button');
    }
})