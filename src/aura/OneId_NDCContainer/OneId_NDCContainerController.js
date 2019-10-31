({
	doInit: function(component, event, helper) {
        $A.get("event.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
		helper.init(component);
    },
    
    acceptTC : function(component, event, helper){
        var action = component.get('c.acceptTermsAndConditions');
        action.setParams({
            tcAcceptance : component.get("v.termsAndConditionsAcceptance")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set("v.termsAndConditionsAcceptance", response.getReturnValue());
                component.set("v.exceptionTC", "");
                helper.getUser(component);
                helper.getNDCCapabilities(component);
            }else{
                // ERROR 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error during initialization"
                });
                toastEvent.fire();
            }
            this.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    }
})