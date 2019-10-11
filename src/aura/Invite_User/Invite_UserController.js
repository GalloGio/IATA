({
    doInit : function(cmp, event, helper) {
    	helper.currentUserType(cmp);
        helper.contactLabels(cmp);
    	helper.jobFunctionOptions(cmp);
        //helper.getActors(cmp);        
	},
    validateNumber : function(c, e, h){
        var input = c.find(e.getSource().getLocalId());
        input.set("v.value", input.get("v.value").replace(/[^0-9+]|(?!^)\+/g, ''));
    },
    back : function(component, event, helper) {        
        let myEvent = component.getEvent("Back_EVT");
        myEvent.setParams({
            'dataModified' : false,
            'page' : 'invitation'
        });
        myEvent.fire();
    },

    backToEmailField : function(component, event, helper) {
        $A.util.removeClass(component.find('form'), 'slds-hide');
        $A.util.addClass(component.find('sent'), 'slds-hide');
        $A.util.addClass(component.find("emailExists"), 'slds-hide');
        $A.util.addClass(component.find("detail"), 'slds-hide');
        let invitation = component.get('v.invitation');
        invitation.Email__c = ''
        component.set('v.invitation', invitation);
    },

    inviteUser : function(cmp, event, helper) {
        debugger;
        helper.handleInviteUser(cmp, event);
	},
 
	checkUsername :function (cmp, event, helper) {
	    helper.toggleSpinner(cmp);
        if(helper.validateEmail(cmp)){

        var emailCmp = cmp.find("email");
        var emailValue = emailCmp.get("v.value");
        var serviceName = "GADM";

        if(serviceName == null){
            console.log('Warning : No service name provided!');
        }

        //check if username is available (insert + rollback)
        var action = cmp.get("c.getUserInformationFromEmail");

        action.setParams({
            "email":emailValue,
            "serviceName": serviceName
        });
        action.setCallback(this, function(resp) {
            var params = resp.getReturnValue();
            
            cmp.set("v.contact", params.contact);
            cmp.set("v.invitation", params.invitation);

            if(params.showNotifyButton){
                $A.util.removeClass(cmp.find("notifyUserButton"), 'slds-hide');
            } else {
                $A.util.addClass(cmp.find("notifyUserButton"), 'slds-hide');
            }
            
            if(params.createNewInvitation){
				$A.util.addClass(cmp.find("emailExists"), 'slds-hide'); 
                $A.util.removeClass(cmp.find("detail"), 'slds-hide');
                cmp.set('v.sendNotification', false);
            } else {
                $A.util.removeClass(cmp.find("emailExists"), 'slds-hide'); 
                $A.util.addClass(cmp.find("detail"), 'slds-hide');
                cmp.set('v.sendNotification', true);
            }

            helper.toggleSpinner(cmp);
        });
        $A.enqueueAction(action);
        }else{

            helper.toggleSpinner(cmp);
        }        
    },

    checkActorDomains : function(component, event, helper) {
        helper.handleCheckActorDomains(component, event);
    },

})