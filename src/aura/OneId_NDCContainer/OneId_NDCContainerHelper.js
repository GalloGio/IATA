({
	init : function(component){
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var userInformation = response.getReturnValue();
                console.log(userInformation);
                component.set("v.isGuestUser", userInformation.isGuestUser);
                component.set("v.accessRequested", userInformation.accessRequested);
                component.set("v.accessStatus", userInformation.accessStatus);
                component.set("v.pendingAccessReason", userInformation.pendingAccessReason);
                component.set("v.termsAndConditionsId", userInformation.tcDocumentId);
                component.set("v.termsAndConditionsException", userInformation.exceptionTC);
                component.set("v.termsAndConditionsAcceptance", userInformation.tcAcceptance);
                if(userInformation.ndcCapabilities.NDC_Capable__c) {
                    component.set("v.ndcCapable", userInformation.ndcCapabilities.NDC_Capable__c);
                }
                if(!userInformation.isGuestUser
                   && userInformation.accessRequested
                   && userInformation.accessStatus == 'Access Granted'
                   && userInformation.exceptionTC == ''){
                    // set which depending fields will be displayed in edit mode
                    var displayRichContentTypes = userInformation.ndcCapabilities.NDC_Rich_Content__c == 'Yes';
                    component.set("v.displayRichContentTypes", displayRichContentTypes);
                    
                    if(userInformation.ndcCapabilities.NDC_Forms_of_Payment_Accepted__c) {
                        var displayTypesOfCCAccepted = userInformation.ndcCapabilities.NDC_Forms_of_Payment_Accepted__c.indexOf('Credit Cards') >= 0;
                        component.set("v.displayTypesOfCCAccepted", displayTypesOfCCAccepted);
                    }
                }
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