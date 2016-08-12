({
	doInit : function(component, event, helper) {
		var milestone = component.get("v.milestone");

		if(milestone.Id === undefined) {
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
		var milestone = component.get("v.milestone");
		var index = component.get("v.index");

		if(milestone.Id === undefined) {
			var deleteEvent = component.getEvent("deleteMilestone");
			deleteEvent.setParams({ "task": milestone, "index":index }).fire();

		} else {

		component.set("v.isEditMode", false);
				console.log('canceling edit mode...');
			}
	component.set("v.isEditMode", false);
			console.log('canceling edit mode...');
},
clickSaveMilestone : function(component, event, helper) {

	var milestone = component.get("v.milestone");
	var status = component.find("status").get("v.value");
	milestone.Status = status;
	console.log(JSON.stringify(milestone));
	var index = component.get("v.index");

	var updateEvent = component.getEvent("updateMilestone");
	updateEvent.setParams({ "task": milestone, "index":index }).fire();

	component.set("v.isEditMode", false);
	// console.log('seiv');
},
	deleteItem : function(component, event, helper) {
	// Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

		console.log('delete clicked...');
		var milestone = component.get("v.milestone");
		console.log(JSON.stringify(milestone));
		var index = component.get("v.index");

		var deleteEvent = component.getEvent("deleteMilestone");
		deleteEvent.setParams({ "task": milestone, "index":index }).fire();

		component.set("v.isEditMode", false);
},
showMore : function(component, event, helper) {
	var comments = component.find("comments");
	$A.util.removeClass(comments, 'slds-truncate');
	$A.util.addClass(comments, 'popup');

	var showMore = component.find("show-more-button");
	$A.util.addClass(showMore, 'hidden');
	var showLess = component.find("show-less-button");
	$A.util.removeClass(showLess, 'hidden');
	$A.util.addClass(showLess, 'popup-button');
},
showLess : function(component, event, helper) {
	var comments = component.find("comments");
	$A.util.addClass(comments, 'slds-truncate');
	$A.util.removeClass(comments, 'popup');

	var showMore = component.find("show-more-button");
	$A.util.removeClass(showMore, 'hidden');
	var showLess = component.find("show-less-button");
	$A.util.addClass(showLess, 'hidden');
	$A.util.removeClass(showLess, 'popup-button');
},
})