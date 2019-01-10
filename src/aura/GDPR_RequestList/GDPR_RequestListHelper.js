({
	retrieveCases : function(component) {
		//Get the cases list
        var getUserServicesActions = component.get("c.getUserCases");
        getUserServicesActions.setCallback(this, function(response){
        	var state = response.getState();
        	if (state === "SUCCESS") {
                var lstCases = response.getReturnValue();
                component.set("v.lstCases", lstCases);
                
                if(lstCases != undefined && lstCases != null){
                    component.set("v.lstCasesLength", lstCases.length);
                }
                component.set("v.localLoading", false);
         	}
      	});
       	$A.enqueueAction(getUserServicesActions);
	}
})