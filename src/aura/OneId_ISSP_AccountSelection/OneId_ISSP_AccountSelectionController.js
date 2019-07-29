({
	doInit: function (c,e,h) {
	    h.getCustomerTypes(c);

	    //Get countries
        var countryAction = c.get("c.getISOCountries");
        countryAction.setCallback(this, function(resp) {
            c.set("v.countryInformation", resp.getReturnValue());
        });
        $A.enqueueAction(countryAction);
	},

	handleAccountSelected : function (c,e,h) {
		var state = e.getParam("state");
		var account = e.getParam("account");
		console.log('acountSelected.. '+state+' -> '+account);

        c.set("v.account.Name", account.Name);
		console.warn(state);
		if(state == 'createNew'){
			c.set("v.search", false);
			c.set("v.create", true);
        }

        if(state == 'accountSelected'){
            var acc = c.get("v.account");
            acc.Id = account.Id;
            c.set("v.account",acc);
        }

		if(state != 'noAccount') c.set("v.accountSelected", true);
	},

	setCountry : function (c) {
	    //console.log('setCountry: '+c.get("v.selectedCountry"));

	    let selectedCountry = c.get("v.selectedCountry");
	    if(selectedCountry == null || selectedCountry.length == 0){
	        c.set("v.account",{});
	        c.set("v.country",null);
	        c.set("v.accountSelected", false);
	    }

		c.set("v.country", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);
		c.set("v.account.BillingCountry", c.get("v.country").Name);
		c.set("v.account.ShippingCountry", c.get("v.country").Name);
	},
	submit : function(c){
	    let account = c.get("v.account");
	    let serviceName = 'ISSP';
	    let country = c.get("v.country");

		let countryId = country ? country.Id : null;

		if(c.get("v.search") || c.find("creationComponent").validateRequiredFields()){
            //alert('account : ' + account.Id);
			var spinner = c.find("loading");
			$A.util.toggleClass(spinner, "slds-hide");
            
            //Data Quality//
            let cityAndStateIds = {	'billingCityId'  : c.get('v.billingCityId'),
                                   'billingStateId' : c.get('v.billingStateId'),
                                   'shippingCityId' : c.get('v.shippingCityId'),
                                   'shippingStateId': c.get('v.shippingStateId') };
            //Data Quality//

			var action;

            if(account.Name != null || account.Id != null){
                action = c.get("c.registration");
                action.setParams({
                    "con" : c.get("v.contact"),
                    "acc" : account,
                    "serviceName" : serviceName,
                    "cityAndStateIds" : cityAndStateIds
                });
            }else{
                action = c.get("c.automaticRegistration");
                action.setParams({
                        "con" : c.get("v.contact"),
                        "country":countryId,
                        "customerType":c.get("v.customerType"),
                        "serviceName" : serviceName
                });
            }

            action.setCallback(this, function(resp){
                var result = resp.getReturnValue();
                //User creation successfull
                if(result) {
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
	},
	customerTypeSelected : function(c,e,h){
	    c.set("v.selectedCustomerTypeName2",null);
	    c.set("v.selectedCustomerTypeName3",null);
	    c.set("v.secondLevelType",false);
	    c.set("v.customerTypes2",null);
	    c.set("v.customerType1",null);
	    c.set("v.customerType2",null);
	    c.set("v.customerType3",null);
	    c.set("v.picklistLabel2",null);
	    c.set("v.v.picklistPlaceholder2",null);
	    c.set("v.v.picklistPlaceholder3",null);

	    h.handleCustomerType(c,null,1);

	    let ctypeName = c.get("v.selectedCustomerTypeName");
	    let ctypes = c.get("v.customerTypes");
	    let searchable = 'User Search';

	    for(let i=0;i<ctypes.length;i++){
	        let currentType = ctypes[i];
	        if(currentType.metadataCustomerType.DeveloperName == ctypeName){
	            if(currentType.children != null && currentType.children.length > 0 && currentType.metadataCustomerType.Search_Option__c != searchable){
	                c.set("v.customerType1",currentType);
	                c.set("v.secondLevelType",true);
	                c.set("v.customerTypes2",currentType.children);
					c.set("v.picklistLabel2",currentType.subCategorizationLabel);
					c.set("v.picklistPlaceholder2",currentType.subCategorizationPlaceholder);
                }else{
                    h.handleCustomerType(c,currentType,1);
                }
            }
        }
	},
	customerTypeSelected2 : function(c,e,h){
	    c.set("v.selectedCustomerTypeName3",null);
	    c.set("v.thirdLevelType",false);
	    c.set("v.customerTypes3",null);
        c.set("v.customerType2",null);
        c.set("v.customerType3",null);
        c.set("v.picklistLabel3",null);
	    c.set("v.v.picklistPlaceholder3",null);

        h.handleCustomerType(c,null,2);

	    let ctypeName = c.get("v.selectedCustomerTypeName2");
	    let ctypes = c.get("v.customerTypes2");
	    let searchable = 'User Search';

	    for(let i=0;i<ctypes.length;i++){
	        let currentType = ctypes[i];
            if(currentType.metadataCustomerType.DeveloperName == ctypeName){
                if(currentType.children != null && currentType.children.length > 0 && currentType.metadataCustomerType.Search_Option__c != searchable){
                    c.set("v.customerType2",currentType);
                    c.set("v.thirdLevelType",true);
                    c.set("v.customerTypes3",currentType.children);
                    c.set("v.picklistLabel3",currentType.subCategorizationLabel);
					c.set("v.picklistPlaceholder3",currentType.subCategorizationPlaceholder);
                }else{
                    h.handleCustomerType(c,currentType,2);
                }
            }
        }
    },
    customerTypeSelected3 : function(c,e,h){
        c.set("v.customerType3",null);

        h.handleCustomerType(c,null,3);

        let ctypeName = c.get("v.selectedCustomerTypeName3");
        let ctypes = c.get("v.customerTypes3");

        for(let i=0;i<ctypes.length;i++){
            if(ctypes[i].metadataCustomerType.DeveloperName == ctypeName){
                c.set("v.customerType3",ctypes[i]);
                h.handleCustomerType(c,ctypes[i],3);
            }
        }
    }
})