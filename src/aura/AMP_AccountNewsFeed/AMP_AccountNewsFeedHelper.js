({

	getNewsFeed : function(component) {
		var action= component.get("c.getNewsFeedBaseOnId");
		var accountId = component.get("v.accountId");


		action.setParams({
			"accountId": accountId
		});
		action.setCallback(this, function(actionResult) {
			var JSONrssData = actionResult.getReturnValue();
			for(var i = 0; i < JSONrssData.length; i++) {
				// console.log(JSON.stringify(JSONrssData[i]));
				JSONrssData[i].description = JSONrssData[i].description.replace(/&#39;/g,'\'').substring(0,100);
			}
				component.set("v.newsfeed", actionResult.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	highlightSearchTerm : function(component) {
		var action= component.get("c.getAccountName");
		var accountId = component.get("v.accountId");

		action.setParams({
			"accountId": accountId
		});
		var searchTerm;
		action.setCallback(this, function(actionResult) {
			searchTerm = actionResult.getReturnValue();
			searchTerm = searchTerm.replace('+',' ');
			console.log(searchTerm);
			var replaceWith = '<b>'+searchTerm+'</b>'.replace('+',' ');
			var newsfeed = component.get("v.newsfeed");
			for(var i = 0; i < newsfeed.length; i++) {
				newsfeed[i].description = newsfeed[i].description.replace(searchTerm,replaceWith);
			}
			component.set("v.newsfeed", newsfeed);
		});
		$A.enqueueAction(action);
	}
})