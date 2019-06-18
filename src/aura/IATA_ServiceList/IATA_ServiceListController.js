({
	doInit : function(component, event, helper) {
        component.set("v.lstServicesLength", 0);
        //Get the services list
        var getUserServicesActions = component.get("c.getUserPortalServices");
        getUserServicesActions.setCallback(this, function(response){
        	var state = response.getState();
            
        	if (state === "SUCCESS") {
                var lstServices = response.getReturnValue();
                component.set("v.lstServices", lstServices);
                
                if(lstServices != undefined && lstServices != null){
                    component.set("v.lstServicesLength", lstServices.length);
                }
                component.set("v.localLoading", false);
         	}
      	});
       	$A.enqueueAction(getUserServicesActions);
    }
})