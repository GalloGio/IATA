({
    placePhoneFlags : function(component, country){
        let input = document.querySelector("#phone");
        window.intlTelInput(input, {
            initialCountry: country,
            preferredCountries: [country],
            placeholderNumberType : 'FIXED_LINE',
        });

        let input2 = document.querySelector("#mobilePhone");
        window.intlTelInput(input2, {
            initialCountry: country,
            preferredCountries: [country],
            placeholderNumberType : 'MOBILE',
        });

        let input3 = document.querySelector("#faxPhone");
        window.intlTelInput(input3, {
            initialCountry: country,
            preferredCountries: [country],
            placeholderNumberType : 'FIXED_LINE',
        });

        this.adjustPhoneFields(component);
    },

    validateNumber : function(component, input) {
        let replaced = input.value.replace(/[^0-9+]|(?!^)\+/g, '');
        input.value = replaced;
    },

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
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.contactLabels", response.getReturnValue());
                this.jobFunctionOptions(component);
            }else{
               this.toggleSpinner(component);
               this.showToast(component, 'error', 'Unexpected error.', 'Unable to load data.');
               console.log('Invite User: contactLabels error') ;
            }
        });
        $A.enqueueAction(action);
    },
    currentUserType: function(component) {
        this.toggleSpinner(component);
        var action = component.get("c.getCurrenthUserInfo");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.userType", response.getReturnValue().UserType);
                this.getActors(component);
                this.contactLabels(component);
            }else{
                this.toggleSpinner(component);
                this.showToast(component, 'error', 'Unexpected error.', 'Unable to load data.');
                console.log('Invite User: currentUserType error');
            }
        });
        $A.enqueueAction(action);
    },


    adjustPhoneFields : function(component) {
        let userType = component.get('v.userType');
        if('Standard' === userType) {
            let phones = document.querySelectorAll(".iti");
            for(let i = 0; i < phones.length; i++) {
                phones[i].classList.add("phoneInternal");
            }
        }
    },

    jobFunctionOptions: function(component) {
        var action = component.get("c.getContactJobFunctionValues");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.jobFunctionOptions", response.getReturnValue());
                component.set('v.showPage', true);
                this.toggleSpinner(component);
                this.getUserCountry(component);
            }else{
                this.toggleSpinner(component);
                this.showToast(component, 'error', 'Unexpected error.', 'Unable to load data.');
                console.log('Invite User: jobFunctionOptions error');
            }
        });
        $A.enqueueAction(action);
    },

    getUserCountry : function(component) {
        var action = component.get("c.findLocation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let contactCountry = response.getReturnValue();
                console.log('contact country: ' + contactCountry);
                component.set("v.userCountry",contactCountry);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("IP Search: Error message: " + errors[0].message);
                    }
                } else {
                    console.error("IP Search: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    handleInviteUser : function(component, event) {
        if(this.checkRequiredFields(component, event)) {
            this.toggleSpinner(component);
            let action = component.get("c.sendInvitation");

            action.setParams({
                "contactStr": JSON.stringify(component.get("v.contact")),
                "invitationStr": JSON.stringify(component.get("v.invitation"))
            });
            action.setCallback(this, function(response) {
                const state = response.getState();
                if(state === 'SUCCESS') {
                    const result = response.getReturnValue();
                    if(result === 'sent') {//OK
                        console.log('sent');

                        this.toggleSpinner(component);
                        $A.util.addClass(component.find('form'), 'slds-hide');
                        $A.util.removeClass(component.find('sent'), 'slds-hide');

                    }else{//error
                        console.log('invite user error');
                        this.toggleSpinner(component);
                        this.showToast(component, 'error', 'Unexpected error.', $A.get("$Label.c.GADM_Invite_User_invitation_error"));
                    }

                }else{//error
                    console.log('invite user error');
                    this.toggleSpinner(component);
                    this.showToast(component, 'error', 'Unexpected error.', $A.get("$Label.c.GADM_Invite_User_invitation_error"));
                }

            });
            $A.enqueueAction(action);
        }
    },

    checkRequiredFields : function(component, event) {
        let valid = false;
        //actor does not need to be filled
        let sendNotification = component.get('v.sendNotification');
        if(sendNotification) {
            return true;
        }

        let actor =  component.find('actor');
        console.log(actor);
        if(! $A.util.isEmpty(actor)) {
            let value = actor.get('v.value');
            if(!$A.util.isEmpty(value)) {
                valid =true;
            }else{
               actor.showHelpMessageIfInvalid();
            }
        }

        return valid;
    },

    hideErrors : function(component, event, helper) {
        var actor = component.find("actor");
        $A.util.removeClass(actor, "slds-has-error"); // remove red border
        $A.util.addClass(actor, "hide-error-message"); // hide error message
        var elements = document.getElementsByClassName("slds-form-element__help");
        console.log(elements[0].innerText);
    },

    getActors: function(component) {
        let userType = component.get('v.userType');
        if(userType === 'Standard') {
            this.getActorsForInternalUser(component, event);            
        }else{
            this.getActorsForExternalUser(component, event);
        }

	},

	getActorsForExternalUser : function(component, event) {
	    console.log('v.invitation.AccountId__c');
	    let action = component.get('c.getUserAccounts');
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
               let actors = response.getReturnValue();
               if(! $A.util.isEmpty(actors)) {
                   let actorsData = [];
                   for (let i = 0; i < actors.length; i++) {
                        actorsData.push({'label':actors[i].Name, 'value':actors[i].Id});
                   }
                   component.set('v.actors', actorsData);
                   component.set('v.invitation.AccountId__c', actors[0].Id);
                   this.handleGetActorsAllowedDomains(component, event, actors);
                   console.log(component.get('v.invitation.AccountId__c'));
               }
            }
        });
        $A.enqueueAction(action);

	},

	getActorsForInternalUser : function(component, event) {
	    console.log(component.find('actor'));
	    let action = component.get('c.getGadmActors');
	    action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const actors = response.getReturnValue();
                if(! $A.util.isEmpty(actors)) {
                    let actorsData = [];
                    for (let i = 0; i < actors.length; i++) {
                        actorsData.push({'label':actors[i].Name, 'value':actors[i].Id});
                    }
                    component.set('v.actors', actorsData);
                    component.set('v.invitation.AccountId__c', actors[0].Id);
                    this.handleGetActorsAllowedDomains(component, event, actors);
                    console.log(component.get('v.invitation.AccountId__c'));
                     console.log(component.find('actor'));
                }
            }
         });
         $A.enqueueAction(action);

	},

	handleGetActorsAllowedDomains : function(component, event, actors) {
	    let action = component.get('c.getActorsAllowedDomains');
        action.setParams({
            'actors' : JSON.stringify(actors)
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    component.set('v.allowedDomains', result);

                }else{
                    console.log('handleGetActorsAllowedDomains error');
                    this.disableContent(component, event);
                    this.showToast(component, 'error', 'Unexpected error.', $A.get("$Label.c.GADM_Invite_User_invitation_no_data"));
                }
            }else{
                console.log('handleGetActorsAllowedDomains error');
                this.disableContent(component, event);
                this.showToast(component, 'error', 'Unexpected error.', $A.get("$Label.c.GADM_Invite_User_invitation_no_data"));
            }
        });
        $A.enqueueAction(action);
	},


	handleCheckActorDomains : function(component, event) {
	    const allowedDomains = component.get('v.allowedDomains');
	    let selectedActor = event.getSource().get('v.value');

	    let actorAllowedDomains = allowedDomains[selectedActor];

	    let email = component.get('v.invitation.Email__c');
	    let start = email.indexOf('@');
	    let domain = email.slice(start+1);

	    if(! actorAllowedDomains.includes(domain)) {
	        component.set('v.emailInputError', $A.get("$Label.c.GADM_Invite_User_not_allowed_email_domain"));
	    }else{
	        component.set('v.emailInputError', '');
	    }

	},

	showToast : function(component, type, title, message) {
        let isLightning = component.get('v.theme') === 'Theme4d';
        if(isLightning) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": type,
                "title": title,
                "message": message
            });
            toastEvent.fire();
        }else{
            let toastMessageEvent = $A.get("e.c:Invite_User_Message_EVT");
            if(toastMessageEvent) {
                toastMessageEvent.setParams({
                    "heading" : title,
                    "message" : message,
                    "messageType" : type
                });
                toastMessageEvent.fire();
            }

        }
    },

	toggleSpinner : function(component) {
	    component.set('v.showSpinner', !component.get('v.showSpinner'));
    },

    disableContent : function(component, event) {
        let userType = component.get('v.userType');
        if(userType === 'Standard') {
            let form = component.find('form');
            form.getElement().classList.add('disabled');
        }else{
            let form = component.find('form');
            let container = component.find('v.container');
            $A.util.removeClass(container, 'slds-hide');
            $A.util.addClass(form, 'disabled');            
        }
    },


})