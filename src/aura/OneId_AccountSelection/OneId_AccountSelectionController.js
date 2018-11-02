({
	doInit: function (c) {
        var countryAction = c.get("c.getISOCountries");
        countryAction.setCallback(this, function(resp) {
            c.set("v.countryInformation", resp.getReturnValue());
        });
        $A.enqueueAction(countryAction);

        var labelsAction = c.get("c.getAccountLabels");
        labelsAction.setCallback(this, function(a) {
            c.set("v.accountLabels", a.getReturnValue());
        });
        $A.enqueueAction(labelsAction);

        var agencyTypes = [
            {value : 'Travel Agent', label: $A.get('{!$Label.c.ISSP_Travel}')},
            {value : 'Cargo Agent', label: $A.get('{!$Label.c.ISSP_Cargo}')}
        ];

        c.set("v.agencyTypes", agencyTypes);
	},

	handleItem : function (c,e,h) {
		var state = e.getParam("state");
		var account = e.getParam("account");

		c.set("v.account.Name", account.Name);

		console.warn(state);
		if(state == 'createNew'){
			h.setCustomer(c);
			c.set("v.search", false)
		}
		if(state == 'accountSelected') c.set("v.account", account);

		if(state != 'noAccount') c.set("v.showCreateNew", true);
	},

	setCountry : function (c) {
		var filters = c.get("v.filters");
        filters['IATA_ISO_Country__c'] = c.get("v.selectedCountry");

		c.set("v.country", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);
		c.set("v.account.BillingCountry", c.get("v.country").Name);
		c.set("v.account.ShippingCountry", c.get("v.country").Name);
	},
	setAgencyType : function(c, e, h){
		var agencyType = c.get("v.agencyType");
		h.sectorAndCategory(c, agencyType, 'Non-IATA '+agencyType);
	},
	customerSelected : function (c, e, h) {
		h.setCustomer(c);
	},

	submit : function(c){	    
		
		if(c.get("v.search") || c.find("creationComponent").validateRequiredFields()){
			var spinner = c.find("loading");
			$A.util.toggleClass(spinner, "slds-hide");

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
	            	/*var successURL = "../registrationcomplete"
	            	var serviceName = c.get("v.serviceName");
	            	if(!$A.util.isEmpty(serviceName)) successURL += "?serviceName="+serviceName;
	                window.location.href = successURL;*/

        			c.getEvent("StepCompletionNotification")
        			.setParams({
                        "stepNumber" : 3,
                        "isComplete" : true,
                         })
                    .fire();
	            }else {
	                $A.util.removeClass(c.find("errorMessage"), "slds-hide");
	                $A.util.addClass(c.find("backdrop"), "slds-backdrop_open");
	            } 
	            $A.util.toggleClass(spinner, "slds-hide");
			});
			$A.enqueueAction(action);
		}

	},
	closeError : function (c) {
        $A.util.toggleClass(c.find("errorMessage"), "slds-hide");
        $A.util.toggleClass(c.find("backdrop"), "slds-backdrop_open");
	}
})