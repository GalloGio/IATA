public with sharing class ams2gdp_TriggerHelper 
{
	public static void crossDeleteAgencyOwners(List<AMS_Account_Role__c> roles)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Account_Role__c r : roles)
			keys.add(r.Id + 'GDP');

		List<Agency_Owner__c> agency_owners = [SELECT Id FROM Agency_Owner__c WHERE AMS_GDP_Key__c IN :keys];
		if(agency_owners.size() > 0) delete agency_owners;
	}

	public static void crossDeleteAdjacentAirports(List<AMS_Agency_Airport__c> airports)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Agency_Airport__c a : airports)
			keys.add(a.Id + 'GDP');

		List<Adjacent_Airport__c> adjacent_airports = [SELECT Id FROM Adjacent_Airport__c WHERE AMS_GDP_Key__c IN :keys];
		if(adjacent_airports.size() > 0) delete adjacent_airports;
	}

	public static void crossDeleteGSATerritory(List<AMS_Territory__c> territories)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Territory__c t : territories)
			keys.add(t.Id + 'GDP');

		List<GSA_Territory__c> gsa_territories = [SELECT Id FROM GSA_Territory__c WHERE AMS_GDP_Key__c IN :keys];
		if(gsa_territories.size() > 0) delete gsa_territories;
	}

	public static void crossDeleteAccountItems(List<Account> accounts)
	{	
		Set<String> product_keys = new Set<String>(); 
		Set<String> gds_keys = new Set<String>(); 
		Set<String> category_keys = new Set<String>(); 
		Set<String> agency_profile_keys = new Set<String>(); 

		for(Account a : accounts)
		{
			product_keys.add(a.Id+'GDP');
			agency_profile_keys.add(a.Id+'GDP');

			if(String.isNotBlank(a.GDS__c))
			{
				for(String code : a.GDS__c.split(';'))
				{
					gds_keys.add(a.Id + '-' + code + 'GDP');
				}
			}

			if(String.isNotBlank(a.Location_Category__c))
			{
				for(String code : a.Location_Category__c.split(';'))
				{
					category_keys.add(a.Id + '-' + code + 'GDP');
				}
			}
		}

		List<GDS__c> gds = [SELECT id FROM GDS__c WHERE AMS_GDP_Key__c IN :gds_keys];
		if(gds.size() > 0) delete gds; 

		List<Account_Category__c>  account_categories = [SELECT id FROM Account_Category__c WHERE AMS_GDP_Key__c IN :category_keys];
		if(account_categories.size() > 0) delete account_categories;

		List<GDP_Products_Account_View__c> gdp_products = [SELECT id FROM GDP_Products_Account_View__c WHERE AMS_GDP_Key__c IN :product_keys];
		if(gdp_products.size() > 0) delete gdp_products;
	}

	public static void crossDeleteAssocAffiliations(List<AMS_Agency_Affiliation__c> agencies)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Agency_Affiliation__c a : agencies)
			keys.add(a.Id + 'GDP');

		List<Assoc_Affiliation_Membership__c> assoc_Affiliations = [SELECT Id FROM Assoc_Affiliation_Membership__c WHERE AMS_GDP_Key__c IN :keys];
		if(assoc_Affiliations.size() > 0) delete assoc_Affiliations;
	}

	public static void crossDeleteAccreditations(List<AMS_Inspection__c> inspections)
	{
		Set<String> keys = new Set<String>();
		for(AMS_Inspection__c i : inspections)
			keys.add(i.Id+'GDP');

		List<Accreditation__c> accreditations = [SELECT Id FROM Accreditation__c WHERE AMS_GDP_Key__c IN :keys];
		if(accreditations.size() > 0) delete accreditations;
	}

	public static void crossDeleteGDPAddressAndPhones(List<AMS_Address__c> addresses)
	{
		Set<String> address_keys = new Set<String>();
		Set<String> phone_keys = new Set<String>();

		for(AMS_Address__c a:addresses)
		{
			address_keys.add(a.Id+'GDP');
			phone_keys.add(a.Id+'-P1GDP');
			phone_keys.add(a.Id+'-P2GDP');
			phone_keys.add(a.Id+'-FXGDP');
		}

		List<GDP_Address__c> gdp_addresses = [SELECT Id FROM GDP_Address__c WHERE AMS_GDP_Key__c IN :address_keys];
		if(gdp_addresses.size() > 0) delete gdp_addresses;

		List<GDP_Phone__c> gdp_phones = [SELECT id FROM GDP_Phone__c WHERE AMS_GDP_Key__c IN :phone_keys];
		if(gdp_phones.size() > 0) delete gdp_phones;
	}
}