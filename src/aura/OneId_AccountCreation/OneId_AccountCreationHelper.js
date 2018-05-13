({
    setCategory : function (c) {
        var sector = c.get("v.account.Sector__c");
        var category = c.get("v.account.Category__c");

        var catoptions = [];
        if(c.get("v.changeCategory")){
            if(sector == 'Airline'){
                catoptions = [
                    { value : "Cargo Only" , label :"Cargo Only", selected : "true"},
                    { value : "General Aviation" , label :"General Aviation"},
                    { value : "Governmental Aviation" , label :"Governmental Aviation"},
                    { value : "Military" , label :"Military"},
                    { value : "Other" , label :"Other"},
                    { value : "Passenger and Cargo" , label :"Passenger and Cargo"},
                    { value : "Passenger Only" , label :"Passenger Only"}
                ];
            }

            if(sector == 'Accommodation'){
                catoptions = [
                    { value : "Apartment & Villa Rental" , label :"Apartment & Villa Rental"},
                    { value : "Hotel" , label :"Hotel"},
                    { value : "Other" , label :"Other"},
                    { value : "Resort" , label :"Resort"},
                ];
            }

            if(sector == 'Airline Supplier'){
                catoptions = [
                    { value : "Caterer" , label :"Caterer"},
                    { value : "Consultancy Firm" , label :"Consultancy Firm"},
                    { value : "Fuel Supplier" , label :"Fuel Supplier"},
                    { value : "Global Distribution System" , label :"Global Distribution System"},
                    { value : "Ground Handler" , label :"Ground Handler"},
                    { value : "Maintenance, Repair, Overhaul" , label :"Maintenance, Repair, Overhaul"},
                    { value : "Other" , label :"Other"},
                    { value : "Processor" , label :"Processor"},
                    { value : "Security" , label :"Security"},
                    { value : "System Solutions Provider" , label :"System Solutions Provider"}
                ];
            }

            if(sector == 'Association'){
                catoptions = [
                    { value : "Cargo Agency Association" , label :"Cargo Agency Association"},
                    { value : "Non Governmental Organization" , label :"Non Governmental Organization"},
                    { value : "Other" , label :"Other"},
                    { value : "Other Private Sector Association" , label :"Other Private Sector Association"},
                    { value : "Travel Agency Association" , label :"Travel Agency Association"}
                ];
            }

            if(sector == 'Cargo Agent'){
                catoptions = [
                    { value : "CASS Associate" , label :"CASS Associate"},
                    { value : "Courier" , label :"Courier"},
                    { value : "GSSA Cargo" , label :"GSSA Cargo"},
                    { value : "Handling Agent" , label :"Handling Agent"},
                    { value : "IATA Cargo Agent" , label :"IATA Cargo Agent"},
                    { value : "Import Agent" , label :"Import Agent"},
                    { value : "Non-IATA Cargo Agent" , label :"Non-IATA Cargo Agent"},
                    { value : "Non-IATA Travel Agent" , label :"Non-IATA Travel Agent"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Education'){
                catoptions = [
                    { value : "Academic/Research Body" , label :"Academic/Research Body"},
                    { value : "Other" , label :"Other"},
                    { value : "Training Centre" , label :"Training Centre"}
                ];
            }

            if(sector == 'Equipment Manufacturer'){
                catoptions = [
                    { value : "Aircraft Manufacturer" , label :"Aircraft Manufacturer"},
                    { value : "Engine Manufacturer" , label :"Engine Manufacturer"},
                    { value : "Large Component OEM" , label :"Large Component OEM"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Financial Institution'){
                catoptions = [
                    { value : "Airline Global Card Acquirer" , label :"Airline Global Card Acquirer"},
                    { value : "Banking Service" , label :"Banking Service"},
                    { value : "Card Brand" , label :"Card Brand"},
                    { value : "Lessor" , label :"Lessor"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'General Sales Agent'){
                catoptions = [
                    { value : "GSA General Sales Agent" , label :"GSA General Sales Agent"},
                    { value : "GSSA Cargo" , label :"GSSA Cargo"},
                    { value : "IBCS consolidator" , label :"IBCS consolidator"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Governmental Institution'){
                catoptions = [
                    { value : "Civil Aviation Authority" , label :"aaaa"},
                    { value : "Individual Government" , label :"Individual Government"},
                    { value : "Inter-Governmental Body" , label :"Inter-Governmental Body"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Holding Company'){
                catoptions = [
                    { value : "Agency Holding Company" , label :"Agency Holding Company"},
                    { value : "Airline Holding Company" , label :"Airline Holding Company"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'IATA'){
                catoptions = [
                    { value : "IATA Cargo Agent" , label :"IATA Cargo Agent"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Infrastructure Partner'){
                catoptions = [
                    { value : "Airport Authority" , label :"Airport Authority"},
                    { value : "Airport Concessionaire" , label :"Airport Concessionaire"},
                    { value : "Airport operator" , label :"Airport operator"},
                    { value : "ANSP" , label :"ANSP"},
                    { value : "Other" , label :"Other"}
                ];
            }

            if(sector == 'Internal Use'){
                catoptions = [
                    { value : "Vendor" , label :"Vendor"}
                ];
            }

            if(sector == 'Media'){
                catoptions = [
                    { value : "Other" , label :"Other"},
                    { value : "Publishing" , label :"Publishing"}
                ];
            }

            if(sector == 'Non.Airline Transportation'){
                catoptions = [
                    { value : "Bus Line" , label :"Bus Line"},
                    { value : "Car Rental" , label :"Car Rental"},
                    { value : "Cruise Line" , label :"Cruise Line"},
                    { value : "Other" , label :"Other"},
                    { value : "Railway Line" , label :"Railway Line"}
                ];
            }

            if(sector == 'Recreational'){
                catoptions = [
                    { value : "Casino" , label :"Casino"},
                    { value : "Landmark" , label :"Landmark"},
                    { value : "Museum" , label :"Museum"},
                    { value : "Other" , label :"Other"},
                    { value : "Park" , label :"Park"}
                ];
            }

            if(sector == 'Travel Agent'){
                catoptions = [
                    { value : "Airline Point of Sale" , label :"Airline Point of Sale"},
                    { value : "CASS Associate" , label :"CASS Associate"},
                    { value : "Courier" , label :"Courier"},
                    { value : "Domestic Agent" , label :"Domestic Agent"},
                    { value : "ERSP Agent" , label :"ERSP Agent"},
                    { value : "GSA General Sales Agent" , label :"GSA General Sales Agent"},
                    { value : "GSSA Cargo" , label :"GSSA Cargo"},
                    { value : "Handling Agent" , label :"Handling Agent"},
                    { value : "IATA Cargo Agent" , label :"IATA Cargo Agent"},
                    { value : "IATA Passenger Sales Agent" , label :"IATA Passenger Sales Agent"},
                    { value : "IBCS consolidator" , label :"IBCS consolidator"},
                    { value : "Import Agent" , label :"Import Agent"},
                    { value : "MSO Member Sales Office" , label :"MSO Member Sales Office"},
                    { value : "Non-IATA Cargo Agent" , label :"Non-IATA Cargo Agent"},
                    { value : "Non-IATA Passenger Agent" , label :"Non-IATA Passenger Agent"},
                    { value : "Non-IATA Travel Agent" , label :"Non-IATA Travel Agent"},
                    { value : "Other" , label :"Other"},
                    { value : "TIDS Agent" , label :"TIDS Agent"},
                    { value : "Tour Operator" , label :"Tour Operator"}
                ];
            }

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
})