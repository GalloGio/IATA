({
	init : function(component, event, helper) {

         component.set("v.serviceName", 'FRED');
               
         //component.set("v.primaryLimit", params.serviceConfig.Max_Number_Of_Primary_User__c); 
         //component.set("v.secondaryLimit", params.serviceConfig.Max_Number_Of_Secondary_User__c);

         helper.loadAccountInfo(component);

        helper.showRoles(component, event, helper); 
	},
/**
    Load customer type depending on service provider in URL
*/
    renderPage : function (component, event, helper){
        
       
        
    },

	redirectToSelfRegistrationPage : function(component, event, helper) {
        // Check if limit is reach: Business rule is to have maximum 2 primary and 5 secondary
        if(component.get("v.maxNbOfPrimaryReached") || component.get("v.maxNbOfSecondaryReached")) {
            helper.showToast();
        } else {
            // Redirect to registration page to create a seondary user
            var primaryUseId = component.get("v.primaryUserId");
            window.location.href = "registration?language=en_US&serviceName=FRED&puid="+primaryUseId;
        }
	},

    openModal : function(cmp, evt, hlp) {    
         // open popup with user type selection
        $A.util.addClass(cmp.find("theModal"), "slds-fade-in-open");
        $A.util.addClass(cmp.find("modalBackdrop"),  "slds-backdrop--open");
    },

     onCancel : function(cmp, evt, hlp) {
       // Hide modal
        $A.util.removeClass(cmp.find("theModal"), "slds-fade-in-open");
        $A.util.removeClass(cmp.find("modalBackdrop"),  "slds-backdrop--open");
    },

    onConfirm : function(cmp, evt, hlp) {
        console.log(cmp.get("v.selectedRole"));
      if(cmp.get("v.selectedRole") == undefined) {
        hlp.showToast(cmp, 'Mandatory data missing', 'Please select a role', 'ERROR');
      } else {
            // Check if the limit of number of user per type has been reached
            if(cmp.get("v.selectedRole") == 'Primary User' && cmp.get("v.maxNbOfPrimaryReached"))
                hlp.showToast(cmp, 'Limit reached', 'You reached the maximum number of primary user you can create', 'ERROR');
            else if(cmp.get("v.selectedRole") == 'Secondary User' && cmp.get("v.maxNbOfSecondaryReached"))
                hlp.showToast(cmp, 'Limit reached', 'You reached the maximum number of secondary user you can create', 'ERROR');
            else {
                var userType = 0;
                if(cmp.get("v.selectedRole") == 'Primary User') userType = 1;
                else if(cmp.get("v.selectedRole") == 'Secondary User') userType = 2;

                // Redirect to registration page to create a primary or a secondary user
                var primaryUseId = cmp.get("v.primaryUserId");
                window.location.href = "registration?language=en_US&serviceName=FRED&puid="+primaryUseId+"&t="+userType;
            }
        }
    },

    clickRadio : function(component, event, helper) {
        component.set("v.selectedRole", event.getSource().get("v.label"));
    },


})