@isTest
private class ams2gdp_Batch_Update_Test {
	
	public static Integer nb = 2;

	@testSetup static void loadData() 
	{
		List<AMS2GDP_Log__c> logs = new List<AMS2GDP_Log__c>(); 
		logs.add(new AMS2GDP_Log__c(
			Job_Name__c = 'Job1'
		));
		insert logs; 

		List<GDP_Reference_Table__c> gdsTables = new List<GDP_Reference_Table__c>();
		gdsTables.add(new GDP_Reference_Table__c(Name = 'Amadeus'
			, Code__c = 'AM'
			, Definition__c = 'Amadeus'
			, Table__c = 'AIRSYS'
		));
		gdsTables.add(new GDP_Reference_Table__c(Name = 'Apollo'
			, Code__c = 'AP'
			, Definition__c = 'Apollo'
			, Table__c = 'AIRSYS'
		));

		List<GDP_Reference_Table__c> catTables = new List<GDP_Reference_Table__c>();
		catTables.add(new GDP_Reference_Table__c(Name = 'Administrative Office'
			, Code__c = 'AO'
			, Definition__c = 'Apollo'
			, Table__c = 'LOCCAT'
		));

		List<GDP_Reference_Table__c> classTables = new List<GDP_Reference_Table__c>();
		classTables.add(new GDP_Reference_Table__c(Name = 'Cargo'
			, Code__c = 'C'
			, Definition__c = 'Cargo'
			, Table__c = 'ORGCLASS'
		));

		List<GDP_Reference_Table__c> airCodeTables = new List<GDP_Reference_Table__c>();
		airCodeTables.add(new GDP_Reference_Table__c(Name = 'IATA'
			, Code__c = 'IATA'
			, Definition__c = 'IATA'
			, Table__c = 'ORGABB'
		));
		List<GDP_Reference_Table__c> statusTables = new List<GDP_Reference_Table__c>();
		statusTables.add(new GDP_Reference_Table__c(Name = 'Accredited'
			, Code__c = '9'
			, Definition__c = 'Accredited'
			, Table__c = 'STATUS'
		));

		List<GDP_Reference_Table__c> assocTables = new List<GDP_Reference_Table__c>();
		assocTables.add(new GDP_Reference_Table__c(Name = 'ABAV'
			, Code__c = 'ABAV'
			, Definition__c = 'ABAV'
			, Table__c = 'ASSC'
		));

		List<GDP_Reference_Table__c> airportTables = new List<GDP_Reference_Table__c>();
		airportTables.add(new GDP_Reference_Table__c(Name = 'ABIDJAN'
			, Code__c = 'ABJ'
			, Definition__c = 'ABIDJAN'
			, Table__c = 'AIRPORT'
		));

		


		insert gdsTables; 
		insert catTables; 
		insert classTables; 
		insert airCodeTables; 
		insert statusTables;
		insert assocTables;
		insert airportTables;

		
		//AMS Accounts
		List<Account> accounts = ams2gdp_TestDataGenerator.generateAccounts(nb, true);
			accounts[0].AIMS_ID__c = 'AIMS001';
			accounts[1].Webstar_Id__c = 'WEB001';
		update accounts; 

		//GDP Products 
		List<GDP_Products_Account_View__c> gdpProducts = ams2gdp_BusinessLogic.formatAccount2ProductAccountView(accounts);
		for(GDP_Products_Account_View__c item : gdpProducts){
			item.AMS_GDP_Key__c = null;
		}
		insert gdpProducts; 

		//GDS & Account Categories
		List<Account_Category__c> accountCategories = new List<Account_Category__c>();
		Map<String, String> catRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account_Category__c'); 
  		accountCategories.add(new Account_Category__c(Category_Code__c = catTables[0].Id
			, RecordTypeID = catRecordTypes.get('GDP')
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, Related_Account__c = accounts[0].Id
			, AIMS_ID__c = 'AIMS001GDP'
		));
		
		insert accountCategories; 

		List<GDS__c> gds = new List<GDS__c>();
		Map<String, String> gdsRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDS__c'); 
		gds.add(new GDS__c(Computer_Reservation_System__c = gdsTables[0].Id
			, RecordTypeID = gdsRecordTypes.get('GDP')
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, Related_Account__c = accounts[0].Id
			, AIMS_ID__c = 'AIMS001GDP'
		));
		gds.add(new GDS__c(Computer_Reservation_System__c = gdsTables[1].Id
			, RecordTypeID = gdsRecordTypes.get('Live')
			, Related_GDP_Products_Account_View__c = gdpProducts[1].Id 
			, Related_Account__c = accounts[1].Id
			, Webstar_Id__c = 'WEB001GDP'
		));		
		insert gds; 

		//Accreditations 
		List<Accreditation__c> accreditations =new List<Accreditation__c>();
		Map<String, String> accreditationRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('Accreditation__c'); 
		accreditations.add(new Accreditation__c(AIMS_ID__c = 'AIMS001ACC1GDP'
			, Accreditation_ID__c =1
			, Class__c = classTables[0].Id
			, Status__c = statusTables[0].Id
			, RecordTypeID = accreditationRecordTypes.get('GDP')
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
		));
		accreditations.add(new Accreditation__c(Webstar_Id__c = 'WEBSTAR001ACC1GDP'
			, Accreditation_ID__c =2
			, Class__c = classTables[0].Id
			, Status__c = statusTables[0].Id
			, RecordTypeID = accreditationRecordTypes.get('GDP')
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
		));
		insert accreditations;

		//GDP Phones & Address
		AMS_Address__c adr =  new AMS_Address__c(Legacy_System__c = 'AIMS'
			, Legacy_External_Id__c = 'AIMS001'
			, Address_Type__c = 'Shipping'
		);
		insert adr;

		List<GDP_Phone__c> phones = new List<GDP_Phone__c>(); 
		Map<String, String> phoneRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Phone__c'); 
		phones.add(new GDP_Phone__c(AIMS_ID__c = 'AIMS001P1GDP'
			, Phone_Type__c = 'Phone 1'
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = phoneRecordTypes.get('GDP')
			, Number__c = '1234567890'
			, ISD_Code__c = '1'
		));
		insert phones;

		List<GDP_Address__c> addresses = new List<GDP_Address__c>(); 
		Map<String, String> addressRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Address__c'); 
		addresses.add(new GDP_Address__c(AIMS_ID__c = 'AIMS001MAIGDP'
			, Address_Type__c = 'Mailing'
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = addressRecordTypes.get('GDP')
		));
		insert addresses;

		//Agency Owner 
		List<Agency_Owner__c> owners= new List<Agency_Owner__c>();
		Map<String, String> ownerRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('Agency_Owner__c'); 
		owners.add(new Agency_Owner__c(AIMS_ID__c = 'AIMS001GDP'
			, Owner_ID__c = 1
			, Percent__c = 60
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = ownerRecordTypes.get('GDP')
		));
		owners.add(new Agency_Owner__c(Name = 'Marley', Webstar_Id__c = 'WEB001GDP'
			, Owner_ID__c = 2
			, Percent__c = 40
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = ownerRecordTypes.get('GDP')
		));
		insert owners; 

		//Assoc Affiliation 
		List<Assoc_Affiliation_Membership__c> assocAffiliations = new List<Assoc_Affiliation_Membership__c>(); 
		Map<String, String> assocRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('Assoc_Affiliation_Membership__c'); 
		assocAffiliations.add(new Assoc_Affiliation_Membership__c(AIMS_ID__c = 'AIMS001GDP'
			, Assoc_Affiliation_Code__c = assocTables[0].Id
			, Assoc_Affiliation_ID__c = 1
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = assocRecordTypes.get('GDP')
		));
		insert assocAffiliations;

		//Adjacent Airports
		List<Adjacent_Airport__c> adjacentAirports = new List<Adjacent_Airport__c>(); 
		Map<String, String> airportRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('Adjacent_Airport__c'); 
		adjacentAirports.add(new Adjacent_Airport__c(AIMS_ID__c = 'AIMS001GDP'
			, AirportCode__c = airportTables[0].Id
			, Airport_ID__c = 1
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = airportRecordTypes.get('GDP')
		));
		insert adjacentAirports;

		//Agency profiles
		List<GDP_Agency_Profile_Specialization__c> agencies = new List<GDP_Agency_Profile_Specialization__c>(); 
		Map<String, String> agencyRecordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Agency_Profile_Specialization__c'); 
		agencies.add(new GDP_Agency_Profile_Specialization__c(AIMS_ID__c = 'AIMS001GDP'
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			, RecordTypeID = agencyRecordTypes.get('GDP')
		));
		insert agencies;

		//GSA Territories
		List<GSA_Territory__c> territories = new List<GSA_Territory__c>(); 
		
		territories.add(new GSA_Territory__c(AIMS_ID__c = 'AIMS001GDP'
			,Related_Accreditation__c = accreditations[0].Id
			, AIMS_Territory_Unique_Reference__c = '1234'
			, Related_Account__c = accounts[0].Id
			, Related_GDP_Products_Account_View__c = gdpProducts[0].Id 
			));
		insert territories;
 
	}
	

	@isTest static void test_method_1() {		
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGDPProductsAccountView', null));
		Test.stopTest();
	}
	@isTest static void test_method_2() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAccreditation', null));
		Test.stopTest();	
	}
	@isTest static void test_method_3() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGDPPhone', null));
		Test.stopTest();
	}
	@isTest static void test_method_4() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGDPAddress', null));
		Test.stopTest();
	}

	@isTest static void test_method_5() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAgencyOwner', null));
		Test.stopTest();
	}
	@isTest static void test_method_6() {		
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAssocAffiliationMembership', null));
		Test.stopTest();
	}
	@isTest static void test_method_7() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAdjacentAirport', null));
		Test.stopTest();		
	}

	@isTest static void test_method_8() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGDS', null));
		Test.stopTest();		
	}

	@isTest static void test_method_9() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAccountCategory', null));
		Test.stopTest();		
	}

	@isTest static void test_method_10() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAgencyProfileSpecialization', null));
		Test.stopTest();		
	}

	@isTest static void test_method_11() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGSATerritory', null));
		Test.stopTest();		
	}

	/*@isTest static void test_method_12() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('clearBatchGeneratedData', 'GDS__c'));
		Test.stopTest();		
	}*/

	@isTest static void test_method_13() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('clearLiveRecords', 'GDS__c'));
		Test.stopTest();		
	}

	/*@isTest static void test_method_14() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('clearKeyValues', 'GDS__c'));
		Test.stopTest();		
	}*/
	
	@isTest static void test_method_15() {
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('clearLogs', null));
		Test.stopTest();		
	}

	@isTest static void test_method_16() {		
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGSATerritory', null));
		Test.stopTest();
	}
	@isTest static void test_method_17() {		
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateAgencyProfileSpecialization', null));
		Test.stopTest();
	}
	
	
	

}