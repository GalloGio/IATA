/**************************************************************************************************
 * @ Last Modified By: Bhargavi Rayavarapu
 * @ Last Edited Date : 2016-04-15
 * @ Description: This batch apex when run, calculates the total number of records in different combinations of Location filers
 *  and stores each as a record in EBC_Statistic__c object
 * Currently considered Location filters are:   SUB-CONTINENT, Country, State/Province and CITY
   Total number of combinations that are possible for 1 record with all 4 filters populated are : 15
 * ************************************************************************************************/
global class Batch_LocationCounter implements Database.Batchable<sObject>,Database.Stateful
{
   	global final String Query;
	// this map has the count of the number of agencies using a particular key
   	global Map<String,Integer> LocationMap;
	// this map has the Country of the key inclued (if any)
   	global Map<String,String> KeyCountyMap;
	// this map has the SubContinent of the key inclued (if any)
   	global Map<String,String> KeySubContinentMap;
	// this map has the State/Province of the key inclued (if any)
   	global Map<String,String> KeyStateProvinceMap;
	// this map has the City of the key inclued (if any)
   	global Map<String,String> KeyCityMap;
   	global Batch_LocationCounter()
   	{
		// initial query to get all the Agencies that are accrediated.
   		Query = 'Select Id,Sub_Continent__c,Country_Name__c,State_Province__c,City__c'
				+' from GDP_Products_Account_View__c'
				+' where Agency_Status_Code__c >= 4';
	 	LocationMap = new Map<String,Integer>();
		KeyCountyMap = new Map<String,String>();
		KeySubContinentMap = new Map<String,String>();
		KeyStateProvinceMap = new Map<String,String>();
		KeyCityMap = new Map<String,String>();
   	}

   	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		// execute the query
	  	return Database.getQueryLocator(query);
   	}
   	global void execute( Database.BatchableContext BC, List<GDP_Products_Account_View__c> agencyRecords)
	{
	 	LocationMap = new Map<String,Integer>();
		KeyCountyMap = new Map<String,String>();
		KeySubContinentMap = new Map<String,String>();
		KeyStateProvinceMap = new Map<String,String>();
		KeyCityMap = new Map<String,String>();
		Set<String> keyMap = new Set<String>();
		// parse through the result set and add the counts to the map
		for(GDP_Products_Account_View__c parser : agencyRecords)
		{
			// entering all the possible 15 combinations.
			//we are using a SET so that we do not have duplicates
			Set<String> filterCombinations = new Set<String>();
			//only 1 location filter = 4
			String subContinent = parser.Sub_Continent__c;
			String countryName = parser.Country_Name__c;
			String stateProvince = parser.State_Province__c;
			String cityName = parser.City__c;

			filterCombinations = fillMap(subContinent,countryName,stateProvince,cityName);

			// parse through each item in the set and check if that is present in the map
			for(String filterCombination : filterCombinations)
			{
				integer agencyCounter = 0;

				if(null != LocationMap && LocationMap.containsKey(filterCombination))
				{
					agencyCounter = LocationMap.get(filterCombination);
				}
				keyMap.add(filterCombination);
				LocationMap.put(filterCombination,agencyCounter+1);
			}
	  	}
		 // get the new EBC statistics values processed by the batch
		Map<String,Integer> existingKeyValues = new Map<String,Integer>();
		Map<String,Id> existingIdKeyValues = new Map<String,Id>();
		List<EBC_Statistic__c> otherPossibleLocationFilters = new List<EBC_Statistic__c>();
		String tempQuery = 'Select Id,Key__c,Agency_Counter__c from EBC_Statistic__c where Key__c in: keyMap Limit 10000';
		List<EBC_Statistic__c> newRecords = database.query(tempQuery);
		for(EBC_Statistic__c parser: newRecords)
		{
			existingKeyValues.put(parser.Key__c,Integer.valueOf(parser.Agency_Counter__c));
			existingIdKeyValues.put(parser.Key__c,parser.Id);
		}
		// now insert new records
		for (String keyValue : LocationMap.keySet())
		{
			EBC_Statistic__c newPossibleLocationFilter = new EBC_Statistic__c();
			newPossibleLocationFilter.Key__c = keyValue;
			newPossibleLocationFilter.Agency_Counter__c = LocationMap.get(keyValue);
			if(null != existingIdKeyValues && existingIdKeyValues.containsKey(keyValue))
			{
				newPossibleLocationFilter.Id = existingIdKeyValues.get(keyValue);
				newPossibleLocationFilter.Agency_Counter__c = existingKeyValues.get(keyValue) + LocationMap.get(keyValue);
			}
			newPossibleLocationFilter.Sub_Continent__c = KeySubContinentMap.get(keyValue);
			newPossibleLocationFilter.Country__c = KeyCountyMap.get(keyValue);
			newPossibleLocationFilter.State_Province__c = KeyStateProvinceMap.get(keyValue);
			newPossibleLocationFilter.City__c = KeyCityMap.get(keyValue);
			otherPossibleLocationFilters.add(newPossibleLocationFilter);
		}
		try
		{
			upsert otherPossibleLocationFilters;
		}
		catch(Exception e)
		{
			System.debug(' Exception caused while inserting - '+e.getMessage());
		}

   	}
	global void finish(Database.BatchableContext BC)
	{

   	}
	private Set<String> fillMap(String subContinent,String countryName, String stateProvince, String cityName)
	{
		Set<String> filterCombinations = new Set<String>();

		if(String.isNotBlank(subContinent))
		{
			filterCombinations.add('SC-'+subContinent);
			KeySubContinentMap.put('SC-'+subContinent,subContinent);
		}
		if(String.isNotBlank(countryName))
		{
			filterCombinations.add('Co-'+countryName);
			KeyCountyMap.put('Co-'+countryName,countryName);
		}
		if(String.isNotBlank(stateProvince))
		{
			filterCombinations.add('S-'+stateProvince);
			KeyStateProvinceMap.put('S-'+stateProvince,stateProvince);
		}
		if(String.isNotBlank(cityName))
		{
			filterCombinations.add('C-'+cityName);
			KeyCityMap.put('C-'+cityName,cityName);
		}

		//two location filters = 6
		String subContinent_CountryName = 'SC-'+subContinent+'Co-'+countryName;
		String subContinent_StateProvince = 'SC-'+subContinent+'S-'+stateProvince;
		String subContinent_CityName = 'SC-'+subContinent+'C-'+cityName;
		String countryName_StateProvince = 'Co-'+countryName+'S-'+stateProvince;
		String countryName_CityName = 'Co-'+countryName+'C-'+cityName;
		String stateProvince_CityName = 'S-'+stateProvince+'C-'+cityName;

		//three location filters = 4
		String subContinent_CountryName_StateProvince = 'SC-'+subContinent+'Co-'+countryName+'S-'+stateProvince;
		String subContinent_CountryName_CityName = 'SC-'+subContinent+'Co-'+countryName+'C-'+cityName;
		String subContinent_StateProvince_CityName = 'SC-'+subContinent+'S-'+stateProvince+'C-'+cityName;
		String CountryName_StateProvince_CityName = 'Co-'+countryName+'S-'+stateProvince+'C-'+cityName;

		//all the location filters = 1
		String subContinent_CountryName_StateProvince_CityName = 'SC-'+subContinent+'Co-'+countryName+'S-'+stateProvince+'C-'+cityName;

		if(String.isNotBlank(subContinent) && String.isNotBlank(countryName))
		{
			filterCombinations.add(subContinent_CountryName);
			KeySubContinentMap.put(subContinent_CountryName,subContinent);
			KeyCountyMap.put(subContinent_CountryName,countryName);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(stateProvince))
		{
			filterCombinations.add(subContinent_StateProvince);
			KeySubContinentMap.put(subContinent_StateProvince,subContinent);
			KeyStateProvinceMap.put(subContinent_StateProvince,stateProvince);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(cityName))
		{
			filterCombinations.add(subContinent_CityName);
			KeySubContinentMap.put(subContinent_CityName,subContinent);
			KeyCityMap.put(subContinent_CityName,cityName);
		}
		if(String.isNotBlank(countryName) && String.isNotBlank(stateProvince))
		{
			filterCombinations.add(countryName_StateProvince);
			KeyCountyMap.put(countryName_StateProvince,countryName);
			KeyStateProvinceMap.put(countryName_StateProvince,stateProvince);
		}
		if(String.isNotBlank(countryName) && String.isNotBlank(cityName))
		{
			filterCombinations.add(countryName_CityName);
			KeyCountyMap.put(countryName_CityName,countryName);
			KeyCityMap.put(countryName_CityName,cityName);
		}
		if(String.isNotBlank(stateProvince)&& String.isNotBlank(cityName))
		{
			filterCombinations.add(stateProvince_CityName);
			KeyStateProvinceMap.put(stateProvince_CityName,stateProvince);
			KeyCityMap.put(stateProvince_CityName,cityName);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(countryName) && String.isNotBlank(stateProvince))
		{
			filterCombinations.add(subContinent_CountryName_StateProvince);
			KeySubContinentMap.put(subContinent_CountryName_StateProvince,subContinent);
			KeyCountyMap.put(subContinent_CountryName_StateProvince,countryName);
			KeyStateProvinceMap.put(subContinent_CountryName_StateProvince,stateProvince);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(countryName) && String.isNotBlank(cityName))
		{
			filterCombinations.add(subContinent_CountryName_CityName);
			KeySubContinentMap.put(subContinent_CountryName_CityName,subContinent);
			KeyCountyMap.put(subContinent_CountryName_CityName,countryName);
			KeyCityMap.put(subContinent_CountryName_CityName,cityName);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(stateProvince) && String.isNotBlank(cityName))
		{
			filterCombinations.add(subContinent_StateProvince_CityName);
			KeySubContinentMap.put(subContinent_StateProvince_CityName,subContinent);
			KeyStateProvinceMap.put(subContinent_StateProvince_CityName,stateProvince);
			KeyCityMap.put(subContinent_StateProvince_CityName,cityName);
		}
		if(String.isNotBlank(countryName) && String.isNotBlank(stateProvince) && String.isNotBlank(cityName))
		{
			filterCombinations.add(CountryName_StateProvince_CityName);
			KeyCountyMap.put(CountryName_StateProvince_CityName,countryName);
			KeyStateProvinceMap.put(CountryName_StateProvince_CityName,stateProvince);
			KeyCityMap.put(CountryName_StateProvince_CityName,cityName);
		}
		if(String.isNotBlank(subContinent) && String.isNotBlank(countryName) && String.isNotBlank(stateProvince) && String.isNotBlank(cityName))
		{
			filterCombinations.add(subContinent_CountryName_StateProvince_CityName);
			KeySubContinentMap.put(subContinent_CountryName_StateProvince_CityName,subContinent);
			KeyCountyMap.put(subContinent_CountryName_StateProvince_CityName,countryName);
			KeyStateProvinceMap.put(subContinent_CountryName_StateProvince_CityName,stateProvince);
			KeyCityMap.put(subContinent_CountryName_StateProvince_CityName,cityName);
		}
		return filterCombinations;
	}
}
