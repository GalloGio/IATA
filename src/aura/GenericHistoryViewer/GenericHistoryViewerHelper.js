({
	getHistoryRecords : function(component, event, helper) {
        var action = component.get("c.getHistoryRecords");
        
        action.setParams({
            trackedObjId : component.get("v.trackedObjectId"),
            trackerObjApiName : component.get("v.trackerApiName"),
            trackedObjApiName : component.get("v.trackedApiName")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                /*component.set('v.columns', [
                    {label: 'Date', fieldName: 'createdDate', type: 'text'},
                    {label: 'User', fieldName: 'linkToUser', type: 'url', 
                     	typeAttributes: { 
                            label: { fieldName: 'createdByName' }}},
                    {label: 'Action', fieldName: 'description', type: 'html'},
        		]);*/
                component.set("v.data", response.getReturnValue());
                //console.log("result: " + response.getReturnValue());
            }
       	});
                    
        $A.enqueueAction(action);
	}
})