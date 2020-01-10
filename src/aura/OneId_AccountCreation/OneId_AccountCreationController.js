({
    handleInit : function (c, e, h) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");

        var action = c.get("c.getSectors");
        action.setCallback(this, function(a) {
            var sectorsMap = a.getReturnValue();
            c.set("v.sectors", sectorsMap);


            if(c.get("v.changeSector")){
                var options = [];
                for (var key in sectorsMap){
                    options.push(sectorsMap[key]);
                }

                c.find("sectorSelection").set("v.options", options);
            }else{
                var option = sectorsMap[sector];/* WMO-391 */
                if(option) {
                    c.find("sectorSelection").set("v.options", [{label: option.label, value : option.value, selected : true}]);
                } else {
                	c.find("sectorSelection").set("v.options", [{label: sector, value : sector, selected : true}]);
            	}
            }

            h.setCategory(c);
        });
        $A.enqueueAction(action);
        

        var action = c.get("c.getAccountLabels");
        action.setCallback(this, function(a) {
            
            c.set("v.accountLabels", a.getReturnValue());
        });
        $A.enqueueAction(action);

        //Data Quality//
               
            h.checkCountryStates(c,e,h,'Billing',c.get("v.country"));
                                 
        //Data Quality//
    },
    sectorChanged : function (c, e, h) {
        h.setCategory(c);
    },
    jsLoaded: function(c, e, h){
        c.set("v.hasJquery", true);
        if(!$A.util.isEmpty(c.get("v.country.ISO_Code__c"))) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    changedCountry : function(c, e,h){
        if(c.get("v.hasJquery")) h.placePhoneFlags(c.get("v.country.ISO_Code__c"));
    },

    setAddress: function (c, e, h) {
        // FIll all address fields when user select a validated address from suggestion
        var addressObj = e.getParam("addressSelected");
        var addressType = e.getParam("addressType");

        if(!$A.util.isEmpty(addressObj.street)){
            c.set("v.account."+addressType+"Street", addressObj.street);
        }else if(!$A.util.isEmpty(addressObj.deliveryservice)){
            c.set("v.account."+addressType+"Street", addressObj.deliveryservice);
        }
        
        //Commented as per Data Quality project
        //This way the only boxes that are filled according address doctor are Street and Postal Code

       /* if(!$A.util.isEmpty(addressObj.locality)){
            c.set("v.account."+addressType+"City", addressObj.locality);
        }
        if(!$A.util.isEmpty(addressObj.province)){
            c.set("v.account."+addressType+"State", addressObj.province);
        }*/

        if(!$A.util.isEmpty(addressObj.postalCode)){
            c.set("v.account."+addressType+"PostalCode", addressObj.postalCode);
        }

        //reset validation
        c.set("v.valid"+addressType, 0);
        c.set("v.suggestionsMode", "hidden");
        
        //clear warnings
        h.clearWarnings(c,e,h,addressType);
        h.clearContextLabelWarnings(c,e,h,addressType);
        
        // if copy checkbox is selectected copy billing to shipping
        h.copyBillingToShipping(c, e, h);

        
    },

    validateAddress : function (c, e, h) {
        
        //Data quality//
        
        var mode = e.currentTarget.dataset.mode;
        let currentState;
        let addDocComponent = c.find('addDocComponent'+mode);       
        let stateElement = c.find(mode+'State');        
        let cityElement = c.find(mode+'City');        
        let streetElement = addDocComponent.find('Street');        
              
        c.set('v.error'+mode+'StateProvince', false);
        c.set('v.cityDoesNotExist'+mode, false);
        c.set('v.cityInAnotherState'+mode, false);
        c.set('v.'+mode+'CityEmpty', false);
        c.set('v.'+mode+'StreetEmpty', false);
        c.set('v.'+mode+'CityStreetEmpty', false);
        c.set('v.validationError', false);
        c.set('v.cityInvalidWarning', false);
        c.set('v.stateInvalidWarning', false);
        c.set('v.cityDoesntExistWarning', false);
        
        cityElement.set('v.errors', null);
        streetElement.set('v.errors', null);
        
        if(stateElement){
            
            //This verification is made because sometimes stateElement is an Array
            //for more info please refer to -> https://salesforce.stackexchange.com/questions/227712/lightning-component-findauraid-returns-an-array-consisting-of-one-element 
          
            if(Array.isArray(stateElement)){
                currentState = stateElement[0].get('v.value');
            }else{
                currentState = stateElement.get('v.value');
            }  
        } 
        
        let currentCity = cityElement.get('v.value');
		let currentStreet = streetElement.get('v.value');
	    
		//CHECK IF THERE IS A CITY AND A STREET//
        if(currentCity && currentStreet){

            let countryHasStates = c.get("v.countryHasStates"+mode);
            currentCityLowerCase = currentCity.toLowerCase();
            currentStreetLowerCase = currentStreet.toLowerCase();
            if(currentState) { currentState = currentState.toLowerCase(); }
        
            //THE FOLLOWING LOGIC WAS MOVED INSIDE THIS CONDITION//
        
            
            c.set("v.valid"+mode, 2); //set spinner
            if(countryHasStates){

            let hierarchyCities = c.get('v.hierarchyCities'+mode);
            let hierarchyLower; 
            if(currentState) hierarchyLower = currentState.toLowerCase()+' > '+currentCityLowerCase;

            
            let citiesAvailable = c.get('v.cities'+mode);            
            let citiesToSearch = citiesAvailable["All"];
            let cityAndStateMatch = false;
            let cityMatch = false;
            
            cityAndStateMatch = hierarchyCities[hierarchyLower]?true:false;

            for(var i = 0; i < citiesToSearch.length; i++){                
                if(citiesToSearch[i]){
                    let cityName = citiesToSearch[i]["Name"].toLowerCase();
                    let cityStateName = citiesToSearch[i]["IATA_ISO_State__r"].Name.toLowerCase();			                    
                    if(cityName===currentCityLowerCase&&cityStateName!==currentState) cityMatch=true;
                }                
            }
            
            if(!cityAndStateMatch && !cityMatch){
            
                c.set('v.cityDoesNotExist'+mode, true);        
                c.set('v.invalidCity', currentCity);
                c.set('v.cityInvalidWarning', false);
                c.set('v.cityDoesntExistWarning', true);
                c.set('v.stateInvalidWarning', false);
                
                
            }else if(cityMatch && !cityAndStateMatch){

                c.set('v.cityInAnotherState'+mode, true);
                c.set('v.invalidCity', currentCity);
                c.set('v.cityInvalidWarning', false);
                c.set('v.cityDoesntExistWarning', false);
                c.set('v.stateInvalidWarning', true);
            
            }else{
                c.set('v.cityDoesNotExist'+mode, false);
                c.set('v.cityInAnotherState'+mode, false);
                c.set('v.invalidCity', '');           
                c.set('v.cityInvalidWarning', false);
                c.set('v.cityDoesntExistWarning', false);
                c.set('v.stateInvalidWarning', false);         
            }
        }
            

            if( c.get('v.cityDoesNotExist'+mode) || c.get('v.cityInAnotherState'+mode) ){
                c.set('v.valid'+mode, 3);
                h.copyBillingToShipping(c, e, h);
            }else{

            var addressInfo = {
                street : c.get("v.account."+mode+"Street"),
                locality : c.get("v.account."+mode+"City"),
                postalCode : c.get("v.account."+mode+"PostalCode"),
                province : c.get("v.account."+mode+"State"),
                countryCode : mode==='Billing'?c.get("v.country.ISO_Code__c"):c.get("v.countryShipping.ISO_Code__c")
            };

            var action = c.get("c.checkAddress");

            action.setParams({"info": $A.util.json.encode(addressInfo)});
    
            action.setCallback(this, function(a) {
                var addresses = a.getReturnValue();              
                var isValidAddress = addresses.length > 0;
    
                c.set("v.valid"+mode, isValidAddress ? 1 : -1);
    
                if(isValidAddress){
                    if(addresses.length == 1){
                        var cmpEvent = c.getEvent("addressSelected");
                        cmpEvent.setParams({
                            "addressType" : mode,
                            "addressSelected" : addresses[0] });
                        cmpEvent.fire();  
    
                        c.set("v.valid"+mode, 1);
                        h.copyBillingToShipping(c, e, h);
                    }else{
                        c.set("v.suggestions", addresses);
                        c.set("v.suggestionsMode", mode);
                    }
                }else{
                    
                    c.set("v.suggestionsMode", "hidden");
                    c.set("v.valid"+mode, -1);
                    h.copyBillingToShipping(c, e, h);
                }
            });

            $A.enqueueAction(action);
        }    
        //THE PREVIOUS LOGIC WAS MOVED INSIDE THIS CONDITION//

        //IF THERE IS NO CITY AND THERE IS A STREET//
        }else if(!currentCity && currentStreet){
            
            c.set('v.'+mode+'CityEmpty', true);
        
        //IF THERE IS NO STREET AND THERE IS A CITY//
        }else if(currentCity && !currentStreet){
            
            c.set('v.'+mode+'StreetEmpty', true);            
        
        }else{

            c.set('v.'+mode+'CityStreetEmpty', true);
        
        }
  
		//Data quality//
    },
    
    copyBilling: function (c, e, h) {
        h.clearContextLabelWarnings(c, null, null, 'Shipping');
        h.clearWarnings(c,e,h,'Shipping');

        if(!c.get("v.copyAddress")){
            c.set("v.showListShipping", false);
            c.find("ShippingCountry").set("v.value",'');
            c.set("v.countryShipping", '');
            c.set("v.statesShipping", []);        
            c.set("v.citiesShipping", []);
            c.set("v.allCitiesShipping", {});
            c.set("v.idAndAlternateNamesShipping", {});
            c.set("v.cityNameIdShipping", {});
            c.set("v.hierarchyCitiesShipping", {});
            c.set("v.shippingCityId", '');
            c.set("v.shippingStateId", '');                       
            c.set("v.ShippingCityEmpty", false);
            c.set("v.ShippingStreetEmpty", false);
            c.set("v.ShippingCityStreetEmpty", false);
            c.set("v.cityDoesNotExistShipping", false);
            c.set("v.cityInAnotherStateShipping", false);
            c.set("v.cityDoesNotExistShipping", false);
            c.set("v.account.ShippingCountry", '');                                     
            c.set("v.account.ShippingStreet", '');
			c.set("v.account.ShippingCity", '');
            c.set("v.account.ShippingState", '');            
            c.set("v.account.ShippingPostalCode", '');
            c.set("v.countryHasStatesShipping",false);
            c.set("v.suggestionShipping", '');
            c.set("v.predictionsShipping", '');
            c.set("v.cityFirstSuggestionShipping", false);
            c.set("v.validShipping", 0);
        }

        //check if information need to be passed to shipping as well
        h.copyBillingToShipping(c, e, h);
    },
    
    updateAddress: function (c, e, h) {  
        
        let localId = e.getSource().getLocalId();
        let mode = localId.includes('Billing')?'Billing':'Shipping';        
        h.clearWarnings(c,e,h, mode, true);
        h.clearContextLabelWarnings(c,e,h, mode);
        h.updateAddress(c,e,h,mode);        
    },

    updateState: function(c,e,h){
        //Data quality//
        
        let mode = e.currentTarget.getAttribute('data-mode');
        let hierarchyCities = c.get('v.hierarchyCities'+mode);
        let selectedHierarchy = e.currentTarget.getAttribute('data-attriVal').toLowerCase();
        
        c.set('v.predictions'+mode, []); 
        c.set('v.account.'+mode+'City', hierarchyCities[selectedHierarchy].CityName);
        c.set('v.account.'+mode+'State', hierarchyCities[selectedHierarchy].StateName);
        h.updateAddress(c,e,h,mode);
        //Data quality//
    },
    validateNumber : function(c, e, h){
        var input = c.find(e.getSource().getLocalId());
        input.set("v.value", input.get("v.value").replace(/[^0-9+]|(?!^)\+/g, ''));
    },

    validateRequiredFields: function(c) {
        
        //Data quality//
        
        c.set('v.account.Data_quality_feedback__c',null);
        
        let modes = ['Billing', 'Shipping'];
        let billingCityId;
        let billingStateId;
        let shippingCityId;
        let shippingStateId;
        let billingCityDoesNotExist = c.get('v.cityDoesNotExistBilling');
        let billingCityInAnotherState = c.get('v.cityInAnotherStateBilling');
        
        let shippingCityDoesNotExist = c.get('v.cityDoesNotExistShipping');
        let shippingCityInAnotherState = c.get('v.cityInAnotherStateShipping');
        
        
        for(let i = 0 ; i < modes.length ; i++){            
            
            let hierarchyCities = c.get('v.hierarchyCities'+modes[i]);

            //checking if the value of the state is in the inputBox(added as workaround) or in a picklist
            
            let stateElement = (c.get("v.copyAddress")&&modes[i]==='Shipping')?c.find('InputShippingState'):c.find(modes[i]+'State');
            let cityElement = c.find(modes[i]+'City');
            let addDocComponent = c.find('addDocComponent'+modes[i]);
            let streetElement = addDocComponent.find('Street');
            
            //State/Province Picklist value should only be retrieved when the picklist exists.
            let state;
            if(stateElement){ 
                
                if(Array.isArray(stateElement)){
                    state = stateElement[0].get('v.value');
                }else{
                    state = stateElement.get('v.value');
                }
            }
            let city = cityElement.get('v.value');
            let street = streetElement.get('v.value');
            
            let emptyCity =  $A.util.isEmpty(city);
            let emptyStreet =$A.util.isEmpty(street);
            let hierarchy = state+' > '+city;
            let hierarchyLower = hierarchy.toLowerCase();
            let predictions = c.get("v.predictions"+modes[i]);
            
            if(hierarchyCities[hierarchyLower]){
                if(i===0){
                    billingCityId = hierarchyCities[hierarchyLower].CityId;
                    billingStateId = hierarchyCities[hierarchyLower].StateId;                    
                    c.set('v.account.BillingCity', hierarchyCities[hierarchyLower].CityName);
                }else{
                    shippingCityId = hierarchyCities[hierarchyLower].CityId;
                    shippingStateId = hierarchyCities[hierarchyLower].StateId;
                    c.set('v.account.ShippingCity', hierarchyCities[hierarchyLower].CityName);
                }
            }

            if( emptyCity || emptyStreet ){
                c.set('v.valid'+modes[i], 0);

                if(emptyCity){
                    cityElement.set('v.errors', [{message: $A.util.format($A.get("$Label.c.AMS_DQ_City_Cumpulsory"),modes[i],modes[i]) }]);
                }else{
                    cityElement.set('v.errors', null);
                }
                if(emptyStreet){
                    streetElement.set('v.errors', [{message: $A.util.format($A.get("$Label.c.AMS_DQ_Street_Compulsory"),modes[i],modes[i]) }]);
                }else{
                    streetElement.set('v.errors', null);
                }            
            }
        }                   
        
        //Data quality//
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        var category = c.find("categorySelection");
        
        var email = c.find("email");
        var emailValue = email.get("v.value");

        var officePhone = c.find("officePhone");        

        var domPhone = officePhone.getElement();
        var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;

        var legalName = c.find('legalName');
        var legalNameValue = legalName.get('v.value');
        var isAllFilled = true;

        if($A.util.isEmpty(category.get("v.value"))){
            category.set("v.errors",[{message: $A.get("$Label.c.OneId_CategoryError")}]);
            isAllFilled = false;
        } else {
            category.set("v.errors",null);
            var catValue = category.get("v.value");
            if(catValue == 'Other') {
                var catOther = c.find("catOtherVal");
               
                if(!$A.util.isEmpty(catOther) && $A.util.isEmpty(catOther.get("v.value"))) {            
                    catOther.set("v.errors",[{message: $A.get("$Label.c.ISSP_YouMustEnter")}]);
                    isAllFilled = false;
                } else {
                    catOther.set("v.errors", false);                
                }            
            }
        }

        if(!$A.util.isEmpty(emailValue) && !emailValue.match(regExpEmailformat)){
           email.set("v.errors",[{message: $A.get("$Label.c.ISSP_AMS_Invalid_Email")}]);
           isAllFilled = false;
        }else{
           email.set("v.errors",null);
        }

        if($A.util.isEmpty(legalNameValue)){
            legalName.set("v.errors",[{message: $A.get("$Label.c.ISSP_Registration_Error_LegalName")}]);
            isAllFilled = false;
            let lnc = document.getElementById('legalNameContainer');
            lnc.scrollIntoView();
         }else{
            legalName.set("v.errors",null);
         }

        if($A.util.isEmpty(officePhone.get("v.value"))){
           officePhone.set("v.errors",[{message: $A.get("$Label.c.ISSP_Registration_Error_BusinessPhone")}]);
           isAllFilled = false;

           setTimeout(function(){
                $(domPhone).intlTelInput("setCountry", "");
                $(domPhone).intlTelInput("setCountry", country);
            }, 100);
        }else{
           officePhone.set("v.errors",null);
        }

        if(c.get("v.validBilling") == 0){
            c.set("v.validationError", true);
            let ac = document.getElementById('addrContainer');
            isAllFilled = false;
            ac.scrollIntoView();
        }else{
            c.set("v.validationError", false);
        }

        if(c.get("v.validShipping") == 0){
            c.set("v.validationError", true);
            let ac = document.getElementById('addrContainer');
            isAllFilled = false;
            ac.scrollIntoView();
        }else{
            c.set("v.validationError", false);
        }
        
        
       /* MME TEMP for test purpose*/
//        isAllFilled = true;        
//Data quality//
        if(isAllFilled){
          c.getEvent("newAccountSet")
            .setParams({
                "state" : "newAccountSet",
                "account" : c.get("v.account")
            }).fire();             
          
            let dataQualityFeedback = ''; 
            
                                
                
            if(billingCityInAnotherState) dataQualityFeedback=';Billing city found in another state';                    
                
            if(billingCityDoesNotExist) dataQualityFeedback=';Billing city not found in our Database';
            
            if(c.get("v.validBilling") === -1) dataQualityFeedback=';Billing address not found by address doctor';                    
                
            if(shippingCityInAnotherState) dataQualityFeedback+=';Shipping city found in another state'; 
                    
            if(shippingCityDoesNotExist) dataQualityFeedback+=';Shipping city not found in our Database'; 
            
            if(c.get("v.validShipping") === -1) dataQualityFeedback+=';Shipping address not found by address doctor'; 
            
            if(billingCityId) c.set('v.billingCityId', billingCityId);
            
            if(billingStateId) c.set('v.billingStateId', billingStateId);

            if(shippingCityId) c.set('v.shippingCityId', shippingCityId);
            
            if(shippingStateId) c.set('v.shippingStateId', shippingStateId);

            c.set('v.account.Comment_data_quality_feedback__c','Registration errors.');
            c.set('v.account.Data_quality_feedback__c', dataQualityFeedback.substring(1));
            
        }
        
        //Data quality//
        return isAllFilled;        
    },

    closeModal: function(c){
        c.set("v.suggestionsMode", "hidden");
    },

    parseCategory: function(c){
        var category = c.find("categorySelection");
        var catValue = category.get("v.value");
        if(!$A.util.isEmpty(catValue) && catValue == 'Other') {
            c.set("v.categoryOther", true);
        } else {
            c.set("v.categoryOther", false);
        }
    },

    suggestionSelected: function(c, e) {
        
        // Set input with selected value
        var response = c.get("v.suggestions");

        var index = parseInt(e.currentTarget.dataset.rowIndex);
        var addressType = c.get("v.suggestionsMode");
        
        var cmpEvent = c.getEvent("addressSelected");
        cmpEvent.setParams({
            "addressType" : addressType,
            "addressSelected" : response[index] });
        cmpEvent.fire();
        c.set("v.suggestionsMode", "hidden");   
    },


    setCitiesUpdateAddress: function(c,e,h){
        
        let localId = e.getSource().getLocalId();
        let m = localId.includes('Billing')?'Billing':'Shipping';   
        c.set('v.account.'+m+'City','');
        c.set('v.account.'+m+'Street','');
        c.set('v.account.'+m+'PostalCode','');        
        h.clearWarnings(c,e,h,m);        
        h.clearContextLabelWarnings(c,e,h,m);
        h.setCities(c,e,h,m);
        h.updateAddress(c,e,h,m);        
    },
    
    //Only used by shipping at the moment
    setCountry : function (c,e,h) {
        c.set('v.account.ShippingCity','');
        c.set('v.account.ShippingStreet','');
        c.set('v.account.ShippingPostalCode','');
        //clear warnings
        h.clearWarnings(c,e,h,'Shipping');
        h.clearContextLabelWarnings(c,e,h,'Shipping');
        h.updateAddress(c,e,h, 'Shipping');
        h.setCountry(c,e,h);

    },

})