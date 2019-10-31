({
    init : function(component){
        var action = component.get('c.initialize');
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var userInformation = response.getReturnValue();
                component.set("v.ndcCapabilities", userInformation.ndcCapabilities);
                component.set("v.displayRichContentTypes", userInformation.displayRichContentTypes);
                component.set("v.displayTypesOfCCAccepted", userInformation.displayTypesOfCCAccepted);
                var submittableForApproval = userInformation.ndcCapabilities.Submittable_for_Approval__c == true;
                component.set("v.submittableForApproval", submittableForApproval);
                var submittedForApproval = userInformation.ndcCapabilities.Submitted_for_Approval__c == true;
                component.set("v.submittedForApproval", submittedForApproval);
                component.set("v.usr", userInformation.usr);
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
    },
        
    getUser : function(component){
        var action = component.get('c.getUser');
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set("v.usr", response.getReturnValue());
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
    },
    
    getNDCCapabilities : function(component){
        var action = component.get('c.getNDCCapabilities');
        action.setParams({
            usr : component.get("v.usr")
        });
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set("v.ndcCapabilities", response.getReturnValue());
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
    },
        
    toggleSpinner : function(component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }
})