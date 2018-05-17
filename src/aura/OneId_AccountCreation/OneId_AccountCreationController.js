({
    setSector : function (c, e, h) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");

        if(c.get("v.changeSector")){
            var action = c.get("c.getSectors");
            action.setCallback(this, function(a) {
                c.find("sectorSelection").set("v.options", a.getReturnValue());
            });
            $A.enqueueAction(action);
        }else{
            var sectoroptions = [{label: sector, value : sector, selected : true}];
            c.find("sectorSelection").set("v.options", sectoroptions);
        }

        h.setCategory(c);
    },
    sectorChanged : function (c, e, h) {
        h.setCategory(c);
    },
    jsLoaded: function(c, e, h){
        c.set("v.hasJquery", true);
        if(!$A.util.isEmpty(c.get("v.country.ISO_Code__c"))) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    changedCountry : function(c, e , h){
        if(c.get("v.hasJquery")) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    setAddress: function (c, e, h) {
        // FIll all address fields when user select a validated address from suggestion
        var addressObj = e.getParam("addressSelected");
        var addressType = e.getParam("addressType");

        c.set("v.account."+addressType+"Street", addressObj.street);
        c.set("v.account."+addressType+"City", addressObj.locality);
        c.set("v.account."+addressType+"State", addressObj.province);
        c.set("v.account."+addressType+"PostalCode", addressObj.postalCode);
        
        // if copy checkbox is selectected copy billing to shipping
        h.copyBillingToShipping(c);
    },
    
    updateAddress: function (c, e, h) {
        h.copyBillingToShipping(c);
    },

    validateNumber : function(c, e, h){
        var input = c.find(e.getSource().getLocalId());
        input.set("v.value", input.get("v.value").replace(/[^0-9+]|(?!^)\+/g, ''));
    },

    validateRequiredFields: function(c) {
        console.log('aqui validateRequiredFields');
        
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        var category = c.find("categorySelection");
        
        var email = c.find("email");
        var emailValue = email.get("v.value");

        var officePhone = c.find("officePhone");        

        var domPhone = officePhone.getElement();
        var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;

        var isAllFilled = true;        
        //console.log('tradeName ' + tradeName + ' officePhone ' + officePhone + ' email ' + email);
        if($A.util.isEmpty(category.get("v.value"))){
           category.set("v.errors",[{message:"Please, choose the category"}]);
           isAllFilled = false;
        }else{
           category.set("v.errors",null);
        }

        if(!$A.util.isEmpty(emailValue) && !emailValue.match(regExpEmailformat)){
           email.set("v.errors",[{message:"Please, enter your email"}]);
           isAllFilled = false;
        }else{
           email.set("v.errors",null);
        }

        if($A.util.isEmpty(officePhone.get("v.value"))){
           officePhone.set("v.errors",[{message:$A.get("$Label.c.ISSP_Registration_Error_BusinessPhone")}]);
           isAllFilled = false;

           setTimeout(function(){
                $(domPhone).intlTelInput("setCountry", "");
                $(domPhone).intlTelInput("setCountry", country);
            }, 100);
        }else{
           officePhone.set("v.errors",null);
        }
        
        if(isAllFilled == false)
          return false;
        
    }
})