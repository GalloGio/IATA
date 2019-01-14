({
	doInit : function(component, event, helper) {
		var bma = component.get("v.bma");
		var dpt = component.get("v.displayType");
		if(dpt === 'Division') {
			var comment;
	    if(bma.Comments__r !== undefined) comment = bma.Comments__r[0];
		component.set("v.comment",comment);
		}

		var statusValues = [];
		statusValues.push('On Track');
		statusValues.push('On Hold');
		statusValues.push('Delayed');
		statusValues.push('Delivered');
		statusValues.push('Canceled');
		statusValues.push('Not Delivered');

		component.set("v.statusValues", statusValues);

	},

	switchToEditMode : function(component, event, helper) {
		component.set("v.isEditMode", true);
        console.log('going into edit mode...');
var status = component.get("v.status");
		var comment = component.get("v.comment");
		if(comment !== undefined) {

		console.log('--------- ' + JSON.stringify(comment));
		status = comment.Status__c;
	}
		if(status === undefined) status = 'On Track';
		console.log(status);

		// var status = component.find("comment").get("v.value");
		component.set("v.status", status);
		// console.log('status: ' + status);
	},
    cancelEditMode : function(component, event, helper) {
		component.set("v.isEditMode", false);
        component.set("v.isError", false);
        console.log('canceling edit mode...');
	},    
    HandleBMAError: function(component, event, helper) {
        var componentIndex = event.getParam("index");
        var bmaId = event.getParam("bmaId");
        //console.log('Index ' + component.get("v.index") + ' with BMA Id ' + component.get("v.bma").Id + ' is treating error message ');
        
        if (componentIndex == component.get("v.index") && bmaId == component.get("v.bma").Id) {
            console.log('Index ' + component.get("v.index") + ' with BMA Id ' + bmaId + ' is going into error mode... ');
            
            component.set("v.isEditMode", true);
            component.set("v.isError", true);
            component.set("v.errorMessage", event.getParam("errorMessage"));
        }
	},
    deleteItem : function(component, event, helper) {
		// Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

        console.log('delete clicked...');
	},
	clickSaveComment : function(component, event, helper) {

		var comment = component.get("v.comment");
		var accountId = component.get("v.accountId");
		var objective = component.get("v.bma");
		var detail = component.find("detail").get("v.value");
		console.log('c: ' + detail);

		if(comment === undefined) {
			var comment = {'sobjectType':'Comment__c', 'Account__c': accountId, 'Parent_Objective__c': objective.Id, 'Detail__c':detail};
		}
		// if(comment.Account__c ===undefined) comment.Account__c = accountId;
		console.log('--------- ' + JSON.stringify(comment));
        comment.Status__c = component.find("accountStatus").get("v.value");
		
		var index = component.get("v.index");

		var updateEvent = component.getEvent("updateBMA");
		updateEvent.setParams({ "comment": comment, "index":index }).fire();

		component.set("v.status", comment.Status__c);
		component.set("v.isEditMode", false);

	}
})