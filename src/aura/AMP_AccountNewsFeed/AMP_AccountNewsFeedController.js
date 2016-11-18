({
	doInit: function(component, event, helper) {
		// helper.getSearchTerm(component);
		helper.getNewsFeed(component);
		helper.highlightSearchTerm(component);
	}
})