public class ams2gdp_Selector
{
	public static Map<String, String> getCountryNameById(Set<String> countryIds)
	{
		Map<String, String> result = new Map<String, String>();
		if(countryIds.size() > 0)
		{
			for(IATA_ISO_Country__c isoCountry : [SELECT Id, Name FROM IATA_ISO_Country__c WHERE Id IN :countryIds])
				result.put(isoCountry.Id, isoCountry.Name);

		}
		return result;
	}

	public static Map<String, String> getCountryIdByName(Set<String> countryNames)
	{
		Map<String, String> result = new Map<String, String>();
		if(countryNames.size() > 0)
		{
			for(IATA_ISO_Country__c isoCountry : [SELECT Id, Name FROM IATA_ISO_Country__c WHERE Name IN :countryNames])
				result.put(isoCountry.Name, isoCountry.Id);

		}
		return result;
	}

	public static Map<String, String> getStateNameById(Set<String> stateIds)
	{
		Map<String, String> result = new Map<String, String>();
		if(stateIds.size() > 0)
		{
			for(IATA_ISO_State__c isoState : [SELECT Id, Name FROM IATA_ISO_State__c WHERE Id IN :stateIds])
				result.put(isoState.Id, isoState.Name);

		}
		return result;
	}

	public static Map<String, String> getStateIdByName(Set<String> stateNames)
	{
		Map<String, String> result = new Map<String, String>();
		if(stateNames.size() > 0)
		{
			for(IATA_ISO_State__c isoState : [SELECT Id, Name FROM IATA_ISO_State__c WHERE Name IN :stateNames])
			       result.put(isoState.Name, isoState.Id);

		}
		return result;
	}

	public static Map<String, String> getGeoDetailsByCountry(Set<String> countryIds)
	{
		Map<String, String> result = new Map<String, String>();

		for(GDP_Geo_Detail__c geo : [SELECT ID, IATA_ISO_Country__c, Sub_Continent__c, System_ID__c FROM GDP_Geo_Detail__c WHERE IATA_ISO_Country__c IN :countryIds])
			result.put(geo.IATA_ISO_Country__c, geo.Id);


		return result;
	}

	/*public static List<String> getAMS_InspectionIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Inspection__c item:[SELECT Id FROM AMS_Inspection__c WHERE Account__c IN:accountIds])
			result.add(item.Id);

		return result;
	}*/

	public static List<String> getAMS_TerritoryIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Territory__c item:[SELECT Id FROM AMS_Territory__c WHERE Appointment__r.Account__c IN:accountIds])
		   result.add(item.Id);


		return result;
	}

	public static List<String> getAMS_AddressIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Address__c item:[SELECT Id FROM AMS_Address__c WHERE Account__c IN:accountIds])
			result.add(item.Id);

		return result;
	}

	public static List<String> getAMS_Agency_AffiliationIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Agency_Affiliation__c item:[SELECT Id FROM AMS_Agency_Affiliation__c WHERE Account__c IN:accountIds])
		    result.add(item.Id);

		return result;
	}

	public static List<String> getAMS_Account_RoleIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Account_Role__c item:[SELECT Id FROM AMS_Account_Role__c WHERE Account__c IN:accountIds])
		    result.add(item.Id);


		return result;
	}

	public static List<String> getAMS_Agency_AirportIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Agency_Airport__c item:[SELECT Id FROM AMS_Agency_Airport__c WHERE Account__c IN:accountIds])
		result.add(item.Id);


		return result;
	}

	public static List<String> getAMS_Agency_ProfileIdsByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(AMS_Agency_Profile__c item:[SELECT Id FROM AMS_Agency_Profile__c WHERE Account__c IN:accountIds])
		result.add(item.Id);

		return result;
	}


	//Ex CA=>1|514;450;819 ... will be an entry for Canada
	public static Map<String, String> getPhoneCodesByCountry()
	{
		Map<String, String> result = new Map<String, String>(); /*, Phone_Area_Codes__c*/
		for(IATA_ISO_Country__c c : [SELECT ISO_Code__c, International_dialing_code_ISD__c	 FROM IATA_ISO_Country__c ORDER BY Name])
		{ result.put(c.ISO_Code__c,c.International_dialing_code_ISD__c/*+':'+c.Phone_Area_Codes__c*/);}

		return result;
	}


	public static Map<String, String> getGDP_Products_Account_View_By_Account(Set<String> accountIds)
	{
		Map<String, String> result = new Map<String, String>();
		if(accountIds !=null && accountIds.size() >0)
		{
			for(GDP_Products_Account_View__c prod : [SELECT Id, AMS_GDP_Key__c FROM GDP_Products_Account_View__c WHERE AMS_GDP_Key__c IN :accountIds])
			result.put(prod.AMS_GDP_Key__c, prod.Id);
		}

		return result;
	}

	public static Map<String, String> getGDP_AddressByAccount(Set<String> accountIds)
	{
		Map<String, String> result = new Map<String, String>();
		for(GDP_Address__c item:[SELECT Id, Related_Account__c FROM GDP_Address__c WHERE Related_Account__c IN:accountIds AND Address_Type__c = 'Location' AND RecordType.Name='GDP'])
		{	result.put(item.Related_Account__c,item.Id);}

		return result;
	}

	public static Map<String, String> getGDP_PhoneByAccount(Set<String> accountIds)
	{
		Map<String, String> result = new Map<String, String>();
		for(GDP_Phone__c item:[SELECT Id, Related_Account__c FROM GDP_Phone__c WHERE Related_Account__c IN:accountIds AND Phone_Type__c='Phone 1' AND RecordType.Name='GDP'])
		{
			result.put(item.Related_Account__c,item.Id);
		}

		return result;
	}

	public static Map<String, String> getAccreditationByAccount(Set<String> accountIds)
	{
		Map<String, String> result = new Map<String, String>();
		for(Accreditation__c item:[SELECT Id, Related_Account__c FROM Accreditation__c WHERE Related_Account__c IN:accountIds AND RecordType.Name='GDP'])
		{
			result.put(item.Related_Account__c,item.Id);
		}

		return result;
	}

	public static Map<String, String> getAppointmentByAccount(Set<String> accountIds)
	{
		Map<String, String> result = new Map<String, String>();
		for(AMS_Inspection__c item:[SELECT Id, Account__c, Airline_Code__c FROM AMS_Inspection__c WHERE Account__c IN : accountIds])
		{
			result.put(item.Account__c,item.Airline_Code__c);
		}

		return result;
	}

	public static List<String> getAMS_Agency_AuthorizationByAccountIds(List<String> accountIds)
	{
		List<String> result = new List<String>();
		for(Agency_Authorization__c item:[SELECT Id, Account__c FROM Agency_Authorization__c WHERE Account__c IN:accountIds AND RecordType.Name='FormOfPayment'])
		{
			result.add(item.Id);
		}

		return result;
	}

	public static AMS_GDP_Batch__c getBatchInfo(String batchName)
	{
		List<AMS_GDP_Batch__c> batches =  [
			SELECT Id, Batch_Name__c, Last_Sync_End_Date__c, Last_Sync_Start_Date__c, Failed_Records__c FROM AMS_GDP_Batch__c WHERE Batch_Name__c = :batchName LIMIT 1
		];
		return (batches.size() >0)? batches[0] : null;
	}

	public static Map<String, GDP_Reference_Table__c> getGDPReferenceTableByCode(Set<String> codes)
	{
		Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();

		for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c FROM GDP_Reference_Table__c WHERE Code__c IN : codes])	result.put(tbl.Code__c, tbl);

		return result;
	}

	public static Map<String, GDP_Reference_Table__c> getGDPReferenceTableByCodeAndTable(Set<String> codes, String table)
	{
		Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();

		for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c, Table__c, Definition__c FROM GDP_Reference_Table__c WHERE Code__c IN : codes AND Table__c = :table])
			result.put(tbl.Code__c, tbl);

		return result;
	}


	// public static Map<String, GDP_Reference_Table__c> getGDPReferenceTablebyDefinitionAndTable(Set<String> definitions, String table)
	// {
	// 	Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();
	//
	// 	for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c, Table__c, Definition__c FROM GDP_Reference_Table__c WHERE Definition__c IN : definitions AND Table__c = :table])
	// 		result.put(tbl.Definition__c, tbl);
	//
	// 	return result;
	// }

	public static Map<String, GDP_Reference_Table__c> getGDPReferenceTablebyDescriptionAndTable(Set<String> names, String table)
	{
		Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();

		for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c, Table__c, Name FROM GDP_Reference_Table__c WHERE Name IN : names AND Table__c = :table])
			result.put(tbl.Name, tbl);

		return result;
	}

	// public static Map<String, GDP_Reference_Table__c> getGDPReferenceTablebyDefinitionAndTable(Set<String> definitions, String table, String sys)
	// {
	// 	Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();
	//
	// 	for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c, Table__c, Definition__c FROM GDP_Reference_Table__c WHERE Definition__c IN : definitions AND Table__c = :table AND System__c = :sys])
	// 		result.put(tbl.Definition__c, tbl);
	//
	// 	return result;
	// }

	public static Map<String, GDP_Reference_Table__c> getGDPReferenceTablebyDescriptionAndTable(Set<String> descriptions, String table, String sys)
	{
		Map<String, GDP_Reference_Table__c> result = new Map<String, GDP_Reference_Table__c>();

		for(GDP_Reference_Table__c tbl : [SELECT Id, Code__c, Table__c, Definition__c FROM GDP_Reference_Table__c WHERE Name IN : descriptions AND Table__c = :table AND System__c = :sys])
			result.put(tbl.Definition__c, tbl);

		return result;
	}


	public static Map<String,GDP_Reference_Table__c> getGDPReferenceTableByCodeandTable1(Set<String> codes)
	{
		Map<String,GDP_Reference_Table__c> result = new Map<String,GDP_Reference_Table__c>();

		for(GDP_Reference_Table__c table : [SELECT Id, Code__c, Table__c FROM GDP_Reference_Table__c WHERE Code__c IN : codes])
			result.put(table.Table__c+table.Code__c, table);

			return result;
	}

	public static Map<String, GDP_Agency_Profile_Specialization__c> getGDPbyAccount(Set<Id> accountsSet)
	{

		Map<String, GDP_Agency_Profile_Specialization__c> result= new Map<String, GDP_Agency_Profile_Specialization__c> ();

		for(GDP_Agency_Profile_Specialization__c gdprecord: [SELECT AMS_GDP_Key__c, Related_Account__c FROM GDP_Agency_Profile_Specialization__c WHERE Related_Account__c IN: accountsSet])
			result.put(gdprecord.Related_Account__c,gdprecord);


		return result;
	}
}
