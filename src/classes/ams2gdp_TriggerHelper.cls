public with sharing class ams2gdp_TriggerHelper 
{
	public static void crossDeleteAgencyOwners(List<AMS_Account_Role__c> roles)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Account_Role__c r : roles)	keys.add(r.Id + 'GDP');

		List<Agency_Owner__c> agency_owners = [SELECT Id FROM Agency_Owner__c WHERE AMS_GDP_Key__c IN :keys];
		if(agency_owners.size() > 0) delete agency_owners;
	}

	public static void crossDeleteAdjacentAirports(List<AMS_Agency_Airport__c> airports)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Agency_Airport__c a : airports)	keys.add(a.Id + 'GDP');

		List<Adjacent_Airport__c> adjacent_airports = [SELECT Id FROM Adjacent_Airport__c WHERE AMS_GDP_Key__c IN :keys];
		if(adjacent_airports.size() > 0) delete adjacent_airports;
	}

	public static void crossDeleteGSATerritory(List<AMS_Territory__c> territories)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Territory__c t : territories)	keys.add(t.Id + 'GDP');

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
			product_keys.add(a.Id);
			agency_profile_keys.add(a.Id+'GDP');

			if(String.isNotBlank(a.GDS__c))
			{
				for(String code : a.GDS__c.split(';'))	gds_keys.add(a.Id + '-' + code + 'GDP');
			}

			if(String.isNotBlank(a.Location_Category__c))
			{
				for(String code : a.Location_Category__c.split(';'))  category_keys.add(a.Id + '-' + code + 'GDP');
				
			}}

		List<GDS__c> gds = [SELECT id FROM GDS__c WHERE AMS_GDP_Key__c IN :gds_keys];
		if(gds.size() > 0) delete gds; 

		List<Account_Category__c>  account_categories = [SELECT id FROM Account_Category__c WHERE AMS_GDP_Key__c IN :category_keys];
		if(account_categories.size() > 0) delete account_categories;

		List<GDP_Products_Account_View__c> gdp_products = [SELECT id FROM GDP_Products_Account_View__c WHERE AMS_GDP_Key__c IN :product_keys];
		if(gdp_products.size() > 0) delete gdp_products;
		
	}

	public static void crossDeleteAccountItemsBefore(List<Account> accounts)
	{	
		Set<String> product_keys = new Set<String>(); 
		Set<String> gds_keys = new Set<String>(); 
		Set<String> category_keys = new Set<String>(); 
		Set<String> agency_profile_keys = new Set<String>(); 

		for(Account a : accounts)
		{
			product_keys.add(a.Id);
					
		}

		List<Assoc_Affiliation_Membership__c> assoc_Affiliations = [SELECT id FROM Assoc_Affiliation_Membership__c WHERE Related_Account__c IN :product_keys];
		if(assoc_Affiliations.size() > 0) delete assoc_Affiliations;

		List<GDP_Agency_Profile_Specialization__c> specializations = [SELECT id FROM GDP_Agency_Profile_Specialization__c WHERE Related_Account__c IN :product_keys];
		if(specializations.size() > 0) delete specializations;

		List<Adjacent_Airport__c> airports = [SELECT id FROM Adjacent_Airport__c WHERE AMS_GDP_Key__c IN :product_keys];
		if(airports.size() > 0) delete airports;

		List<GDP_Address__c> gdp_address = [SELECT id FROM GDP_Address__c WHERE Related_Account__r.Id IN :product_keys];
		if(gdp_address.size() > 0) delete gdp_address;

		List<GDP_Phone__c> gdp_phones = [SELECT id FROM GDP_Phone__c WHERE Related_Account__r.Id IN :product_keys];
		if(gdp_phones.size() > 0) delete gdp_phones;

		List<Account_Category__c> categories = [SELECT id FROM Account_Category__c WHERE Related_Account__c IN :product_keys];
		if(categories.size() > 0) delete categories;

		List<Agency_Owner__c> owners = [SELECT id FROM Agency_Owner__c WHERE Related_Account__c IN :product_keys];
		if(owners.size() > 0) delete owners;

		List<GSA_Territory__c> territories = [SELECT id FROM GSA_Territory__c WHERE Related_Account__c IN :product_keys];
		if(territories.size() > 0) delete territories;

		List<Accreditation__c> accreditations = [SELECT id,Related_Account__r.Id FROM Accreditation__c WHERE Related_Account__r.Id IN :product_keys];
		if(accreditations.size() > 0) delete accreditations;


	}

	public static void crossDeleteAssocAffiliations(List<AMS_Agency_Affiliation__c> agencies)
	{
		Set<String> keys = new Set<String>(); 
		for(AMS_Agency_Affiliation__c a : agencies) keys.add(a.Id + 'GDP');

		List<Assoc_Affiliation_Membership__c> assoc_Affiliations = [SELECT Id FROM Assoc_Affiliation_Membership__c WHERE AMS_GDP_Key__c IN :keys];
		if(assoc_Affiliations.size() > 0) delete assoc_Affiliations;
	}

	public static void crossDeleteAccreditations(List<Account> accounts)
	{
		Set<String> keys = new Set<String>();
		for(Account i : accounts)	keys.add(i.Id+'GDP');

		List<Accreditation__c> accreditations = [SELECT Id FROM Accreditation__c WHERE AMS_GDP_Key__c IN :keys];
		if(accreditations.size() > 0) delete accreditations;
	}

	public static void updateAccountAddresses(Map<Id,AMS_Address__c> beforeAddresses, Map<Id,AMS_Address__c> afterAddresses)
	{
		List<Account> accountsToUpdateBillingAddress = new List<Account>(); 
		List<Account> accountsToUpdateShippingAddress = new List<Account>(); 
		List<Account> accountsToClearBillingAddress = new List<Account>(); 
		List<Account> accountsToClearShippingAddress = new List<Account>(); 

		Map<String,AMS_Address__c> accountIdToUpdateBillingAddress_Address = new Map<String,AMS_Address__c>();
		Map<String,AMS_Address__c> accountIdToUpdateShippingAddress_Address = new Map<String,AMS_Address__c>();
		
		Set<String> accountIdsToClearBillingAddress = new Set<String>();
		Set<String> accountIdsToClearShippingAddress = new Set<String>();
//Comme t2 
		Set<String> countryIds = new Set<String>(); 
		Set<String> stateIds = new Set<String>();

		for(Id adrId :afterAddresses.keySet())
		{
			AMS_Address__c newAddress = afterAddresses.get(adrId);
			AMS_Address__c oldAddress = (beforeAddresses != null) ? beforeAddresses.get(adrId) :null;

			if(newAddress.Country__c != null) countryIds.add(newAddress.Country__c);
			if(newAddress.State__c != null) stateIds.add(newAddress.State__c);

			if(newAddress.Address_Type__c!= null && newAddress.Address_Type__c.contains('Primary'))
			{
				accountIdToUpdateBillingAddress_Address.put(newAddress.Account__c, newAddress);

				//Account change ? clear oldAccount Address
				if(oldAddress!=null && oldAddress.Account__c != newAddress.Account__c)  accountIdsToClearBillingAddress.add(oldAddress.Account__c);
			}
			else if(newAddress.Address_Type__c!= null && newAddress.Address_Type__c.contains('Mailing'))
			{
				accountIdToUpdateShippingAddress_Address.put(newAddress.Account__c, newAddress);

				//Account change ? clear oldAccount Address
				if(oldAddress!=null && oldAddress.Account__c != newAddress.Account__c)  accountIdsToClearShippingAddress.add(oldAddress.Account__c);
			}

			if(oldAddress != null && oldAddress.Address_Type__c != null && newAddress != null && newAddress.Address_Type__c != null)
			{
				//If old address was Billing and new on change then Clear Account Billing Address
				if(oldAddress.Address_Type__c.contains('Primary') && !newAddress.Address_Type__c.contains('Primary')) 
					accountIdsToClearBillingAddress.add(oldAddress.Account__c);

				//If old address was Shpping and new on change then Clear Account Shipping Address
				if(oldAddress.Address_Type__c.contains('Mailing') && !newAddress.Address_Type__c.contains('Mailing')) 
					accountIdsToClearShippingAddress.add(oldAddress.Account__c);
			}
		}

		//Build Country & State Map 
		Map<String, String> countryNameById = ams2gdp_Selector.getCountryNameById(countryIds); 
		Map<String, String> stateNameById = ams2gdp_Selector.getStateNameById(stateIds);

		if(!accountIdsToClearBillingAddress.isEmpty())
		{	
			for(String accId : accountIdsToClearBillingAddress)
			{
				accountsToClearBillingAddress.add(new Account(Id = accId, BillingStreet = '', BillingCity = '', BillingCountry = '', IATA_ISO_Country__c = null	, BillingState =  '', IATA_ISO_Billing_State__c = null, BillingPostalCode = '', Email__c = '', Website = ''	, Fax = '', Phone = '', TTY__c = ''	));
			}

			update accountsToClearBillingAddress; }

		if(!accountIdsToClearShippingAddress.isEmpty())
		{
			for(String accId : accountIdsToClearShippingAddress)
			{
				accountsToClearShippingAddress.add(new Account(Id = accId, ShippingStreet = '', ShippingCity = '', ShippingCountry = '', IATA_ISO_Shipping_Country__c = null, ShippingState =  '', IATA_ISO_Shipping_State__c = null, ShippingPostalCode = ''));
			}
			update accountsToClearShippingAddress; }


		if(!accountIdToUpdateBillingAddress_Address.isEmpty())
		{
			for(String accId : accountIdToUpdateBillingAddress_Address.keySet())
			{
				AMS_Address__c adr = accountIdToUpdateBillingAddress_Address.get(accId);
				String street = adr.Address_1__c; 
                if(String.isNotBlank(adr.Address_2__c)) street += ' ' + adr.Address_2__c;
                if(String.isNotBlank(adr.Address_3__c)) street += ' ' + adr.Address_3__c;

                String phone = '';
                if(String.isNotBlank(adr.Telephone_Int__c)) phone += adr.Telephone_Int__c + ' ';
                if(String.isNotBlank(adr.Telephone_STD__c)) phone += adr.Telephone_STD__c + ' ';
                if(String.isNotBlank(adr.Telephone__c)) phone += adr.Telephone__c + ' ';

                String fax = ''; 
                if(String.isNotBlank(adr.Fax_Int__c)) fax += adr.Fax_Int__c + ' ';
                if(String.isNotBlank(adr.Fax_STD__c)) fax += adr.Fax_STD__c + ' ';
                if(String.isNotBlank(adr.Fax__c)) fax += adr.Fax__c + ' ';

				if(accId!=null) accountsToUpdateBillingAddress.add(new Account(Id = accId, BillingStreet = street, BillingCity = adr.City__c , BillingCountry = (adr.Country__c != null)? countryNameById.get(adr.Country__c) : '', IATA_ISO_Country__c = adr.Country__c, BillingState = (adr.State__c != null)? stateNameById.get(adr.State__c) : '', IATA_ISO_Billing_State__c = adr.State__c	, BillingPostalCode = adr.AMS_ZipCode__c , Email__c = adr.Email__c, Website = adr.Website__c, Fax = fax	, Phone = phone, TTY__c = adr.TTY__c));
			}

			if(!accountsToUpdateBillingAddress.isEmpty()) update accountsToUpdateBillingAddress; 
		}

		if(!accountIdToUpdateShippingAddress_Address.isEmpty())
		{
			for(String accId : accountIdToUpdateShippingAddress_Address.keySet())
			{
				AMS_Address__c adr = accountIdToUpdateShippingAddress_Address.get(accId);
				String street = adr.Address_1__c; 
                if(String.isNotBlank(adr.Address_2__c)) street += ' ' + adr.Address_2__c;
                if(String.isNotBlank(adr.Address_3__c)) street += ' ' + adr.Address_3__c;

				if(accId!=null) accountsToUpdateShippingAddress.add(new Account(Id = accId, ShippingStreet = street, ShippingCity = adr.City__c , ShippingCountry = (adr.Country__c != null)? countryNameById.get(adr.Country__c) : '', IATA_ISO_Shipping_Country__c = adr.Country__c, ShippingState = (adr.State__c != null)? stateNameById.get(adr.State__c) : ''	, IATA_ISO_Shipping_State__c = adr.State__c	, ShippingPostalCode = adr.AMS_ZipCode__c ));
			}

			if(!accountsToUpdateShippingAddress.isEmpty()) update accountsToUpdateShippingAddress;
		}
	}

	public static void clearAccountAddresses(List<AMS_Address__c> addresses)
	{
		List<Account> accountsToClearAddress = new List<Account>(); 
	
		for(AMS_Address__c adr : addresses)
		{
			if (adr.Account__c == null) continue; 

			if(adr.Address_Type__c!= null && adr.Address_Type__c.contains('Primary'))
			{
				accountsToClearAddress.add(new Account(Id = adr.Account__c, BillingStreet = '', BillingCity = '', BillingCountry = '', BillingState =  '', BillingPostalCode = '', Email__c = '', Website = '', Fax = '', Phone = '', TTY__c = ''));
			}
			else if(adr.Address_Type__c!= null && adr.Address_Type__c.contains('Mailing'))
			{
				accountsToClearAddress.add(new Account(Id = adr.Account__c, ShippingStreet = '', ShippingCity = '', ShippingCountry = '', ShippingState =  '', ShippingPostalCode = ''));
			}
		}

		if(accountsToClearAddress.size() > 0) update accountsToClearAddress;
	}
}