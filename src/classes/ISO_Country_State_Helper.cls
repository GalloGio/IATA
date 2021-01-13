/****************************************************************************************************
    Created by CGI, Thai 2015-10-20
        Methods returning country-state structure
****************************************************************************************************/
public class ISO_Country_State_Helper {
	/****************************************************************************************************
	    Created by CGI, Thai 2015-10-20
	        Return list of all ISO countries and states
	****************************************************************************************************/
	public static List<ISO_Country_State_DTO> getCountry_State() {
		List<ISO_Country_State_DTO> listCountry = new List<ISO_Country_State_DTO>();
		ISO_Country_State_DTO oneCountry;
		
		for (IATA_ISO_Country__c country : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){

			if(country.ISO_Code__c != null && country.Name != 'All Countries'){
				oneCountry = new ISO_Country_State_DTO(country.Id, country.ISO_Code__c, country.Name);

				//*** add only states having name to country structure
				for (IATA_ISO_State__c state : country.IATA_ISO_States__r) {

					if(state.ISO_Code__c != null && state.IEC_Valid_SAP__c == true){
						oneCountry.StateId.add(state.Id);
						oneCountry.StateCode.add(state.ISO_Code__c);
						oneCountry.StateName.add(state.Name);
					}
				}
				listCountry.add(oneCountry);
			}
		}
		
		return listCountry;
	} 
	//*** end of "getCountry_State"
	
	/****************************************************************************************************
	    Created by CGI, Thai 2015-10-30
	        Return map of country name and code
	****************************************************************************************************/
	public static Map<String, String> getCountryCodeFromName(List<String> listCountryName) {
		Map<String, String> mapName_Code = new Map<String, String>();
		
		//*** ensure all input countries is in returning map
		for (String s : listCountryName)
			mapName_Code.put(s, null);
	
		//*** get country codes
		Set<String> countryList = new Set<String>();
		countryList.addAll(listCountryName);
		for (IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountryByCountriesName(countryList))
			mapName_Code.put(country.Name, country.ISO_Code__c);
		
		return mapName_Code;
	} //*** end of "getCountryCodeFromName"
	
	/****************************************************************************************************
	    Created by CGI, Thai 2015-10-30
	        Return map of country name and code
	****************************************************************************************************/
	public static Map<String, String> getStateCodeFromName(Map<String, String> mapStateName_CountryCode) {
		Map<String, String> mapName_Code = new Map<String, String>();
		
		//*** ensure all input states is in returning map
		for (String s : mapStateName_CountryCode.keySet())
			mapName_Code.put(s, null);
	
		//*** get state codes
		for (IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStateByStateName(mapStateName_CountryCode.keySet())){
			if (state.ISO_Code__c != null && state.IEC_Valid_SAP__c == true && 
				state.ISO_Code__c.startsWith('' + mapStateName_CountryCode.get(state.Name) + '-')){
					mapName_Code.put(state.Name, state.ISO_Code__c);
			}
		}
		
		return mapName_Code;
	} //*** end of "getCountryCodeFromName"
	
	// Get a list of SelectOption containing all ISO Countries
	public static List<SelectOption> getPicklistISOCountry(List<ISO_Country_State_DTO> lstCountryState)
	{
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select a Country-'));
        // Loop over existing Country/State DTO to populate the Country picklist
        if (lstCountryState != null && !lstCountryState.isEmpty())
        {
            for(ISO_Country_State_DTO country : lstCountryState)
            {
                options.add(new SelectOption(country.CountryId, country.CountryName));
            }
        }
        return options;
    }
    
    // Get a list of SelectOption containing all ISO States based on a specified Country
    public static List<SelectOption> getPicklistISOState(List<ISO_Country_State_DTO> lstCountryState, Id idCountry)
    {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select a State/Province-'));
        // Loop over existing Country/State DTO to populate the State picklist based on the selected Country
        if (idCountry != null && lstCountryState != null && !lstCountryState.isEmpty())
        {
            for(ISO_Country_State_DTO country : lstCountryState)
            {
            	if (country.CountryId == idCountry && !country.StateId.isEmpty())
            	{
                	for (integer i = 0; i < country.StateId.size(); i++)
                	{
                		options.add(new SelectOption(country.StateId[i], country.StateName[i]));
                	}
                	// Break out of the loop, we already found the selected country
                	break;
            	}
            }
        }
        return options;
    }

    //Get the list of iso country by iso code
	public static List<IATA_ISO_Country__c> getIsoCountryByIsoCode(String isoCode){
		return IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{isoCode});
	}
	//Get the list of iso country by Id
	public static List<IATA_ISO_Country__c> getIsoCountryById(Id isoCountryId){
		return IATAIsoCountryDAO.getIsoCountriesByIds(new Set<String>{isoCountryId});
	}

	//Get the list of iso State by iso code
	public static List<IATA_ISO_State__c> getIsoStateByIsoCode(String isoCode){
		List<IATA_ISO_State__c> isoStateList =	IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{isoCode});
		for(IATA_ISO_State__c state : isoStateList){
			if(state.IEC_Valid_SAP__c == true){
				return isoStateList;
			}
		}
		return new List<IATA_ISO_State__c>();
	} 

	public static List<IATA_ISO_State__c> getIsoStateByIsoCode(String countryCode, String isoCode){
		List<IATA_ISO_State__c> isoStateList =	IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{isoCode});
		for(IATA_ISO_State__c state : isoStateList){
			if(state.IEC_Valid_SAP__c == true && state.IATA_ISO_Country__r.ISO_Code__c == countryCode){
				return isoStateList;
			}
		}
		return new List<IATA_ISO_State__c>();
	} 

	//Get the list of iso State by Id
	public static List<IATA_ISO_State__c> getIsoStateById(Id isoStateId){
		
		List<IATA_ISO_State__c> isoStatesLst = IATAIsoStateDAO.getIsoStatesByIds(new Set<Id>{isoStateId});
		
		if(isoStatesLst != null && isoStatesLst.size() > 0 && isoStatesLst.get(0).IEC_Valid_SAP__c){
			return isoStatesLst;
		}
			
		return new List<IATA_ISO_State__c>();
		
	}

	//get the zipCode required countries
	public static map<Id,IATA_ISO_Country__c> requiredCountriesZipCode(){
		return new map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountriesByZipCoderequired(true));
	}

    /****************************************************************************************************
        Created by CGI, Thai 2016-04-25
            Get list of countries having VAT number
    ****************************************************************************************************/
    public static map<Id,IATA_ISO_Country__c> requiredCountriesVAT(){
        return new map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountriesByVatValidationRequired(true));
    }

	public static Boolean requiredVATNumber(String CountryCode) {
		Boolean required = false;
		List<IATA_ISO_Country__c> lstCountry = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{CountryCode});
			
		if(lstCountry != null && lstCountry.size() > 0){
			required = lstCountry[0].VAT_Validation_Required__c;
		}

		return required;
	}
    
    /****************************************************************************************************
        Created by CGI, Thai 2016-03-17
            Determine if zip code or postal code is required
    ****************************************************************************************************/
    public static Boolean requiredZipCode(String CountryCode) {
        IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{CountryCode}).get(0);
        return country.IEC_Zip_Postal_Code_required__c;
    }


	public static List<SelectOption> getCountriesSelectOption(){

		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',Label.Select_a_Country));

    	for(IATA_ISO_Country__c c : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
    		if(c.Name != 'All Countries')
    			options.add(new SelectOption(c.ISO_Code__c, c.Name));
    	}

    	return options;
	}
	
	public static List<SelectOption> getStatesSelectOption(String countryCode)
	{
		List<SelectOption> options = new List<SelectOption>();
		List<SelectOption> ret = new List<SelectOption>();
        
        List<IATA_ISO_State__c> states = IATAIsoStateDAO.sortIATAIsoStateList(IATAIsoStateDAO.getIsoStates(), 'Name');

    	if(states != null && states.size() > 0){
    		for(IATA_ISO_State__c s : states)
    			if(s.ISO_Code__c != null && s.IEC_Valid_SAP__c == true && s.IATA_ISO_Country__r.ISO_Code__c == countryCode)
    				options.add(new SelectOption(s.ISO_Code__c, s.Name));
    	}

		if(options.size() > 0){
			ret.add(new SelectOption('',Label.Select_a_State_Province));
			ret.addAll(options);
		}

    	return ret;
	}
	
	/**
	*	Enhancements 2017-05-10
	**/
	public static Map<String, Object> getCountriesOptionsMap() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('',Label.Select_a_Country));
		Map<String, Boolean> mapZipCodeApplicable = new Map<String, Boolean>();
		
		for(IATA_ISO_Country__c c : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
    		if(c.ISO_Code__c != null && c.Name != 'All Countries'){
				options.add(new SelectOption(c.ISO_Code__c, c.Name));
				mapZipCodeApplicable.put(c.ISO_Code__c, c.IEC_Zip_Postal_Code_required__c);
			}
		}
		
		return new Map<String, Object> {'options' => options, 'zipCodeApplicable' => mapZipCodeApplicable };
	}	
	
} //*** end of class