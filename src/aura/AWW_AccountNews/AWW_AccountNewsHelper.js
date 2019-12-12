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
			{label: 'Time', fieldName: 'dateString', type: 'text', sortable : true},
			{label: 'Title', fieldName: 'link', type: 'url', sortable : true, typeAttributes: {label: {fieldName: 'title'}}, target: '_blank'},
			{label: 'Description', fieldName: 'description', type: 'text', sortable : true}
        ]);
	},
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.data');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { 
			if(fieldName == 'link') {
				fieldName = 'title';
			} 
			if(fieldName == 'dateString') {
				fieldName = 'timeStamp'
			}
			return a[fieldName];
		}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
    }
})