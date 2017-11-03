@isTest
private class ams2gdp_TriggerHelper_Test 
{
	@isTest static void testDeleteAppointmentAccreditations()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 


		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id,IATA_Code__c='123'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id,IATA_Code__c='1234'));
		insert gdp_products;

		//Generate Appointment (AMS) 
		List<AMS_Inspection__c> inspections = ams2gdp_TestDataGenerator.generateAMS_Inspections(4,false);
			inspections[0].Account__c = accounts[0].Id;
			inspections[1].Account__c = accounts[0].Id;
			inspections[2].Account__c = accounts[1].Id;
			inspections[3].Account__c = accounts[1].Id;
		insert inspections;

		List<Accreditation__c> accreditations  = new List<Accreditation__c>();
			accreditations.add(new Accreditation__c(AMS_GDP_Key__c=inspections[0].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[0].Id));
			accreditations.add(new Accreditation__c(AMS_GDP_Key__c=inspections[1].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[0].Id));
			accreditations.add(new Accreditation__c(AMS_GDP_Key__c=inspections[2].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[1].Id));
			accreditations.add(new Accreditation__c(AMS_GDP_Key__c=inspections[3].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[1].Id));
		insert accreditations;

		//Generate AMS Territories 
		List<AMS_Territory__c> ams_territories = ams2gdp_TestDataGenerator.generateAMS_Territories(4,false);
			ams_territories[0].Appointment__c = inspections[0].Id;
			ams_territories[1].Appointment__c = inspections[1].Id;
			ams_territories[2].Appointment__c = inspections[2].Id;
			ams_territories[3].Appointment__c = inspections[3].Id;
		insert ams_territories; 

		List<GSA_Territory__c> gsa_territories = new List<GSA_Territory__c>(); 
			gsa_territories.add(new GSA_Territory__c(AMS_GDP_Key__c=ams_territories[0].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[0].Id));
			gsa_territories.add(new GSA_Territory__c(AMS_GDP_Key__c=ams_territories[1].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[0].Id));
			gsa_territories.add(new GSA_Territory__c(AMS_GDP_Key__c=ams_territories[2].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[1].Id));
			gsa_territories.add(new GSA_Territory__c(AMS_GDP_Key__c=ams_territories[3].Id+'GDP',Related_GDP_Products_Account_View__c=gdp_products[1].Id));
		insert gsa_territories;

		//Delete ams_territories
		delete ams_territories; 
		System.assertEquals(0, [SELECT count() FROM GSA_Territory__c]);

		//Delete Appointments 
		//LF: accreditations are no longer created ore deleted following Appointments: they're now following accounts directly.
		/*Integer countAccreditation =[SELECT count() FROM Accreditation__c];
		delete inspections; 
		System.assertEquals(countAccreditation-4, [SELECT count() FROM Accreditation__c]);*/

	}
	
	@isTest static void testDeleteAccount()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 

		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id,IATA_Code__c='1235'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id,IATA_Code__c='1236'));
		insert gdp_products;

		//Delete Account 
		System.debug('BEFORE::'+[SELECT count() FROM Account]);
		delete accounts; 
		System.debug('AFTER::'+[SELECT count() FROM Account]);

		System.assertEquals(0, [SELECT count() FROM GDP_Products_Account_View__c]);
	}

	@isTest static void testDeleteAirports()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 

		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id+'GDP',IATA_Code__c='1237'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id+'GDP',IATA_Code__c='1238'));
		insert gdp_products;

		//Generate Agency Airports (AMS)
		List<AMS_Agency_Airport__c> ams_airports = ams2gdp_TestDataGenerator.generateAMS_AgencyAirports(4,false); 
			ams_airports[0].Account__c = accounts[0].Id;
			ams_airports[1].Account__c = accounts[0].Id;
			ams_airports[2].Account__c = accounts[1].Id;
			ams_airports[3].Account__c = accounts[1].Id;
		insert ams_airports;

		List<Adjacent_Airport__c> adjacent_airports = new List<Adjacent_Airport__c>(); 
			adjacent_airports.add(new Adjacent_Airport__c(Related_GDP_Products_Account_View__c = gdp_products[0].Id, AMS_GDP_Key__c=ams_airports[0].Id+'GDP'));
			adjacent_airports.add(new Adjacent_Airport__c(Related_GDP_Products_Account_View__c = gdp_products[0].Id, AMS_GDP_Key__c=ams_airports[1].Id+'GDP'));
			adjacent_airports.add(new Adjacent_Airport__c(Related_GDP_Products_Account_View__c = gdp_products[1].Id, AMS_GDP_Key__c=ams_airports[2].Id+'GDP'));
			adjacent_airports.add(new Adjacent_Airport__c(Related_GDP_Products_Account_View__c = gdp_products[1].Id, AMS_GDP_Key__c=ams_airports[3].Id+'GDP'));
		insert adjacent_airports;

		//Delete AMS Airports 
		delete ams_airports; 
		System.assertEquals(0, [SELECT count() FROM Adjacent_Airport__c]);
	}

	@isTest static void testDeleteOwners()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 

		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id+'GDP',IATA_Code__c='1239'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id+'GDP',IATA_Code__c='1240'));
		insert gdp_products;

		//Generate AMS Account Roles : 2 for each account
		List<AMS_Account_Role__c> roles = new List<AMS_Account_Role__c>();
			roles.add(new AMS_Account_Role__c(Account__c=accounts[0].Id, Owner_Name__c='A1 Owner 1', Percentage__c=40,Legacy_External_ID__c='AIMS0011'));
			roles.add(new AMS_Account_Role__c(Account__c=accounts[0].Id, Owner_Name__c='A1 Owner 2', Percentage__c=60,Legacy_External_ID__c='AIMS0012'));
			roles.add(new AMS_Account_Role__c(Account__c=accounts[1].Id, Owner_Name__c='A2 Owner 1', Percentage__c=50,Legacy_External_ID__c='WEB0011'));
			roles.add(new AMS_Account_Role__c(Account__c=accounts[1].Id, Owner_Name__c='A2 Owner 2', Percentage__c=50,Legacy_External_ID__c='WEB0012'));
		insert roles;

		List<Agency_Owner__c> owners = new List<Agency_Owner__c>(); 
			owners.add(new Agency_Owner__c(Related_GDP_Products_Account_View__c=gdp_products[0].Id, AMS_GDP_Key__c=roles[0].Id+'GDP'));
			owners.add(new Agency_Owner__c(Related_GDP_Products_Account_View__c=gdp_products[0].Id, AMS_GDP_Key__c=roles[1].Id+'GDP'));
			owners.add(new Agency_Owner__c(Related_GDP_Products_Account_View__c=gdp_products[1].Id, AMS_GDP_Key__c=roles[2].Id+'GDP'));
			owners.add(new Agency_Owner__c(Related_GDP_Products_Account_View__c=gdp_products[1].Id, AMS_GDP_Key__c=roles[3].Id+'GDP'));
		insert owners;

		//Delete AMS Roles 
		delete roles; 
		System.assertEquals(0, [SELECT count() FROM Agency_Owner__c]);
	}

	@isTest static void testDeleteAffiliations()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 

		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id+'GDP',IATA_Code__c='1241'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id+'GDP',IATA_Code__c='1242'));
		insert gdp_products;

		//Generate AMS Agency Affiliations 
		List<AMS_Agency_Affiliation__c> ams_Affiliations = ams2gdp_TestDataGenerator.generateAMS_Agency_Affiliations(4,false);
			ams_Affiliations[0].Account__c = accounts[0].Id;
			ams_Affiliations[1].Account__c = accounts[0].Id;
			ams_Affiliations[2].Account__c = accounts[1].Id;
			ams_Affiliations[3].Account__c = accounts[1].Id;
		insert ams_Affiliations;

		List<Assoc_Affiliation_Membership__c> assoc_Affiliations = new List<Assoc_Affiliation_Membership__c>();
			assoc_Affiliations.add(new Assoc_Affiliation_Membership__c(Related_GDP_Products_Account_View__c=gdp_products[0].Id,AMS_GDP_Key__c=ams_Affiliations[0].Id+'GDP'));
			assoc_Affiliations.add(new Assoc_Affiliation_Membership__c(Related_GDP_Products_Account_View__c=gdp_products[0].Id,AMS_GDP_Key__c=ams_Affiliations[1].Id+'GDP'));
			assoc_Affiliations.add(new Assoc_Affiliation_Membership__c(Related_GDP_Products_Account_View__c=gdp_products[1].Id,AMS_GDP_Key__c=ams_Affiliations[2].Id+'GDP'));
			assoc_Affiliations.add(new Assoc_Affiliation_Membership__c(Related_GDP_Products_Account_View__c=gdp_products[1].Id,AMS_GDP_Key__c=ams_Affiliations[3].Id+'GDP'));
		insert assoc_Affiliations; 

		delete ams_Affiliations; 
		System.assertEquals(0, [SELECT count() FROM Assoc_Affiliation_Membership__c]);
	}
	@isTest static void testUpdateAccountAddresses()
	{
		//Generate Accounts 2 Accounts 1-AIMS 1-WEBSTAR
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(2, false);
			accounts[0].AIMS_ID__c = 'AIMS001';
			//accounts[1].Webstar_Id__c = 'WEB001';
		insert accounts; 

		List<GDP_Products_Account_View__c> gdp_products = new List<GDP_Products_Account_View__c>();
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[0].Name, AIMS_Id__c='AIMS001', AMS_GDP_Key__c=accounts[0].Id+'GDP',IATA_Code__c='1241'));
			gdp_products.add(new GDP_Products_Account_View__c(Name = accounts[1].Name, Webstar_Id__c='WEB001',AMS_GDP_Key__c=accounts[1].Id+'GDP',IATA_Code__c='1242'));
		insert gdp_products;

	//Generate AMS Address 
		List<AMS_Address__c> addresses = ams2gdp_TestDataGenerator.generateAMS_Addresses(2, false);
			addresses[0].Account__c = accounts[0].Id;
			addresses[1].Account__c = accounts[0].Id;
			//ams_Affiliations[2].Account__c = accounts[1].Id;
			//ams_Affiliations[3].Account__c = accounts[1].Id;
		insert addresses;

		addresses[1].Email__c = 'test_b@test.com';

		update addresses[1];
		List<AMS_Address__c> toDelete=new List<AMS_Address__c>();
		toDelete.add(addresses[1]);

		delete toDelete;
		//system.assertEquals(0, [SELECT count() FROM Assoc_Affiliation_Membership__c]);
	}
}