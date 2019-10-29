({
	retrieveDPOCase : function(component) {
		//Get the cases list
                    var getUserServicesActions = component.get("c.getUserCasesDPO");
                    getUserServicesActions.setCallback(this, function(responseTwo){
                        var state = responseTwo.getState();
                        
                        if (state === "SUCCESS") {
                            var lstCases = responseTwo.getReturnValue();
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