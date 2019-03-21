({
	init : function(component, event, helper) {
		helper.getHistoryRecords(component, event, helper);
	},
    
    navigateToId : function(component, event, helper) {
		var recId = event.currentTarget.dataset.recId;

        sforce.one.navigateToSObject(recId);	
	}
})