({
	sectorAndCategory : function(c, sector, category) {
		var account = c.get("v.account");
		account.Sector__c = sector;
		account.Category__c = category;		
		c.set("v.account", account);
	},
	setCustomer : function (c) {
		var customerType = c.get("v.customerType");
		var fieldLabels = ['Company Name', 'Address'];
		var fieldNames = ['Name', 'BillingStreet'];
		var searchFields = ['Name', 'IATACode__c', 'Airline_Prefix__c'];
		var filters = c.get("v.filters");
		filters['IATA_ISO_Country__c'] = c.get("v.selectedCountry");

		if(customerType == 'Airline'){
			fieldLabels = ['Company Name', 'Address', 'Country', 'Designator code', 'IATA Code'];
			fieldNames = ['Name', 'BillingStreet', 'IATA_ISO_Country__r.Name', 'Airline_designator__c', 'IATACode__c', 'Category__c'];
			searchFields.push('Airline_designator__c');

			delete filters['Sector__c'];

			c.set('v.account.Sector__c', 'Airline');					

		}
		if(customerType == 'GloballSalesAgent'){
			delete filters['Sector__c'];
		}
		if(customerType == 'Agency'){
			fieldLabels = ['Company Name', 'Address', 'IATA Code'];
			fieldNames = ['Name', 'BillingStreet', 'IATACode__c'];

			var agencyType = c.get("v.agencyType");
			this.sectorAndCategory(c, agencyType, 'Non-IATA '+agencyType);
		}
		if(customerType == 'OtherCompany'){
			delete filters['Sector__c'];

			c.set('v.account.Sector__c', '');
		}
		
		if(customerType == 'GeneralPublic'){
			c.set('v.account.Sector__c', 'General Public');
		}

		// add fields that will be needed on creation
	    // TODO create a new attribute for this
	    fieldNames.push('IATA_ISO_Billing_State__c');
	    fieldNames.push('IATA_ISO_Shipping_State__c');
	    fieldNames.push('Sector__c');

		c.set("v.fieldLabels", fieldLabels);
		c.set("v.fieldNames", fieldNames);
		c.set("v.searchFields", searchFields);
	}
})