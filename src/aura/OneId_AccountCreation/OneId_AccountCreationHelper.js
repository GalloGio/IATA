({
    setCategory : function (c) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");
        var sectors = c.get("v.sectors");

        var catoptions = [];
        if(c.get("v.changeCategory") && !$A.util.isEmpty(sectors)){
            catoptions = c.get("v.sectors")[sector].dependentValues;
        }else{
            /* WMO-391 */
            var categories = c.get("v.sectors")[sector].dependentValues;
            catoptions = [{label: this.getCategoryLabel(categories, category) , value : category, selected : true}];
        }

        c.find("categorySelection").set("v.options", catoptions);
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
    /* WMO-391*/
    getCategoryLabel : function(categories, api_value) {
        if(categories) {
            for(var i=0; i<categories.length; i++) {
                if(categories[i].value == api_value) {
                    return categories[i].label;
                }
            }
        }
        return api_value;
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

                let hierarchyAsciiName = citiesOfThisState[i]["GeonameHierarchy_label__c"].toLowerCase();
                let hierarchyGeoName = citiesOfThisState[i]["IATA_ISO_State__r"].Name.toLowerCase()+' > '+citiesOfThisState[i]["GeonameName__c"].toLowerCase();

                hierarchyCities[hierarchyAsciiName] = {
                                                        "CityName" : citiesOfThisState[i]["Name"], 
                                                        "StateName": citiesOfThisState[i]["IATA_ISO_State__r"].Name,
                                                        "CityId"   : citiesOfThisState[i]["Id"], 
                                                        "StateId"  : citiesOfThisState[i]["IATA_ISO_State__r"].Id
                                                      };
                hierarchyCities[hierarchyGeoName] = {
                                                        "CityName" : citiesOfThisState[i]["Name"], 
                                                        "StateName": citiesOfThisState[i]["IATA_ISO_State__r"].Name,
                                                        "CityId"   : citiesOfThisState[i]["Id"], 
                                                        "StateId"  : citiesOfThisState[i]["IATA_ISO_State__r"].Id
                                                    };                                                      
                  
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

                        if(alternateNames) value+=alternateNames;
                                            
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
            c.set("v.countryShipping", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);	
            let country = c.get("v.countryShipping");
            c.set("v.account.ShippingCountry", country.Name);
            h.checkCountryStates(c,e,h,'Shipping',country);
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

        if(Array.isArray(stateElement)){
            currentState = stateElement[0].get('v.value');
        }else{
            currentState = stateElement.get('v.value');
        }  
        
        let predictions = c.get('v.predictions'+m);
        if(!(currentState?true:false) && predictions.length > 0) {
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