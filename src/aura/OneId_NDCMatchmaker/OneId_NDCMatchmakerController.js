({
    doInit: function(component, event, helper) {
        $A.get("event.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        helper.init(component);
    },

	renderPage : function (component, event, helper){
        var state = event.getParam("state");
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
            }
        }
    },
    
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        component.find('myform').submit(eventFields);
    },
    
    handleSuccess : function(component, event, helper) {
		component.set("v.isEditMode", false);
		component.set("v.submittableForApproval", true);        
    },
    
    handleCancel : function(component, event, helper) {
		component.set("v.isEditMode", false);
	},
    
    handleEdit : function(component, event, helper) {
		component.set("v.isEditMode", true);
	},
    
    handleSubmitForApproval : function(component, event, helper) {
        helper.toggleSpinner(component);
        
        var action = component.get('c.submitCaseForApproval');        
        action.setCallback(this, function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state === 'SUCCESS' && component.isValid() && response.getReturnValue()){
                // SUCCESS
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Your case has been successfully submitted."
                });
                toastEvent.fire();
				component.set("v.submittedForApproval", true);
                helper.toggleSpinner(component);
            } else {
                // ERROR 
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error submitting the case"
                });
                toastEvent.fire();
                helper.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

	checkRichContent : function(component, event, helper) {
		var display = component.find("NDC_Rich_Content__c").get("v.value") == 'Yes';
        component.set("v.displayRichContentTypes", display);
	},

	checkFormsOfPaymentAccepted : function(component, event, helper) {
		var display = component.find("NDC_Forms_of_Payment_Accepted__c").get("v.value").indexOf('Credit Cards') >= 0;
        component.set("v.displayTypesOfCCAccepted", display);
	},
    
    showRequiredFields: function(component, event, helper){
    	$A.util.removeClass(component.find("Contact_Person__c"), "none");
    	$A.util.removeClass(component.find("Contact_Email__c"), "none");
    	$A.util.removeClass(component.find("NDC_Schema_Version__c"), "none");
        $A.util.removeClass(component.find("NDC_Servicing__c"), "none");
    	$A.util.removeClass(component.find("NDC_Types_of_Fares__c"), "none");
    	$A.util.removeClass(component.find("NDC_Forms_of_Payment_Accepted__c"), "none");
    	$A.util.removeClass(component.find("NDC_Forms_of_Remittance_and_Settlement__c"), "none");
    	$A.util.removeClass(component.find("NDC_Products_and_Services__c"), "none");
    	$A.util.removeClass(component.find("NDC_Type_of_Connectivity__c"), "none");
    	$A.util.removeClass(component.find("NDC_Rich_Content__c"), "none");
    	$A.util.removeClass(component.find("NDC_Rich_Content_Types__c"), "none");
    	$A.util.removeClass(component.find("NDC_Personalisation__c"), "none");
    	$A.util.removeClass(component.find("NDC_Airline_Profile__c"), "none");
    	$A.util.removeClass(component.find("NDC_Content_Differentiation__c"), "none");
    	$A.util.removeClass(component.find("Content_Differentiation_Products_and_Se__c"), "none");
    	$A.util.removeClass(component.find("NDC_Type_of_CC_Accepted__c"), "none");
    	$A.util.removeClass(component.find("NDC_Other_Products_and_Services__c"), "none");
    }
})