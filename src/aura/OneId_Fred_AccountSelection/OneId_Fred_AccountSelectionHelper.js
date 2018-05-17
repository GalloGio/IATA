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
       console.log("isAllFilled"+isAllFilled);
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

  getPartnerAccount: function(cmp) {
      var action = cmp.get("c.getPartnerAccount");
        
        action.setCallback(this, function(resp) {
            var accountOfPrimary = resp.getReturnValue();

            // Set user type and disable the field
            cmp.set("v.customerType", accountOfPrimary.RecordType.Name);
            //cmp.find("typeOfCustomer").set("v.value", accountOfPrimary.RecordType.Name);
            var opts = [
            { class: "uiInputSelectOption", label:accountOfPrimary.RecordType.Name, value: accountOfPrimary.RecordType.Name, selected: "true" }
           
            ];
            cmp.find("typeOfCustomer").set("v.options", opts);
            
             // Set input with selected value
            //var userInputCmp = component.find("userInput");
            cmp.set("v.userInput", accountOfPrimary.Name);

            // Hide suggestion box
            var resultDiv = cmp.find("agencies");
            if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                $A.util.removeClass(resultDiv, 'slds-is-open');
            }
            cmp.set("v.suggestionBoxHeight", 0 );

            cmp.set("v.accountSelected", true);

            cmp.set("v.acc", accountOfPrimary);
            cmp.set("v.isForSecondaryUsers", true);
            //cmp.set("v.customerTypesByServiceName", customerTypesFound);
        });
        $A.enqueueAction(action);
  }

})