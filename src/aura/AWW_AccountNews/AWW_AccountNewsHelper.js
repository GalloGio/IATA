({
    getNewsFeed : function(component) {
        var action= component.get("c.getNewsFeedBaseOnId");
		var accountId = component.get("v.accountId");


		action.setParams({
			"accountId": accountId
		});
		action.setCallback(this, function(actionResult) {
			var JSONrssData = actionResult.getReturnValue();
			component.set("v.data", actionResult.getReturnValue());
		});
		$A.enqueueAction(action); 
	},
	initTable : function(component) {
		component.set('v.columns', [
			{label: 'Time', fieldName: 'dateString', type: 'text'},
			{label: 'Title', fieldName: 'link', type: 'url', typeAttributes: {label: {fieldName: 'title'}}, target: '_blank'},
			{label: 'Description', fieldName: 'description', type: 'text'}
        ]);
	}
})