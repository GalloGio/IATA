({
    setCategory : function (c) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");
        var sectors = c.get("v.sectors");

        var catoptions = [];
        if(c.get("v.changeCategory") && !$A.util.isEmpty(sectors)){
            catoptions = c.get("v.sectors")[sector].dependentValues;
        }else{
            catoptions = [{label: category, value : category, selected : true}];
        }

        c.find("categorySelection").set("v.options", catoptions);
    },
	copyBillingToShipping : function(c) {
		if(c.get("v.copyAddress")) {
			c.set("v.account.ShippingStreet", c.get("v.account.BillingStreet"));
			c.set("v.account.ShippingCity", c.get("v.account.BillingCity"));
			c.set("v.account.ShippingState", c.get("v.account.BillingState"));
            c.set("v.account.ShippingPostalCode", c.get("v.account.BillingPostalCode"));
			c.set("v.validShipping", c.get("v.validBilling"));
		}
	},

	placePhoneFlags : function(country){		
        $('.phoneFormat').intlTelInput({
            initialCountry: country,                    
            preferredCountries: [country],
            placeholderNumberType : 'FIXED_LINE'
        });

        $(".mobileFormat").intlTelInput({
            initialCountry: country,                    
            preferredCountries: [country],
            placeholderNumberType : 'MOBILE'
        });
    }
})