({
	searchQueryChange : function(cmp, event, helper) {
		if(event.keyCode == 13){
        	var searchChange = cmp.getEvent("searchChange");
        	searchChange.setParams({
            	"search": event.target.value
        	});
        	searchChange.fire();
        }
	}
})