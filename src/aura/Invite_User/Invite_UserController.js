({
    doInit : function(cmp, event, helper) {
    	helper.currentUserType(cmp);
	},

    validateNumber : function(component, event, helper){
        let input = document.querySelector("#phone");
        helper.validateNumber(component, input);
    },

    validateMobileNumber : function(component, event, helper){
        let input = document.querySelector("#mobilePhone");
        helper.validateNumber(component, input);
    },

    validateFaxNumber : function(component, event, helper){
        let input = document.querySelector("#faxPhone");
        helper.validateNumber(component, input);
    },

    back : function(component, event, helper) {        
        let myEvent = component.getEvent("Back_EVT");
        myEvent.setParams({
            'dataModified' : false,
            'page' : 'invitation'
        });
        myEvent.fire();
    },

    scriptsLoaded: function(component, event, helper){
        console.log('scripts loaded');
    },

    changedCountry : function(component, event , helper){
        if(! $A.util.isEmpty(component.get('v.userCountry'))) {
            helper.placePhoneFlags(component, component.get("v.userCountry"));
        }
    },

    backToEmailField : function(component, event, helper) {
        $A.util.removeClass(component.find('form'), 'slds-hide');
        $A.util.addClass(component.find('sent'), 'slds-hide');
        $A.util.addClass(component.find("emailExists"), 'slds-hide');
        $A.util.addClass(component.find("detail"), 'slds-hide');
        let invitation = component.get('v.invitation');
        invitation.Email__c = ''
        //component.set('v.invitation', invitation);

        let emailField = component.find('email');
        if(! $A.util.isEmpty(emailField)) {
            emailField.set('v.disabled', false);
        }
        component.set('v.showBack', false);
        $A.util.addClass(component.find("emailError"), 'slds-hide');
        //reset the combo-box error message
        helper.hideErrors(component, event, helper);
    },

    inviteUser : function(cmp, event, helper) {
        let phoneNumber = document.querySelector("#phone").value;
        let mobileNumber = document.querySelector("#mobilePhone").value;
        let faxNumber = document.querySelector("#faxPhone").value;

        let invitation = cmp.get('v.invitation');
        invitation.Business_Phone__c = phoneNumber;
        invitation.Mobile_Phone__c = mobileNumber;
        invitation.Business_Fax__c = faxNumber;

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
                    let emailField = cmp.find('email');
                    if(! $A.util.isEmpty(emailField)) {
                        emailField.set('v.disabled', true);
                    }
                    cmp.set('v.showBack', true);
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
                    cmp.set('v.showBack', true);
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