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
    },
    //Data quality
    setCities: function(c,e){
        
        
        let mode;
        let currentState;

        if(e) mode = e.currentTarget.getAttribute('name');        
       // console.log('setCities mode -> '+mode);
        if(mode){
            c.set('v.predictions'+mode, []);
            
            currentState = c.get('v.account.'+mode+'State');
            console.log('setCities currentstate -> '+currentState);
        } 
        
        let citiesAvailable = c.get('v.cities');
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
            let citiesAvailable = c.get('v.cities');
            let idAndAlternateNames = c.get('v.idAndAlternateNames');

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
        h.copyBillingToShipping(c);
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
        c.set('v.errorStateProvince', false);
    }
})