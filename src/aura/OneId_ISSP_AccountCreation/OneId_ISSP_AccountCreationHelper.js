({
    getPicklists : function(component, event, helper) {
        var action = component.get("c.getCustomerTypePicklists");
        action.setParams({
            "root": component.get("v.rootCustomerType"),
            "leaf": component.get("v.currentCustomerType")
        });
        action.setCallback(this, function(a) {            
            var picklists = a.getReturnValue();
            component.set("v.picklists", picklists);
        });
        $A.enqueueAction(action);
    },
    
    getMetadataCustomerType : function(component, event, helper){
        var action = component.get("c.getMetadataCustomerType");
        action.setParams({
            "customerTypeKey": component.get("v.currentCustomerType")
        });
        action.setCallback(this, function(a) {
            var metadataCustomerType = a.getReturnValue();
            component.set("v.currentMetadataCustomerType", metadataCustomerType);
        });
        $A.enqueueAction(action);        
    },
    
    copyBillingToShipping : function(c, e, h) {
        //the init attribute is used so this code runs when handleInit is called

        if(c.get("v.copyAddress") || c.get("v.init")) {       
            
            c.set("v.showListShipping", false);

            c.find("ShippingCountry").set("v.value", c.get("v.country.Id"));
            c.set("v.countryShipping", c.get("v.countryInformation.countryMap")[c.get("v.country.Id")]);
            c.set("v.statesShipping", c.get("v.statesBilling"));        
            c.set("v.citiesShipping", c.get("v.citiesBilling"));
            c.set("v.allCitiesShipping", c.get("v.allCitiesBilling"));
            c.set("v.idAndAlternateNamesShipping", c.get("v.idAndAlternateNamesBilling"));
            c.set("v.cityNameIdShipping", c.get("v.cityNameIdBilling"));
            c.set("v.hierarchyCitiesShipping", c.get("v.hierarchyCitiesBilling"));
            c.set("v.shippingCityId", c.get("v.billingCityId"));
            c.set("v.shippingStateId", c.get("v.billingStateId"));                    
            c.set("v.ShippingCityEmpty", c.get("v.BillingCityEmpty"));
            c.set("v.ShippingStreetEmpty", c.get("v.BillingStreetEmpty"));
            c.set("v.ShippingCityStreetEmpty", c.get("v.BillingCityStreetEmpty"));
            c.set("v.cityDoesNotExistShipping", c.get("v.cityDoesNotExistBilling"));
            c.set("v.cityInAnotherStateShipping", c.get("v.cityInAnotherStateBilling"));            
            c.set("v.cityDoesNotExistShipping", c.get("v.cityDoesNotExistBilling"));
            c.set("v.account.ShippingCountry", c.get("v.account.BillingCountry"));                                     
            c.set("v.account.ShippingStreet", c.get("v.account.BillingStreet"));
			c.set("v.account.ShippingCity", c.get("v.account.BillingCity"));
            c.set("v.account.ShippingState", c.get("v.account.BillingState"));            
            c.set("v.account.ShippingPostalCode", c.get("v.account.BillingPostalCode"));
            c.set("v.countryHasStatesShipping", c.get("v.countryHasStatesBilling"));
            c.set("v.cityFirstSuggestionShipping", c.get("v.cityFirstSuggestionBilling"));
            c.set("v.predictionsShipping", c.get("v.predictionsBilling"));
            c.set("v.validShipping", c.get("v.validBilling"));
            c.set("v.validShipping", c.get("v.validBilling"));
            c.set("v.init",false);
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
    },
    
    //Data quality
    setCities: function(c,e,h,m){
        let mode;
        let currentState;
        mode = m;
        
        if(mode){
            c.set('v.predictions'+mode, []);
            currentState = c.get('v.account.'+mode+'State');
        } 
        
        let citiesAvailable = c.get('v.cities'+mode);
        let citiesOfThisState;
        
        if(currentState){
            
            citiesOfThisState = citiesAvailable[currentState];
        }else{
            
            citiesOfThisState = citiesAvailable["All"];
        }
        
        let hierarchyCities = {};
        
        for (var i = 0; i < citiesOfThisState.length; i++){
            if(citiesOfThisState[i]){

                let hierarchyAsciiName;
                let stateName;

                if(citiesOfThisState[i]["GeonameHierarchy_label__c"]) hierarchyAsciiName = citiesOfThisState[i]["GeonameHierarchy_label__c"].toLowerCase();
                if(citiesOfThisState[i]["IATA_ISO_State__r"]) stateName = citiesOfThisState[i]["IATA_ISO_State__r"].Name.toLowerCase();
                
                let geonameName;
                let hierarchyGeoName;

                if(stateName){
                    
                    if(citiesOfThisState[i]["GeonameName__c"]) geonameName = citiesOfThisState[i]["GeonameName__c"].toLowerCase();
                    
                    if(geonameName) hierarchyGeoName = stateName+' > '+geonameName;
                                        
                }
                

                if(hierarchyAsciiName){
                    hierarchyCities[hierarchyAsciiName] = {
                        "CityName" : citiesOfThisState[i]["Name"], 
                        "StateName": citiesOfThisState[i]["IATA_ISO_State__r"].Name,
                        "CityId"   : citiesOfThisState[i]["Id"], 
                        "StateId"  : citiesOfThisState[i]["IATA_ISO_State__r"].Id
                      };
                }
                                
                if(hierarchyGeoName){
                    hierarchyCities[hierarchyGeoName] = {
                        "CityName" : citiesOfThisState[i]["Name"], 
                        "StateName": citiesOfThisState[i]["IATA_ISO_State__r"].Name,
                        "CityId"   : citiesOfThisState[i]["Id"], 
                        "StateId"  : citiesOfThisState[i]["IATA_ISO_State__r"].Id
                    };
                }  
            } 
        }
        
        if(mode){
            c.set('v.hierarchyCities'+mode, hierarchyCities);
        }else{
            c.set('v.hierarchyCitiesBilling', hierarchyCities);
            c.set('v.hierarchyCitiesShipping', hierarchyCities);
        }
		if(c.get("v.init")){
            h.copyBillingToShipping(c,e,h);
        }
        c.set("v.spinner", false);
    },
    
    getPredictions: function(c, e, h, v, m){                
        //Data quality//
        let currentState = c.get('v.account.'+m+'State');
        let citiesAvailable = c.get('v.cities'+m);
        let idAndAlternateNames = c.get('v.idAndAlternateNames'+m);
        let citiesToSearch = [];
        
        if(currentState){            
            let citiesOfThisState = citiesAvailable[currentState];
            citiesToSearch = citiesOfThisState;        
        }else{
            citiesToSearch = citiesAvailable["All"];
        }
        
        let cityNames = [];
        let inputValue = v.toLowerCase();
        
        if(inputValue){
            
            for (var i = 0; i < citiesToSearch.length; i++){
                if(citiesToSearch[i]){
                    let cityId = citiesToSearch[i]["Id"];
                    
                    let cityName = citiesToSearch[i]["Name"];
                    
                    let hierarchy = citiesToSearch[i]["GeonameHierarchy_label__c"];
                    
                    let alternateNames = idAndAlternateNames[cityId]?idAndAlternateNames[cityId]["GeonameAlternateNames__c"]:null;
                    
                    let value = cityName;
                    
                    if(alternateNames) value+=','+alternateNames;
                    
                    if(value.toLowerCase().includes(inputValue)) cityNames.push(hierarchy);
                }
            }
            
            //sort array by city length
            
            cityNames.sort(function (a, b) { return a.split('>')[1].length - b.split('>')[1].length; });
            
            c.set("v.predictions"+m, cityNames.slice(0,30));
            
        }else{
            c.set("v.predictions"+m, []);
        }
        c.set('v.account.'+m+'City',v);
        c.set('v.showList'+m, true);
        
        //Data quality//
    },
    
    removeList: function(c, h, m){
        c.set('v.showList'+m, false);
    },
    
    updateAddress: function(c,e,h,m){
        //change of address makes the validation null
        c.set("v.valid"+m, 0);        
        
        //check if information need to be passed to shipping as well
        h.copyBillingToShipping(c, e, h);
    },
    
    toggleInvalidCityWarning: function(c, e, h){
        c.set('v.cityDoesNotExist', false);
        c.set('v.cityInAnotherState', false);                
    },
    
    clearWarnings: function(c,e,h,m){     
                
        c.set('v.cityDoesNotExist'+m, false);
        c.set('v.cityInAnotherState'+m, false);
        c.set('v.'+m+'CityEmpty', false);
        c.set('v.'+m+'StreetEmpty', false);
        c.set('v.'+m+'CityStreetEmpty', false);
        c.set('v.validationError', false);
        if(c.get('v.cityFirstSuggestion'+m)){
            c.set('v.cityFirstSuggestion'+m, false);
        }else{
            var warningElement = document.getElementById("firstSuggestion"+m);
            warningElement.classList.add("slds-hide");
        }
    },
    
    clearContextLabelWarnings: function(c,e,h, m){
        let cityElement = c.find(m+'City');
        let addDocComponent = c.find('addDocComponent'+m);
        let streetElement = addDocComponent.find('Street');    
        cityElement.set('v.errors', null);
        streetElement.set('v.errors', null);        
        c.set('v.error'+m+'StateProvince', false);
    },
    
    getStates : function(c,e,h,m,cn){
        var country = cn;
        var action = c.get("c.getStates");
        action.setParams({"country": country});
        action.setCallback(this, function(response){
            let fetchedStates = [""];
            let res = response.getReturnValue();
            let states = res.states;
            let idAndAlternateNames = res.idAndAlternateNames;             
            let stateCities = {};
            let allCities = [];
            
            for(var i = 0; i < states.length; i++){
                fetchedStates.push(states[i].Name);
                stateCities[states[i].Name] = states[i].IATA_ISO_Cities__r;                
                allCities.push(states[i].IATA_ISO_Cities__r);                
            
            }
            
            let allCitiesMerged = [].concat.apply([], allCities);            
           
            stateCities["All"] = allCitiesMerged;
            
            c.set('v.cities'+m, stateCities);
            c.set('v.states'+m, fetchedStates);
            c.set('v.allCities'+m, allCitiesMerged);
            c.set('v.idAndAlternateNames'+m, idAndAlternateNames);
            h.setCities(c, null, h, m);            
        });
        
        $A.enqueueAction(action);
        
    },
    
    //only used by shipping 
    setCountry: function(c,e,h){
        if(c.get("v.selectedCountry")){
            var countryShipping = c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")];

            c.set("v.countryShipping", countryShipping);	
            c.set("v.account.ShippingCountry", countryShipping.Name);
            h.checkCountryStates(c,e,h,'Shipping',countryShipping);
        }else{
            c.set('v.statesShipping', null);            
        }
    },
    
    checkCountryStates: function(c, e, h, m, cn){
        c.set("v.countryHasStates"+m, false);
        c.set('v.account.'+m+'State', null);
        
        //country has states
        let chs = cn.Region_Province_and_Cities_Enabled__c;
        
        if(chs) {
            c.set("v.countryHasStates"+m, true);
            c.set("v.spinner", true);
            h.getStates(c,e,h,m,cn.Name);
        }else{
           
            c.set('v.cities'+m, null);
            c.set('v.states'+m, null);
            c.set('v.allCities'+m, null);
            c.set('v.idAndAlternateNames'+m, null);            
            c.set('v.cityNameId'+m, null);
        }
    },

    selectFirstPrediction: function(c,e,h,m){
        
        let stateElement = c.find(m+'State');
        let currentState;
        let cityElement = c.find(m+'City');
        let city = cityElement.get('v.value');

        if(Array.isArray(stateElement)){
            currentState = stateElement[0].get('v.value');
        }else{
            currentState = stateElement.get('v.value');
        }  
        
        let predictions = c.get('v.predictions'+m);
        let hierarchyCities = c.get('v.hierarchyCities'+m);
        let idAndAlternateNames = c.get('v.idAndAlternateNames'+m);
        let isInputInAlternateNames = false;

        if(predictions.length === 1){
            let alternateNames = idAndAlternateNames[hierarchyCities[predictions[0].toLowerCase()].CityId]["GeonameAlternateNames__c"];            
            
            if(alternateNames) isInputInAlternateNames = alternateNames.toLowerCase().includes(city.toLowerCase());                        
        }
        
        if((!(currentState?true:false) && predictions.length > 0) || isInputInAlternateNames) {
            c.set('v.cityFirstSuggestion'+m,true);
            var warningElement = document.getElementById("firstSuggestion"+m);
            warningElement.classList.remove("slds-hide");
            let hierarchyCities = c.get('v.hierarchyCities'+m);
            c.set('v.suggestion'+m,predictions[0]);
            let selectedHierarchy = predictions[0].toLowerCase();        
            c.set('v.predictions'+m, []); 
            c.set('v.account.'+m+'City', hierarchyCities[selectedHierarchy].CityName);
            c.set('v.account.'+m+'State', hierarchyCities[selectedHierarchy].StateName);
            h.updateAddress(c,e,h,m);
        }
    }
})