({
    doInit : function(component, event, helper) {
        var milestone = component.get("v.milestone");

        if(milestone.Id === undefined) {
            component.set("v.isEditMode", true);
        } else {
            component.set("v.isEditMode", false);
        }

        var statusValues = [];
		statusValues.push('On Track');
        statusValues.push('On Hold');
        statusValues.push('Delayed');
        statusValues.push('Delivered');
        statusValues.push('Cancelled');
        statusValues.push('Not Delivered');

		component.set("v.statusValues", statusValues);
    },


    switchToEditMode : function(component, event, helper) {
        component.set("v.isEditMode", true);
        console.log('going into edit mode...');

        var milestone = component.get("v.milestone");
        var status = milestone.Status;

        var statusValues = component.get("v.statusValues");
        if(status === undefined) status = statusValues[0];

        component.set("v.status", status);
    },
    cancelEditMode : function(component, event, helper) {
        var milestone = component.get("v.milestone");
        if(milestone.Id === undefined) {
            var deleteEvent = component.getEvent("cancelAddMilestone");
            deleteEvent.setParams({'task': milestone});
            deleteEvent.fire();
        } 
        component.set("v.isEditMode", false);
        component.set("v.isError", false);
        console.log('canceling edit mode...');
    },
    HandleMilestoneError: function(component, event, helper) {
        var componentIndex = event.getParam("index");
        var milestoneId = event.getParam("milestoneId");
        console.log('Index ' + component.get("v.index") + ' with milestone Id ' + component.get("v.milestone").Id + ' is treating the error message ');

        if (componentIndex == component.get("v.index") && milestoneId == component.get("v.milestone").Id) {
            console.log('Index ' + component.get("v.index") + ' with milestone Id ' + milestoneId + ' is going into error mode... ');

            component.set("v.isEditMode", true);
            component.set("v.isError", true);
            component.set("v.errorMessage", event.getParam("errorMessage"));
        }
	},
    clickSaveMilestone : function(component, event, helper) {

        var milestone = component.get("v.milestone");
        var status = component.find("statusList").get("v.value");
        var statusValues = component.get("v.statusValues"); 
        if(status === undefined) status = statusValues[0];
        milestone.Status = status;
        
        milestone.Subject = milestone.Subject__c;
        var index = component.get("v.index");

        var updateEvent = component.getEvent("updateMilestone");
        updateEvent.setParams({ "task": milestone, "index":index }).fire();

        component.set("v.isEditMode", false);
    },
    deleteItem : function(component, event, helper) {
        // Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

        console.log('delete clicked...');
        var milestone = component.get("v.milestone");
        var index = component.get("v.index");

        var deleteEvent = component.getEvent("deleteMilestone");
        deleteEvent.setParams({ "task": milestone, "index":index }).fire();

        component.set("v.isEditMode", false);
    }
})