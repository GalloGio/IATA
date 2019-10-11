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
    currentUserType: function(component) {
        var action = component.get("c.getCurrenthUserInfo");
        action.setCallback(this, function(a) {
            component.set("v.userType", a.getReturnValue().UserType);
            this.getActors(component);
        });
        $A.enqueueAction(action);
    },
	
    jobFunctionOptions: function(component) {
        var action = component.get("c.getContactJobFunctionValues");
        action.setCallback(this, function(a) {
            component.set("v.jobFunctionOptions", a.getReturnValue());
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

        let actor = component.find('actor');
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

    getActors: function(component) {
        let userType = component.get('v.userType');
        if(userType === 'Standard') {
            this.getActorsForInternalUser(component, event);            
        }else{
            this.getActorsForExternalUser(component, event);
        }

	},

	getActorsForExternalUser : function(component, event) {
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
               }
            }
        });
        $A.enqueueAction(action);

	},

	getActorsForInternalUser : function(component, event) {
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