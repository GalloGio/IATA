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

        c.set("v.account."+addressType+"Street", addressObj.deliveryAddressLines);
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
})