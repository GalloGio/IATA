/*
* @author Next-Link Smart Facilities
* @Description: CW_LandingSearchBarController
*               AuraEnabled and public methods: getLocationsList(), getCertificationsList(), getCompanyNamesList()
*/
public without sharing class CW_LandingSearchBarController {

	private final static String CITYSTR = 'City';
	private final static String COUNTRYSTR = 'Country';
	private final static String AIRPORTSTR = 'Airport';
	private final static String CERTIFICATIONSTR = 'Certification';
	private final static String COMPANYSTR = 'Company';
	public final static String STATIONSTR = 'Station';
	/*
	* @Description: wrapper Result {String key, Integer value}
	*/
	class Result {
		public String key;
		public RowInfo info;
		public Integer value;

		public Result(String key, RowInfo location) {
			this.key = key;
			this.info = location;
			this.value = location.value;
		}
	}
	/**
	* @author Next-Link Smart Facilities
	* @description Location Info Wrapper to store info of each type of location [Airport, City, Country...]
	*/
	public class RowInfo {
		@AuraEnabled
		public String searchValues{get;set;}
		@AuraEnabled
		public String keyName{get;set;}
		@AuraEnabled
		public Integer value{get;set;}
		@AuraEnabled
		public String code{get;set;}
		@AuraEnabled
		public String description{get;set;}
		@AuraEnabled
		public String type{get;set;} //[Airport, City, Country...]
		@AuraEnabled
		public String uniqueId{get;set;} //loc.keyName + '#' + loc.type in lowerCase
		@AuraEnabled
		public String alias{get;set;}
		@AuraEnabled
		public String stationsIds{get;set;}

		public RowInfo(){}
		public RowInfo(String searchValues, String keyName, Integer value, String code, String description, String type, String uniqueId, String alias, String stationsIds){
			this.searchValues = searchValues;
			this.keyName = keyName;
			this.value = value;
			this.code = code;
			this.description = description;
			this.type = type;
			this.uniqueId = uniqueId;
			this.alias = alias;
			this.stationsIds = stationsIds;
		}

	}
	/*
	* @author Next-Link Smart Facilities
	* @Description: getLocationsList: return a map of <String, RowInfo> and how many times each location is storaged in salesforce
	* @output: String JSON.serialize(Result results)
	*/
	@AuraEnabled(cacheable=true)
	public static String getLocationsList() {
		Map<String, RowInfo> valueMap = new Map<String, RowInfo>();

		/* Initialization of valueMap with IATA_ISO_Country__c values */
		valueMap = fetchCountries(valueMap);
		/* Initialization of valueMap with Airport_Detail__c values */
		valueMap = fetchAirports(valueMap);

		for (ICG_Account_Role_Detail__c accd : [SELECT Id, City_FOR__c, Search_city__c, State_Province_FOR__c,
												Nearest_Airport__r.Airport_Name__c, Nearest_Airport__r.Code__c, 
												Nearest_Airport__r.City__c, Nearest_Airport__r.IATA_ISO_Country__r.Name, Country_FOR__c
												FROM ICG_Account_Role_Detail__c
												WHERE Status__c = 'Approved']) {

			// locCity
			String locCityKey = (accd.City_FOR__c + '#' + CITYSTR).toLowerCase();
			if (valueMap.containsKey(locCityKey)) {
				valueMap.get(locCityKey).value += 1;
				valueMap.get(locCityKey).stationsIds += '#'+accd.Id;
			} else {
				RowInfo locCity = new RowInfo();
				locCity.keyName = accd.City_FOR__c;
				locCity.searchValues = accd.Search_city__c;
				locCity.type = CITYSTR;
				locCity.uniqueId = locCityKey;
				locCity.description = accd.State_Province_FOR__c != null ? accd.State_Province_FOR__c + ', ' : '';
				locCity.description += accd.Country_FOR__c != null ? accd.Country_FOR__c : '';
				locCity.value = 1;
				locCity.stationsIds = accd.Id;
				valueMap.put(locCity.uniqueId, locCity);
			}

			/** Adding nearestAirport.City to the predictive values */
			String locNearestAirCity = (accd.Nearest_Airport__r.City__c + '#' + CITYSTR).toLowerCase();
			if (!locCityKey.equalsIgnoreCase(locNearestAirCity)) {
				if (valueMap.containsKey(locNearestAirCity)) {
					valueMap.get(locNearestAirCity).value += 1;
					valueMap.get(locNearestAirCity).stationsIds += '#'+accd.Id;
				} else {
					RowInfo locNearestAirport = new RowInfo();
					locNearestAirport.keyName = accd.Nearest_Airport__r.City__c;
					locNearestAirport.searchValues = accd.Nearest_Airport__r.City__c;
					locNearestAirport.type = CITYSTR;
					locNearestAirport.uniqueId = locNearestAirCity;
					locNearestAirport.description = accd.State_Province_FOR__c != null ? accd.State_Province_FOR__c + ', ' : '';
					locNearestAirport.description += accd.Country_FOR__c != null ? accd.Country_FOR__c : '';
					locNearestAirport.value = 1;
					locNearestAirport.stationsIds = accd.Id;

					valueMap.put(locNearestAirport.uniqueId, locNearestAirport);
				}
			}

			
			// locCountry
			String locCountryKey = (accd.Country_FOR__c + '#' + COUNTRYSTR).toLowerCase();
			if (valueMap.containsKey(locCountryKey)) {
				valueMap.get(locCountryKey).value += 1;
				valueMap.get(locCountryKey).stationsIds += '#'+accd.Id;				
			} 

			// locAirport
			String locAirportKey = (accd.Nearest_Airport__r.Airport_Name__c + '#' + AIRPORTSTR).toLowerCase();
			if (valueMap.containsKey(locAirportKey)) {
				valueMap.get(locAirportKey).value += 1;
				valueMap.get(locAirportKey).stationsIds += '#'+accd.Id;	
			}
		}

		final List<CW_LandingSearchBarController.Result> results = getResultByMap(valueMap);
		return JSON.serialize(results);
	}

	/*
	* @author Next-Link Smart Facilities
	* @Description: getCertificationsList: return a map of certifications and how many times each certification is storaged in salesforce
	* @output: String JSON.serialize(Result results)
	*/
	@AuraEnabled (cacheable=true)
	public static String getCertificationsList() {
		final Map<String, RowInfo> mapUpdated = new Map<String, RowInfo> ();
		final List<ICG_Certification__c> certDetails = [SELECT name, Certification_Type__c, Alias__c,
															(SELECT id FROM ICG_Capability_Assignment_Groups__r where Is_Expired__c = false AND ICG_Account_Role_Detail__r.isApproved__c = true)
														FROM ICG_Certification__c 
														WHERE Is_Visible__c = true]; //Check if cert is expired to avoid it

		for(ICG_Certification__c cert : certDetails) {
			final RowInfo loc = new RowInfo();
			loc.keyName = cert.name;
			loc.searchValues = cert.name;
			loc.type = CERTIFICATIONSTR;
			loc.value = cert.ICG_Capability_Assignment_Groups__r.size();
			loc.uniqueId = (cert.name).toLowerCase();
			loc.description = '';
			loc.alias = cert.Alias__c;
			mapUpdated.put(loc.uniqueId, loc);
		}

		final List<CW_LandingSearchBarController.Result> results = getResultByMap(mapUpdated);
		return JSON.serialize(results);
	}

	/*
	* @Description: getCompanyNamesList: return a map of companyNames and how many times each companyName is storaged in salesforce
	*									- Update 22/jan/2020:  calling to helper method in without sharing class 
	*									to be able to reach account info as guest user
	*
	* @output: String JSON.serialize(Result results)
	*/
	@AuraEnabled (cacheable = true)
	public static String getCompanyNamesList(Boolean splitByCountry) {
		final Map<String, RowInfo> mapUpdated = CW_ICGContactRoleDetailHelper.helperGetCompanyNamesWithoutSharing(COMPANYSTR, splitByCountry);
		final List<CW_LandingSearchBarController.Result> results = getResultByMap(mapUpdated);
		return JSON.serialize(results);
	}
	/*
	* @author Next-Link Smart Facilities
	* @Description: fetchCountries
						Fetch all the countries storaged in IATA_ISO_Country
	*                   Update the map with some fields of the query
	* @input: Map<String, RowInfo> mapToUpdate
	* @output: Map<String, RowInfo> mapUpdated
	*/
	private static Map<String, RowInfo> fetchCountries(Map<String, RowInfo> mapToUpdate) {
		final Map<String, RowInfo> mapUpdated = mapToUpdate != null ? mapToUpdate : new Map<String, RowInfo>();
		final List<IATA_ISO_Country__c> lstCountries = [ SELECT name  FROM IATA_ISO_Country__c ];

		for(IATA_ISO_Country__c country : lstCountries) {
			RowInfo loc = new RowInfo();
			loc.keyName = country.name;
			loc.searchValues = loc.Keyname;
			loc.type = COUNTRYSTR;
			loc.value = 0;
			loc.uniqueId = (loc.keyName + '#' + loc.type).toLowerCase();
			loc.description = '';
			mapUpdated.put(loc.uniqueId, loc);
		}
		return mapUpdated;
	}

	/*
	* @author Next-Link Smart Facilities
	* @Description: fetchAirports
						Fetch all the airports storaged in Airport_Detail__c
	*                   Update the map with new keys (some fields of the query)
	* @input: Map<String,Integer> mapToUpdate
	* @output: Map<String, Integer> mapUpdated
	*/
	@AuraEnabled
	public static Map<String, RowInfo> fetchAirports(Map<String, RowInfo> mapToUpdate) {
		final Map<String, RowInfo> mapUpdated = mapToUpdate != null ? mapToUpdate : new Map<String, RowInfo>();
		final List<Airport_Detail__c> lstAirports = [ SELECT Airport_Name__c , Code__c, City__c, IATA_ISO_Country__r.Name, 
													Account__r.Business_City__r.Name
													FROM Airport_Detail__c ];

		for(Airport_Detail__c airport : lstAirports) {
			final RowInfo loc = new RowInfo();
			loc.keyName = airport.Airport_Name__c;
			loc.searchValues = airport.Airport_Name__c;
			loc.type = AIRPORTSTR;
			loc.code = airport.Code__c;
			loc.value = 0;
			loc.uniqueId = (loc.keyName + '#' + loc.type).toLowerCase();
			loc.description = ' (' + airport.Code__c + ') ';
			loc.description += airport.City__c != null ? airport.City__c + ', ' : '';
			loc.description += airport.IATA_ISO_Country__r.Name != null ? airport.IATA_ISO_Country__r.Name : '';

			mapUpdated.put(loc.uniqueId, loc);

		}
		return mapUpdated;
	}

	/*
	* @author Next-Link Smart Facilities
	* @Description: getResultByMap: create wrapper results based on the final map to be sent to the client side
	* @input:   Map<String, RowInfo> mapToUse
	* @output:  List<Result> results
	*/
	private static List<CW_LandingSearchBarController.Result> getResultByMap(Map<String, RowInfo> mapToUse) {
		final List<CW_LandingSearchBarController.Result> results = new List<CW_LandingSearchBarController.Result>();

		for(String key: mapToUse.keySet()) {
			results.add(new CW_LandingSearchBarController.Result(key, mapToUse.get(key)));
		}

		return results;
	}

}