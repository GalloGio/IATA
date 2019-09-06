({
    doInit: function (c,e,h) {
        var countryAction = c.get("c.getISOCountries");
        countryAction.setCallback(this, function(resp) {
            c.set("v.countryInformation", resp.getReturnValue());
        });
        $A.enqueueAction(countryAction);        
        h.checkIfAccountSet(c);
    },
    
    
    handleItem : function (c,e,h) {
        c.set("v.account.Name", account.Name);
        
        console.warn(state);
        if(state == 'createNew'){
            c.set("v.search", false)
        }
    },
    
    setCountry : function (c) {
        var filters = c.get("v.filters");
        filters['IATA_ISO_Country__c'] = c.get("v.selectedCountry");
        
        c.set("v.country", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);
        c.set("v.account.BillingCountry", c.get("v.country").Name);
        c.set("v.account.ShippingCountry", c.get("v.country").Name);
    },
    
    sectorSelected : function (c, e, h) {
        h.setSector(c);
    },
    
    categorySelected : function (c, e, h) {
        h.setCategory(c);
    },
    
    
    submit : function(c){
        if(c.get("v.search") || c.find("creationComponent").validateRequiredFields()){
            var spinner = c.find("loading");
            $A.util.toggleClass(spinner, "slds-hide");
            
            //Data Quality//
            let cityAndStateIds = {	'billingCityId'  : c.get('v.billingCityId'),
                                   'billingStateId' : c.get('v.billingStateId'),
                                   'shippingCityId' : c.get('v.shippingCityId'),
                                   'shippingStateId': c.get('v.shippingStateId') };
            //Data Quality//
            
            var action = c.get("c.registrationAux");
            action.setParams({
                "con" : c.get("v.contact"),
                "acc" : c.get("v.account"),
                "serviceName" : c.get("v.serviceName"),
                "cityAndStateIds" : cityAndStateIds
            });
            action.setCallback(this, function(resp){
                var result = resp.getReturnValue();			
                // redirect to a new page when registration is done
                
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
    
    onKeyUp : function(cmp, evt, hlp) {
        // Unvalidate component when user tries to change input
        cmp.set("v.isValid", false);
        cmp.set("v.accountSelected", false);
        if(hlp.isMandatoryFieldsOK(cmp)) {
            cmp.set("v.searching", true);
            // When user search on input field call Address doctor to get suggestion for validation of address
            var userInputCmp = evt.currentTarget;
            cmp.set("v.userInput", userInputCmp.value);
            
            var action = cmp.get("c.getAccountsBySectorAndCategory");
            action.setParams({
                "sector":cmp.get("v.sector"),
                "cat":cmp.get("v.category"),
                "country":cmp.get("v.selectedCountry"),
                "userInput":userInputCmp.value
            });
            
            action.setCallback(this, function(a) {
                var accountSuggested = a.getReturnValue();
                if(accountSuggested != undefined && accountSuggested.length > 0) {
                    cmp.set("v.response", accountSuggested);                  
                } else {
                    var noResult = {'Name':'No result found...'};
                    var suggestions = [];
                    suggestions.push(noResult);
                    cmp.set("v.response",suggestions);
                }
                // Show suggestion box
                var userInputCmpName = userInputCmp.dataset.value;
                var resultDiv = cmp.find(userInputCmpName);
                cmp.set("v.searching", false);
                if(! $A.util.hasClass(resultDiv, 'slds-is-open'))
                    $A.util.toggleClass(resultDiv, 'slds-is-open');
                
            });
            
            if(! $A.util.isEmpty(cmp.get("v.category")) && !$A.util.isEmpty(cmp.get("v.selectedCountry"))){
                if($A.util.isEmpty(userInputCmp.value) || userInputCmp.value.length < 2) {
                    // Hide suggestion box
                    var userInputCmpName = userInputCmp.dataset.value;
                    var resultDiv = cmp.find(userInputCmpName);
                    if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                        $A.util.removeClass(resultDiv, 'slds-is-open');
                    }
                    cmp.set("v.suggestionBoxHeight", 0);
                    
                } else {
                    // Call search of accounts when user input at least 2 characters
                    $A.enqueueAction(action);
                }
            }
        } else {
            // Hide suggestion box
            var userInputCmpName = userInputCmp.dataset.value;
            var resultDiv = cmp.find(userInputCmpName);            
            if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                $A.util.removeClass(resultDiv, 'slds-is-open');
            }
        }
    },
    
    /**
		When a user select a sugestion from the suggestion box
	*/
    suggestionSelected: function(cmp, evt, hlp) {
        var suggestionSelected = evt.currentTarget;
        var accountIndex = suggestionSelected.dataset.rowIndex;
        
        if(suggestionSelected.dataset.value != 'No result found...') { //TODO Compare with custom label
            // Set input with selected value
            cmp.set("v.userInput", suggestionSelected.dataset.value);
            
            // Hide suggestion box
            var resultDiv = cmp.find("agencies");
            if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                $A.util.removeClass(resultDiv, 'slds-is-open');
            }
            cmp.set("v.suggestionBoxHeight", 0 );
            cmp.set("v.accountSelected", true);
            cmp.set("v.account", cmp.get("v.response")[accountIndex]);
            cmp.set("v.showCreateNew", true);
        }
    },
    
    createNew : function (cmp, evt, hlp) {
        cmp.set("v.account.Name", cmp.get("v.userInput"));
        cmp.set("v.showCreateNew", true);
        cmp.set("v.search", false);
    },
    
    closeError : function (c) {
        $A.util.toggleClass(c.find("errorMessage"), "slds-hide");
        $A.util.toggleClass(c.find("backdrop"), "slds-backdrop_open");
    }
})