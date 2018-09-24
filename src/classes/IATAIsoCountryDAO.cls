/**
 * Data Access Object of IATA_Iso_Country__c 
 */
public class IATAIsoCountryDAO {

	private static Map<ID, IATA_ISO_Country__c> mapIataIsoCountry;

	private static Map<String, IATA_ISO_Country__c> mapIataIsoCountryByName;

	private static Map<String, IATA_ISO_Country__c> mapIataIsoCountrybyIsoCode;

	/**
	 * Method that fetch the Map - mapIataIsoCountry
	 *
	 * @return IATA_ISO_Country Map 
	 */
	private static Map<ID, IATA_ISO_Country__c> fetchMapIataIsoCountry(){

		return new Map<ID, IATA_ISO_Country__c>([SELECT Id, Name, ISO_Code__c, International_dialing_code_ISD__c, Region__c, 
													  	AMS_Default_State__c, AIMS_Area_Name__c, AIMS_Area_ID__c, AMS_Settlement_System__c, 
													  	AMS_Settlement_System_CASS__c, Case_BSP_Country__c, IATA_Regional_Office__c, ISO_Code_Numeric__c,

														//AMS_XML_Generator Fields
														BSP_Country_free_text__c, CASS_Country_free_text__c,SLA_Type__c, Sub_Region__c, 
														Country_Manager__r.Name,

														IATA_COUNTRY_EN__c,
                                                        IATA_Contry_KR__c,
                                                       	IATA_Country_FR__c,
                                                    	IATA_Country_IT__c,
                                                        IATA_Country_JP__c,
                                                        IATA_Country_PT__c,
                                                        IATA_Country_SP__c,
                                                        IATA_Country_ZH__c,
                                                        Tax_1_Label__c, Tax_2_Label__c, Tax_ID_Mandatory__c, VAT_Validation_Required__c,
                                                        IEC_Zip_Postal_Code_required__c,
                                                        Acli_Country__c,

                                                        AMS_Pilot_Country__c,
                                                        Travel_Branch_Country__c, 
                                                        Travel_HO_Country__c, 
                                                        Cargo_Branch_Country__c, 
                                                        Cargo_HO_Country__c, 
                                                        Branches_abroad_not_allowed__c,
                                                        Sanctioned_Country__c,
                                                        Profit_Center__c,
                                                        Is_Non_Compliant__c,
                                                        CurrencyIsoCode, Country_Manager__c,
                                                        ISS_Office_Location__c, OSCAR_Enabled__c,
                                                        ANG_Enable_NewGen__c, EU_Country__c,
                                                        Tax_Number_label__c, Tax_number_format__c,
                                                        Tax_number_help_text__c, Hide_Tax_Number_VAT__c,
                                                        EACP_Country__c, CASS_Import__c,
                                                        Disable_non_IATA_Cargo_Agents__c, original_bank_details_not_required__c,
                                                        Local_language_Agency_details_required__c, Prevent_Portal_Trade_Name_Change__c,
                                                        Enable_Notice_of_Change__c, SAAM_enable_non_IATA_Cargo_Agents__c,
                                                        Enable_Minor_Changes_from_Portal__c, AMS_Accreditation_New_Labels__c,
                                                        EBulletin_enabled__c, AMS_Vouchers_Benchmark__c, AMS_Max_Vouchers_Per_Year__c,
                                                        LVA_CountryLanguage__c, CNS_Country__c, 

                                                        (SELECT Id, Name, ISO_Code__c, IEC_Valid_SAP__c
                                                        FROM IATA_ISO_States__r
                                                        ORDER BY Name),

                                                        (SELECT Id, Minimum_DGR_BR__c, Minimum_DGR_HO__c, Location_Class__c, RecordType.Name, 
                                                        		Threshold__c, RecordType.DeveloperName
													   	FROM AMS_Country_Specific_Attributes__r)

											  	FROM IATA_ISO_Country__c ]);
	}


	/**
	 * Method that return the mapIataIsoCountry using as key an ID of IATA_ISO_Country__c
	 * 
	 * @return Map of Iata_Iso_Country 
	 */
	private static Map<ID, IATA_ISO_Country__c> getMapIataIsoCountry() {

		if(IATAIsoCountryDAO.mapIataIsoCountry == null) {
			IATAIsoCountryDAO.mapIataIsoCountry = IATAIsoCountryDAO.fetchMapIataIsoCountry();
		}
		return IATAIsoCountryDAO.mapIataIsoCountry;
	}

	/**
	 * Method that return the mapIataIsoCountry using as key a country name of IATA_ISO_Country__c
	 * 
	 * @return Map of Iata_Iso_Country 
	 */
	private static Map<String, IATA_ISO_Country__c> getMapIataIsoCountryByName(){
		if(IATAIsoCountryDAO.mapIataIsoCountryByName == null) {

			IATAIsoCountryDAO.mapIataIsoCountryByName = new Map<String, IATA_ISO_Country__c>();

			for(IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountries()){
				IATAIsoCountryDAO.mapIataIsoCountryByName.put(country.Name, country);
			}	
		}

		return IATAIsoCountryDAO.mapIataIsoCountryByName;
	}

	/**
	 * Method that return the mapIataIsoCountry using as key an ISO_Code__c of IATA_ISO_Country__c
	 * 
	 * @return Map of Iata_Iso_Country 
	 */
	private static Map<String, IATA_ISO_Country__c> getMapIataIsoCountryByIsoCode(){
		if(IATAIsoCountryDAO.mapIataIsoCountrybyIsoCode == null) {

			IATAIsoCountryDAO.mapIataIsoCountrybyIsoCode = new Map<String, IATA_ISO_Country__c>();

			for(IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountries()){
				IATAIsoCountryDAO.mapIataIsoCountrybyIsoCode.put(country.ISO_Code__c, country);
			}	
		}

		return IATAIsoCountryDAO.mapIataIsoCountrybyIsoCode;
	}


	/**
	 * Method that return IATA_ISO_Country list
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountries(){
		return IATAIsoCountryDAO.getMapIataIsoCountry().values();
	}


	/**
	 * Method that return IATA_ISO_Country list filtered by ids list
	 *
	 * @param List of Ids
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByIds(Set<ID> idList){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(Id isoCountryId : idList){
			if(IATAIsoCountryDAO.getMapIataIsoCountry().containsKey(isoCountryId)){
				isoCountryList.add(IATAIsoCountryDAO.getMapIataIsoCountry().get(isoCountryId));
			}
		}
		return isoCountryList;
	}

	/**
	 * Method that return IATA_ISO_Country list filtered by ids list
	 *
	 * @param List of Ids
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByIds(Set<String> idList){
		return IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id>((List<Id>) new List<String>(idList)));
	}


	/**
	 * Method that return IATA_ISO_Country list filtered by Name
	 *
	 * @param Set of String - Countries
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountryByCountriesName(Set<String> countries){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();
		
		for(String country : countries){
			if(IATAIsoCountryDAO.getMapIataIsoCountryByName().containsKey(country)){
				isoCountryList.add(IATAIsoCountryDAO.getMapIataIsoCountryByName().get(country));
			}
		}
		return isoCountryList;
	}


	/**
	 * Method that return IATA_ISO_Country list filtered by ISO_Code__c
	 *
	 * @param Set of Strings - IsoCodes
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountryByIsoCodes(Set<String> isoCodes){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(String isoCode : isoCodes){
			if(IATAIsoCountryDAO.getMapIataIsoCountryByIsoCode().containsKey(isoCode)){
				isoCountryList.add(IATAIsoCountryDAO.getMapIataIsoCountryByIsoCode().get(isoCode));
			}
		}
		return isoCountryList;
	}

	/**
	 * Method that return IATA_ISO_Country list filtered by Region
	 *
	 * @param Set of Strings - Regions
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByRegion(Set<String> regions){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
			if(regions.contains(isoCountry.Region__c)){
				isoCountryList.add(isoCountry);
			}
		}
		return isoCountryList;
	}


	/**
	 * Method that return IATA_ISO_Country list filtered by AIMS_Area_Name__c
	 *
	 * @param Set of Strings - IsoCodes
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByAIMSAreaName(Set<String> aimsAreaNamesList){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();
		
		for(String areaName : aimsAreaNamesList){
			for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
				if(isoCountry.AIMS_Area_Name__c == null) continue;
				if(areaName.containsIgnoreCase(isoCountry.AIMS_Area_Name__c)){
					isoCountryList.add(isoCountry);
					break;
				}
			}
		}
		return isoCountryList;
	}

	/**
	 * Method that return IATA_ISO_Country list filtered by AIMS_Area_Name__c
	 *
	 * @param String - IsoCodes
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByAIMSAreaName(String aimsAreaName){
		return getIsoCountriesByAIMSAreaName(new Set<String>{aimsAreaName});
	}

	/**
	 * Method that return IATA_ISO_Country list filtered by Case_BSP_Country__c
	 *
	 * @param Set of Strings - IsoCodes
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByCaseBSPCountries(Set<String> caseBSPCountries){

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();
		
		for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
			if(caseBSPCountries.contains(isoCountry.Case_BSP_Country__c)){
				isoCountryList.add(isoCountry);
			}
		}
		return isoCountryList;
	}


	/**
	 * Method that return IATA_ISO_Country list filtered by IEC_Zip_Postal_Code_required__c = true 
	 *
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByZipCoderequired(Boolean zipPostalCodeRequired){  

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
			if(isoCountry.IEC_Zip_Postal_Code_required__c == zipPostalCodeRequired){
				isoCountryList.add(isoCountry);
			}
		}
		return isoCountryList;
	}

	/**
	 * Method that return IATA_ISO_Country list filtered by VAT_Validation_Required__c = true 
	 *
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByVatValidationRequired(Boolean vatValidationRequired){  

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
			if(isoCountry.VAT_Validation_Required__c == vatValidationRequired){
				isoCountryList.add(isoCountry);
			}
		}
		return isoCountryList;
	}

	/**
	 * Method that return a list of IATA_ISO_Country list without all
	 * Case_BSP_Country__c != null AND Case_BSP_Country__c != ''
	 * 
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_Country__c> getIsoCountriesByCaseBSPCountryNotNull(){  

		List<IATA_ISO_Country__c> isoCountryList = new List<IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.getIsoCountries()){
			if(isoCountry.Case_BSP_Country__c != null && isoCountry.Case_BSP_Country__c != ''){
				isoCountryList.add(isoCountry);
			}
		}
		return isoCountryList;
	}


	/**
	 * Sort the list of IATA_ISO_Country__c using as field a parameter
	 *
	 * @param List<IATA_ISO_Country__c> isoCountryList
	 * @param String sortedField 
	 * @return List of IATA_ISO_Country__c
	 */
	public static List<IATA_ISO_Country__c> sortIATAIsoCountryList(List<IATA_ISO_Country__c> isoCountryList, String sortedField){

		List<IATA_ISO_Country__c> sortedIsoCountryList = new List<IATA_ISO_Country__c>();
		List<IATAIsoCountryWrapper> sortedIATAIsoCountryWrapper = new List<IATAIsoCountryWrapper>();
		
		for(IATA_ISO_Country__c country : isoCountryList){
			sortedIATAIsoCountryWrapper.add(new IATAIsoCountryWrapper(country, sortedField));
		}

		sortedIATAIsoCountryWrapper.sort();

		for(IATAIsoCountryWrapper c : sortedIATAIsoCountryWrapper){
			sortedIsoCountryList.add(c.country);
		}

		return sortedIsoCountryList;
	}


	/**
	 * Generic class that implements sorted list for 
	 * IATA_ISO_Country__c object
	 */ 
	public class IATAIsoCountryWrapper implements Comparable {

	    public IATA_ISO_Country__c country;
	    public String field;
	    
	    // Constructor 
	    public IATAIsoCountryWrapper(IATA_ISO_Country__c c, String sortedField) {
	        this.country = c;
	        this.field = sortedField;
	    }
	    
	    // Compare opportunities based on the opportunity amount.
	    public Integer compareTo(Object compareTo) {
	        // Cast argument to IATAIsoCountryWrapper
	        IATAIsoCountryWrapper compareToContry = (IATAIsoCountryWrapper)compareTo;
	        
	        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if ((String)country.get(field) > (String)compareToContry.country.get(field)) {
	            // Set return value to a positive value.
	            returnValue = 1;
	        } else if ((String)country.get(field) < (String)compareToContry.country.get(field)) {
	            // Set return value to a negative value.
	            returnValue = -1;
	        }
	        
	        return returnValue;       
	    }
	}

	/**
	 * Only used to refresh maps IataIsoCountry.
	 * Just for testing
	 */
	@TestVisible
	private static void resetMapIataIsoCountry(){
		IATAIsoCountryDAO.mapIataIsoCountry = null ;
		IATAIsoCountryDAO.mapIataIsoCountryByName = null; 
		IATAIsoCountryDAO.mapIataIsoCountrybyIsoCode = null;
	}
}