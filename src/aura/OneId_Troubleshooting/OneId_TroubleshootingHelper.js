({
    submitCase : function(component, event, helper) {
        this.toggleSpinner(component);
        var caseObj = component.get("v.case");

        var isFormValid = true;

        if(component.get("v.subject") == ""){
            component.set("v.subjectMissing", true);
            isFormValid = false;
        }
        if(component.get("v.subject") == "Other" && component.get("v.otherSubject") == ""){
            component.set("v.otherSubjectMissing", true);
            isFormValid = false;
        }
        if(!component.find("description").get("v.validity").valid){
			component.find("description").showHelpMessageIfInvalid();
            isFormValid = false;
        }
        if(component.get("v.isGuestUser")){
            if(!component.find("name").get("v.validity").valid){
                component.find("name").showHelpMessageIfInvalid();
                isFormValid = false;
            }        
            if(!component.find("email").get("v.validity").valid){
                component.find("email").showHelpMessageIfInvalid();
                isFormValid = false;
            }
        }

        if(!isFormValid){
            this.toggleSpinner(component);
            return;
        }
        
        if(component.get("v.subject") != 'Other'){
            caseObj.Subject = component.get("v.subject");
        }
        else{
            caseObj.Subject = component.get("v.otherSubject");
        }
        
        var action = component.get('c.submit');
        action.setParams({
            cse : caseObj
        });
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
				component.set("v.submitted", true);
                this.toggleSpinner(component);
            } else {
                // ERROR 
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error submitting the case"
                });
                toastEvent.fire();
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadEmptyCase : function(component) {
        var action = component.get('c.loadEmptyCase');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var newCase = response.getReturnValue();
                component.set("v.case", newCase);
                this.toggleSpinner(component);
            }else{
                // ERROR 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error loading new case"
                });
                toastEvent.fire();
                this.toggleSpinner(component);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    isGuestUser : function(component) {
        var action = component.get('c.isGuestUser');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set("v.isGuestUser", response.getReturnValue());
            }else{
                // ERROR 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error submitting the question"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    toggleSpinner : function(component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }    
})