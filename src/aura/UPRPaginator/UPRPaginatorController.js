({
	lastPage: function(cmp, event, helper) {
		var pageChangeEvent = cmp.getEvent("pageChange");
		var currentPage = cmp.get("v.page");
        var lastPage = currentPage - 1;
        pageChangeEvent.setParams({
            "page": lastPage
        });
        pageChangeEvent.fire();
	},
    
    nextPage: function(cmp, event, helper) {
        var pageChangeEvent = cmp.getEvent("pageChange");
		var currentPage = cmp.get("v.page");
        var nextPage = currentPage + 1;
        pageChangeEvent.setParams({
            "page": nextPage
        });
        pageChangeEvent.fire();
    }
})