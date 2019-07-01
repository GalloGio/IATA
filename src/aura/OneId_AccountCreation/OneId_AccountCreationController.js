({
    handleInit : function (c, e, h) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");

        var action = c.get("c.getSectors");
        action.setCallback(this, function(a) {
            var sectorsMap = a.getReturnValue();
            c.set("v.sectors", sectorsMap);


            if(c.get("v.changeSector")){
                var options = [];
                for (var key in sectorsMap){
                    options.push(sectorsMap[key]);
                }

                c.find("sectorSelection").set("v.options", options);
            }else{
                var option = sectorsMap[sector];/* WMO-391 */
                if(option) {
                    c.find("sectorSelection").set("v.options", [{label: option.label, value : option.value, selected : true}]);
                } else {
                	c.find("sectorSelection").set("v.options", [{label: sector, value : sector, selected : true}]);
            	}
            }

            h.setCategory(c);
        });
        $A.enqueueAction(action);
        

        var action = c.get("c.getAccountLabels");
        action.setCallback(this, function(a) {
            c.set("v.accountLabels", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    sectorChanged : function (c, e, h) {
        h.setCategory(c);
    },
    jsLoaded: function(c, e, h){
        c.set("v.hasJquery", true);
        if(!$A.util.isEmpty(c.get("v.country.ISO_Code__c"))) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    changedCountry : function(c, e,h){
        if(c.get("v.hasJquery")) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    setAddress: function (c, e, h) {
        // FIll all address fields when user select a validated address from suggestion
        var addressObj = e.getParam("addressSelected");
        var addressType = e.getParam("addressType");

        c.set("v.account."+addressType+"Street", addressObj.street);
        
        if(!$A.util.isEmpty(addressObj.locality)){
            c.set("v.account."+addressType+"City", addressObj.locality);
        }
        if(!$A.util.isEmpty(addressObj.province)){
            c.set("v.account."+addressType+"State", addressObj.province);
        }
        if(!$A.util.isEmpty(addressObj.postalCode)){
            c.set("v.account."+addressType+"PostalCode", addressObj.postalCode);
        }

        //reset validation
        c.set("v.valid"+addressType, 0);
        c.set("v.suggestionsMode", "hidden");
        
        // if copy checkbox is selectected copy billing to shipping
        h.copyBillingToShipping(c);
    },

    validateAddress : function (c, e, h) {
        var mode = e.currentTarget.dataset.mode;
        c.set("v.valid"+mode, 2); //set spinner

        var addressInfo = {
            street : c.get("v.account."+mode+"Street"),
            locality : c.get("v.account."+mode+"City"),
            postalCode : c.get("v.account."+mode+"PostalCode"),
            province : c.get("v.account."+mode+"State"),
            countryCode : c.get("v.country.ISO_Code__c")
        };
        var action = c.get("c.checkAddress");
        action.setParams({"info": $A.util.json.encode(addressInfo)});

        action.setCallback(this, function(a) {
            var addresses = a.getReturnValue();

            var isValidAddress = addresses.length > 0;

            c.set("v.valid"+mode, isValidAddress ? 1 : -1);

            if(isValidAddress){
                if(addresses.length == 1){
                    var cmpEvent = c.getEvent("addressSelected");
                    cmpEvent.setParams({
                        "addressType" : mode,
                        "addressSelected" : addresses[0] });
                    cmpEvent.fire();  

                    c.set("v.valid"+mode, 1);
                    h.copyBillingToShipping(c);
                }else{
                    c.set("v.suggestions", addresses);
                    c.set("v.suggestionsMode", mode);
                }
            }else{
                
                c.set("v.suggestionsMode", "hidden");
                c.set("v.valid"+mode, -1);
                h.copyBillingToShipping(c);
            }
        });
        $A.enqueueAction(action);
    },
    
    copyBilling: function (c, e, h) {
        //check if information need to be passed to shipping as well
        h.copyBillingToShipping(c);
    },
    
    updateAddress: function (c, e, h) {
        //change of addres makes the validation null
        c.set("v.validBilling", 0);

        //check if information need to be passed to shipping as well
        h.copyBillingToShipping(c);
    	
        validateRequiredFields(c);
    },

    validateNumber : function(c, e, h){
        var input = c.find(e.getSource().getLocalId());
        input.set("v.value", input.get("v.value").replace(/[^0-9+]|(?!^)\+/g, ''));
    },

    validateRequiredFields: function(c) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        var category = c.find("categorySelection");
        
        var email = c.find("email");
        var emailValue = email.get("v.value");

        var officePhone = c.find("officePhone");        

        var domPhone = officePhone.getElement();
        var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;

        var isAllFilled = true;

        if($A.util.isEmpty(category.get("v.value"))){
            category.set("v.errors",[{message: $A.get("$Label.c.OneId_CategoryError")}]);
            isAllFilled = false;
        } else {
            category.set("v.errors",null);
            var catValue = category.get("v.value");
            if(catValue == 'Other') {
                var catOther = c.find("catOtherVal");
               
                if(!$A.util.isEmpty(catOther) && $A.util.isEmpty(catOther.get("v.value"))) {            
                    catOther.set("v.errors",[{message: $A.get("$Label.c.ISSP_YouMustEnter")}]);
                    isAllFilled = false;
                } else {
                    catOther.set("v.errors", false);                
                }            
            }
        }

        if(!$A.util.isEmpty(emailValue) && !emailValue.match(regExpEmailformat)){
           email.set("v.errors",[{message: $A.get("$Label.c.ISSP_AMS_Invalid_Email")}]);
           isAllFilled = false;
        }else{
           email.set("v.errors",null);
        }

        if($A.util.isEmpty(officePhone.get("v.value"))){
           officePhone.set("v.errors",[{message: $A.get("$Label.c.ISSP_Registration_Error_BusinessPhone")}]);
           isAllFilled = false;

           setTimeout(function(){
                $(domPhone).intlTelInput("setCountry", "");
                $(domPhone).intlTelInput("setCountry", country);
            }, 100);
        }else{
           officePhone.set("v.errors",null);
        }

        if(c.get("v.validBilling") == 0){
            c.set("v.validationError", true);
            isAllFilled = false;
        }else{
            c.set("v.validationError", false);
        }

        if(c.get("v.validShipping") == 0){
            c.set("v.validationError", true);
            isAllFilled = false;
        }else{
            c.set("v.validationError", false);
        }
        
        /* MME TEMP for test purpose*/
//        isAllFilled = true;
        
        if(isAllFilled){
          c.getEvent("newAccountSet")
            .setParams({
                "state" : "newAccountSet",
                "account" : c.get("v.account")
            }).fire();             
        }
        
        return isAllFilled;        
    },

    closeModal: function(c){
        c.set("v.suggestionsMode", "hidden");
    },

    parseCategory: function(c){
        var category = c.find("categorySelection");
        var catValue = category.get("v.value");
        if(!$A.util.isEmpty(catValue) && catValue == 'Other') {
            c.set("v.categoryOther", true);
        } else {
            c.set("v.categoryOther", false);
        }
    },

    suggestionSelected: function(c, e) {
        
        // Set input with selected value
        var response = c.get("v.suggestions");

        var index = parseInt(e.currentTarget.dataset.rowIndex);
        var addressType = c.get("v.suggestionsMode");
        
        var cmpEvent = c.getEvent("addressSelected");
        cmpEvent.setParams({
            "addressType" : addressType,
            "addressSelected" : response[index] });
        cmpEvent.fire();
        c.set("v.suggestionsMode", "hidden");   
    }
})