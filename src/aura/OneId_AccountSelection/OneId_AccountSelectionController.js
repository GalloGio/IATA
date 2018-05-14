({
	doInit: function (c) {
        var action = c.get("c.getISOCountries");
        action.setCallback(this, function(resp) {
            c.set("v.countryInformation", resp.getReturnValue());
        });
        $A.enqueueAction(action);
	},

	create : function (c) {
		c.set("v.search", false);
	},

	setCountry : function (c) {
		var filters = c.get("v.filters");
		
		//Mehdi: the following check was removed to return results related only to the country selected even for airline.
		//if(c.get("v.customerType") != 'Airline')
        filters['IATA_ISO_Country__c'] = c.get("v.selectedCountry");
		c.set("v.country", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);
	},
	setAgencyType : function(c, e, h){
		var agencyType = c.get("v.agencyType");
		console.log('aqui agencyType... ' + agencyType);
		h.sectorAndCategory(c, agencyType, 'Non-IATA '+agencyType);
	},
	customerSelected : function (c, e, h) {
		var customerType = c.get("v.customerType");
		var fieldLabels = ['Company Name', 'Address'];
		var fieldNames = ['Name', 'BillingStreet'];
		var searchFields = ['Name', 'IATACode__c', 'Airline_Prefix__c'];
		var filters = c.get("v.filters");
		filters['IATA_ISO_Country__c'] = c.get("v.selectedCountry");

		if(customerType == 'Airline'){
			fieldLabels = ['Company Name', 'Address', 'Country', 'Designator code', 'IATA Code'];
			fieldNames = ['Name', 'BillingStreet', 'IATA_ISO_Country__r.Name', 'Airline_designator__c', 'IATACode__c', 'Sector__c', 'Category__c'];
			searchFields.push('Airline_designator__c');

			delete filters['Sector__c'];
			delete filters['Category__c'];

			c.set('v.account.Sector__c', 'Airline');					

		}
		if(customerType == 'GloballSalesAgent'){
			delete filters['Sector__c'];
			delete filters['Category__c'];
		}
		if(customerType == 'Agency'){
			fieldLabels = ['Company Name', 'Address', 'IATA Code'];
			fieldNames = ['Name', 'BillingStreet', 'IATACode__c'];

			var agencyType = c.get("v.agencyType");
			h.sectorAndCategory(c, agencyType, 'Non-IATA '+agencyType);
		}
		if(customerType == 'OtherCompany'){
			delete filters['Sector__c'];
			delete filters['Category__c'];

			c.set('v.account.Sector__c', '');
		}
		
		if(customerType == 'GeneralPublic'){
			filters['Sector__c'] = 'General Public';
			delete filters['Category__c'];
		}

		// add fields that will be needed on creation
	    // TODO create a new attribute for this
	    fieldNames.push('IATA_ISO_Billing_State__c');
	    fieldNames.push('IATA_ISO_Shipping_State__c');

		c.set("v.fieldLabels", fieldLabels);
		c.set("v.fieldNames", fieldNames);
		c.set("v.searchFields", searchFields);
	},

	submit : function(c){
		$A.util.toggleClass(c.find("loadingStatus"), "slds-hide");

		var action = c.get("c.registration");
		action.setParams({
				"con" : c.get("v.contact"),
				"acc" : c.get("v.account"),
				"serviceName" : c.get("v.serviceName")
		});
		
		action.setCallback(this, function(resp){
			var result = resp.getReturnValue();			
            // redirect to a new page when registration is done
            if(result) {            	
                window.location.href = "../registrationcomplete?serviceName="+c.get("v.serviceName");
            }	
            
            if(!result) {
                $A.util.toggleClass(c.find("loadingStatus"), "slds-hide");
                $A.util.removeClass(c.find("errorMessage"), "slds-hide");
                $A.util.addClass(c.find("backdrop"), "slds-backdrop_open");
            } 
		});
		$A.enqueueAction(action);
	},
	closeError : function (c) {
        $A.util.toggleClass(c.find("errorMessage"), "slds-hide");
        $A.util.toggleClass(c.find("backdrop"), "slds-backdrop_open");
	}
})