({
	downloadCsv : function(component,event,helper){
        
        var action = component.get("c.getListEU261Cases");

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.dir(response.getReturnValue());
                helper.downloadCSV(component, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})