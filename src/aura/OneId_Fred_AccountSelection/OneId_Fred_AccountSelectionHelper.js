({
	 isMandatoryFieldsOK: function(component) {
       var isAllFilled = true;
       var typeOfCustomerCmp = component.find("typeOfCustomer");
       if($A.util.isEmpty(typeOfCustomerCmp.get("v.value"))) {
       		typeOfCustomerCmp.set("v.errors", [{message:"Please select a type of user"}]);
            isAllFilled = false;
       } else {
       		typeOfCustomerCmp.set("v.errors", null);
       }
		return isAllFilled;
    },

    getCustomerTypeAvailableByServiceName: function(cmp) {
    // Get customerType available for the current service name in URL
     var action = cmp.get("c.getCustomerTypeBySP");
            action.setParams({            
            "serviceName": cmp.get("v.serviceName")
        });
        action.setCallback(this, function(resp) {
          var customerTypesFound = resp.getReturnValue();
          cmp.set("v.customerTypesByServiceName", customerTypesFound);
        });
        $A.enqueueAction(action);
  },

  initParams: function(cmp, isInvitation, invitationId) {
      var action = cmp.get("c.initParams");
        action.setParams({            
            "isInvitation": isInvitation,
            "invitationId": invitationId
        });
        action.setCallback(this, function(resp) {
      
            var params = resp.getReturnValue();
            console.log('ooo'+params);
            var partnerAccount = params.partnerAccount;
            var isFredPrimaryUser = params.isFredPrimaryUser;
            cmp.set("v.isFredPrimaryUser", isFredPrimaryUser);
            cmp.set("v.isGuest", params.isGuest);
            cmp.set("v.createPrimary", params.createPrimary);
            
            if(! params.isInvitation && !isFredPrimaryUser) // Load customer type if not a primary user
               this.getCustomerTypeAvailableByServiceName(cmp);

            // If primary user logged or invitation => Set user type and disable the field
            if(! params.isGuest || params.isInvitation) {
            	var accountType = partnerAccount.RecordType.Name;
            	if(accountType == 'Airline Headquarters' || accountType == 'Operator'){
            		accountType = 'Aircraft Operator';
            	}
                cmp.set("v.customerType", accountType);
                var opts = [{ class: "uiInputSelectOption", label:accountType, value: accountType, selected: "true" }];
                cmp.find("typeOfCustomer").set("v.options", opts);
                
                 // Set input with selected value
                cmp.set("v.userInput", partnerAccount.Name);

                // Hide suggestion box
                var resultDiv = cmp.find("agencies");
                if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                    $A.util.removeClass(resultDiv, 'slds-is-open');
                }
                cmp.set("v.suggestionBoxHeight", 0 );
                cmp.set("v.accountSelected", true);
                cmp.set("v.acc", partnerAccount);
            }
            
        });
        $A.enqueueAction(action);
  },


})