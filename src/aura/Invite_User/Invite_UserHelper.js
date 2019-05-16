({		
    validateEmail :function(component) {
		$A.util.addClass(component.find("emailError"), 'slds-hide');
        $A.util.addClass(component.find("emailExists"), 'slds-hide'); 
        $A.util.addClass(component.find("detail"), 'slds-hide');
        
        var emailCmp = component.find("email");
        var emailValue = emailCmp.get("v.value");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        if($A.util.isEmpty(emailValue)) {
            $A.util.removeClass(component.find("emailError"), 'slds-hide');                 	
            component.set("v.emailInputError", $A.get("$Label.c.ISSP_EmailError"));
            return false;
        } else if(! emailValue.match(regExpEmailformat)) {
            $A.util.removeClass(component.find("emailError"), 'slds-hide');          
            component.set("v.emailInputError", $A.get("$Label.c.ISSP_AMS_Invalid_Email"));           
            return false;
        } else { 
            $A.util.removeClass(component.find("emailError"), 'slds-hide');          
            component.set("v.emailInputError", "");
            return true;
        }
    },
    contactLabels: function(component) {
        var action = component.get("c.getContactLabels");
        action.setCallback(this, function(a) {
            component.set("v.contactLabels", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    jobFunctionOptions: function(component) {
        var action = component.get("c.getContactJobFunctionValues");
        action.setCallback(this, function(a) {
            component.set("v.jobFunctionOptions", a.getReturnValue());
            console.log(a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    getActors: function(component) {
        let action = component.get('c.getUserAccounts');        
        action.setCallback(this, function(action) {
            
            let actors = action.getReturnValue();
                        if(! $A.util.isEmpty(actors)) {
                            let actorsData = [];
                            for (let i = 0; i < actors.length; i++) { 
                                console.log(actors[i]);
                              actorsData.push({'label':actors[i].Name, 'value':actors[i].Id});
                            }                              
                            component.set('v.actors', actorsData);
                            component.set('v.invitation.AccountId__c', actors[0].Id);
                            
                        }           
        });
        $A.enqueueAction(action);
	}
})