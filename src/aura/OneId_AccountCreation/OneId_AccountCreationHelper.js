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

	copyBillingToShipping : function(c, e, h) {
    
        if(c.get("v.copyAddress")) {   
            
            if(c.get("v.account.BillingCountry") !== c.get("v.account.ShippingCountry")){
                c.find("ShippingCountry").set("v.value", c.get("v.country.Id"));
                h.setCountry(c,e,h);
            }            
            c.set("v.account.ShippingStreet", c.get("v.account.BillingStreet"));
			c.set("v.account.ShippingCity", c.get("v.account.BillingCity"));
            c.set("v.account.ShippingState", c.get("v.account.BillingState"));            
            c.set("v.account.ShippingPostalCode", c.get("v.account.BillingPostalCode"));
            c.set("v.validShipping", c.get("v.validBilling"));
            
            c.find("ShippingState").set("v.value", c.get("v.account.ShippingState"));            
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
    setCities: function(c,e,m){
        
        
        let mode;
        let currentState;
        mode = m;
                
       // console.log('setCities mode -> '+mode);
        if(mode){
            c.set('v.predictions'+mode, []);
            
            currentState = c.get('v.account.'+mode+'State');
            console.log('setCities currentstate -> '+currentState);
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
            if(citiesOfThisState[i])
                hierarchyCities[citiesOfThisState[i]["GeonameHierarchy_label__c"]] = {"CityName" : citiesOfThisState[i]["Name"], "StateName": citiesOfThisState[i]["IATA_ISO_State__r"].Name};  
        }
        console.log('setCities hierarchy -> '+hierarchyCities);
        if(mode){
            c.set('v.hierarchyCities'+mode, hierarchyCities);
        }else{
            c.set('v.hierarchyCitiesBilling', hierarchyCities);
            c.set('v.hierarchyCitiesShipping', hierarchyCities);
        }
        console.log('Hierarchy citys -> '+hierarchyCities);
    },

    getPredictions: function(c, e, h, v, m){                
        
        
        //Data quality//
            
            let currentState = c.get('v.account.'+m+'State');
            let citiesAvailable = c.get('v.cities'+m);
            let idAndAlternateNames = c.get('v.idAndAlternateNames'+m);

            let citiesToSearch = [];
            //console.log('All cities for state -> '+JSON.stringify(citiesAvailable) );
            if(currentState){            
                let citiesOfThisState = citiesAvailable[currentState];
                citiesToSearch = citiesOfThisState;        
            }else{
             //let allCities = c.get('v.allCities');
             //citiesToSearch = allCities;
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

                        let alternateNames = idAndAlternateNames[cityId]["GeonameAlternateNames__c"];
                        
                        let value = cityName;

                        if(alternateNames)
                            value+=alternateNames;
                    
                        if(value.toLowerCase().includes(inputValue))
                            cityNames.push(hierarchy);
                    }
                    
                }
                
                c.set("v.predictions"+m, cityNames);
                
            }else{
                c.set("v.predictions"+m, []);
            }
            c.set('v.account.'+m+'City',v);
            c.set('v.showList'+m, true);
       // console.log('cityNames -> '+cityNames);
        //Data quality//
        
    },

    removeList: function(c, h, m){
        c.set('v.showList'+m, false);
    },

    updateAddress: function(c,e,h,m){
      
        //change of addres makes the validation null
        c.set("v.valid"+m, 0);        
        //check if information need to be passed to shipping as well
        h.copyBillingToShipping(c, e, h);
    },

    toggleInvalidCityWarning: function(c, e, h){
        c.set('v.cityDoesNotExist', false);
        c.set('v.cityInAnotherState', false);                
    },

    clearWarnings: function(c,e,h, m){     
           
        c.set('v.cityInAnotherCountry'+m, false);         
        c.set('v.cityDoesNotExist'+m, false);
        c.set('v.cityInAnotherState'+m, false);
        c.set('v.'+m+'CityEmpty', false);
        c.set('v.'+m+'StreetEmpty', false);
        c.set('v.'+m+'CityStreetEmpty', false);
        c.set('v.validationError', false);
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

        c.set('v.account.'+m+'State', null);
        
        var country = cn;

       // if(m === 'Billing')
        //    country = c.get("v.country").Name;
        //if(m === 'Shipping')
         //   country = c.get("v.countryShipping").Name;

        console.log('@@MAC country-> '+country);
        
        var action = c.get("c.getStates");
        action.setParams({"country": country});
        
        action.setCallback(this, function(response){
            let fetchedStates = [""];
            let res = response.getReturnValue();
            let states = res.states;
            let idAndAlternateNames = res.idAndAlternateNames;             
            let stateCities = {};
            let allCities = [];
            let stateNameId = {};
            let cityNameId = {};
            
            for(var i = 0; i < states.length; i++){
                
                fetchedStates.push(states[i].Name);
                stateCities[states[i].Name] = states[i].IATA_ISO_Cities__r;                
                allCities.push(states[i].IATA_ISO_Cities__r);                
                stateNameId[states[i].Name] = states[i];
            }

            let allCitiesMerged = [].concat.apply([], allCities);            
            let name = '';
            let id;
            for(var j = 0; j < allCitiesMerged.length; j++){

                if(allCitiesMerged[j]){
                    
                    id = allCitiesMerged[j];
                    name  = allCitiesMerged[j].Name;

                    cityNameId[name] = id;
                }            
            }
            
            stateCities["All"] = allCitiesMerged;
            
            c.set('v.cities'+m, stateCities);
            c.set('v.states'+m, fetchedStates);
            c.set('v.allCities'+m, allCitiesMerged);
            c.set('v.idAndAlternateNames'+m, idAndAlternateNames);
            c.set('v.stateNameId'+m, stateNameId);
            c.set('v.cityNameId'+m, cityNameId);
            h.setCities(c, null, m);            

        });

        $A.enqueueAction(action);

        var action = c.get("c.getAllCities");
        
        console.log('COUNTRY before inside callback -> '+country);
        action.setParams({"country": country});

        action.setCallback(this,  function(response){       
            
           // console.log('response -> '+JSON.stringify(response.getReturnValue());
           
            c.set("v.spinner", false);            
            c.set('v.allCitiesAllCountries'+m, JSON.stringify(response.getReturnValue())); 
           
           // console.log('All cities all countries -> '+m+' -> '+c.get('v.allCitiesAllCountries'+m));
        });

        
        
        $A.enqueueAction(action);
        
    },

    setCountry: function(c,e,h){
        if(c.get("v.selectedCountry")){
            
            
            c.set("v.countryShipping", c.get("v.countryInformation.countryMap")[c.get("v.selectedCountry")]);	
            let countryName = c.get("v.countryShipping").Name;
            
            c.set("v.account.ShippingCountry", countryName);
            
            h.checkCountryStates(c,e,h,'Shipping',countryName);
        }
    },

    checkCountryStates: function(c, e, h, m, cn){
        c.set("v.countryHasStates"+m, false);
        let cwsa = c.get("v.listOfCountriesWithStates");
        console.log('@@MAC -> cwsa - '+cwsa);
        for(let i = 0; i < cwsa.length; i++){
            console.log('@@MAC -> cwsa[i] - '+cwsa[i]+'///  '+cn+' <- cn');
            //cn is the country name
            if(cwsa[i] === cn){
                
                c.set("v.countryHasStates"+m, true);
            }
        }

        //country has states
        let chs = c.get("v.countryHasStates"+m);
        
        if(chs) {
            c.set("v.spinner", true);
            h.getStates(c,e,h,m,cn);
        }else{
            c.set('v.cities'+m, null);
            c.set('v.states'+m, null);
            c.set('v.allCities'+m, null);
            c.set('v.idAndAlternateNames'+m, null);
            c.set('v.stateNameId'+m, null);
            c.set('v.cityNameId'+m, null);
        }
    }
})