({
    doInit : function(cmp, event, helper) {
    	helper.contactLabels(cmp);
    	helper.jobFunctionOptions(cmp);
        helper.getActors(cmp);
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
    inviteUser : function(cmp, event, helper) {
    	var action = cmp.get("c.sendInvitation");
        console.log(JSON.stringify(cmp.get("v.contact")));
        console.log(JSON.stringify(cmp.get("v.invitation")));
        action.setParams({
            "contactStr": JSON.stringify(cmp.get("v.contact")),
            "invitationStr": JSON.stringify(cmp.get("v.invitation"))
        });
		action.setCallback(this, function(resp) {
            console.log('here');
            console.log(resp.getReturnValue());
        });
        $A.enqueueAction(action);	
	},
 
	checkUsername :function (cmp, event, helper) {        
        $A.util.removeClass(cmp.find("spinner"), 'slds-hide');
        if(helper.validateEmail(cmp)){
        console.log("IN");
        var emailCmp = cmp.find("email");
        console.log(emailCmp);
        var emailValue = emailCmp.get("v.value");
        console.log(emailValue);
        var serviceName = "GADM";

        if(serviceName == null){
            console.log('Warning : No service name provided!');
        }

        //check if username is available (insert + rollback)
        var action = cmp.get("c.getUserInformationFromEmail");
        console.log("before1");
        action.setParams({
            "email":emailValue,
            "serviceName": serviceName
        });
		console.log("before2");
        action.setCallback(this, function(resp) {
            var params = resp.getReturnValue();
            
            console.log(params);
            console.log('Params received : ' + params);
            
            cmp.set("v.contact", params.contact);
            cmp.set("v.invitation", params.invitation);
            console.log(cmp.get("v.contact"));
            console.log(cmp.get("v.invitation"));
            if(params.showNotifyButton){
                $A.util.removeClass(cmp.find("notifyUserButton"), 'slds-hide'); 
            } else {
                $A.util.addClass(cmp.find("notifyUserButton"), 'slds-hide'); 
            }
            
            if(params.createNewInvitation){
				$A.util.addClass(cmp.find("emailExists"), 'slds-hide'); 
                $A.util.removeClass(cmp.find("detail"), 'slds-hide');              		
            } else {
                $A.util.removeClass(cmp.find("emailExists"), 'slds-hide'); 
                $A.util.addClass(cmp.find("detail"), 'slds-hide');
            }
            $A.util.addClass(cmp.find("spinner"), 'slds-hide');
        });
        $A.enqueueAction(action);
        }else{
            $A.util.addClass(cmp.find("spinner"), 'slds-hide');
        }        
    }
})