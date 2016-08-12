({
	doInit : function(component, event, helper) {
		var bma = component.get("v.bma");
		var dpt = component.get("v.displayType");
		if(dpt === 'Division') {
			console.log(JSON.stringify(bma));
			var comment;
	    if(bma.Comments__r !== undefined) comment = bma.Comments__r[0];
			console.log(JSON.stringify(comment));
		}
		component.set("v.comment",comment);
	},
	switchToEditMode : function(component, event, helper) {
		component.set("v.isEditMode", true);
        console.log('going into edit mode...');
	},
    cancelEditMode : function(component, event, helper) {
		component.set("v.isEditMode", false);
        console.log('canceling edit mode...');
	},
    deleteItem : function(component, event, helper) {
		// Add attribute info, trigger event, handle in AMP_AccountOwnership component - to be able to refresh the list

        console.log('delete clicked...');
	},
	clickSaveComment : function(component, event, helper) {

		var comment = component.get("v.comment");
		console.log(JSON.stringify(comment));
		var index = component.get("v.index");

		var updateEvent = component.getEvent("updateBMA");
		updateEvent.setParams({ "comment": comment, "index":index }).fire();

		component.set("v.isEditMode", false);

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
})