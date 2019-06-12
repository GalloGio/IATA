@isTest
private class AMS_MajorDefaultCommunicationTest {

	@testSetup static void setup() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.ISO_Code__c = 'PT';
		country.ISO_Code_Numeric__c = 11;
		insert country;

		Account airline = new Account();
		airline.Name = 'Airline';
		airline.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		airline.IATA_ISO_Country__c = country.Id;

		Account agency = new Account();
		agency.Name = 'Agency';
		agency.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		agency.IATACode__c = '24125';
		agency.Location_Type__c = 'HO';
		agency.Location_Class__c = 'P';
		agency.IATA_ISO_Country__c = country.Id;
		insert new List<Account> {airline, agency};

		Contact airlineContact1 = new Contact();
		airlineContact1.FirstName = 'FirstName';
		airlineContact1.LastName = 'LastName';
		airlineContact1.Email = 'test@mail.com';
		airlineContact1.Status__c = 'Active';
		airlineContact1.AccountId = airline.Id;
		airlineContact1.PSG_Member__c = true;
		airlineContact1.PaConf_Representative__c = true; 

		Contact airlineContact2 = new Contact();
		airlineContact2.FirstName = 'FirstName2';
		airlineContact2.LastName = 'LastName2';
		airlineContact2.Email = 'test2@mail.com';
		airlineContact2.Status__c = 'Active';
		airlineContact2.AccountId = airline.Id;
		airlineContact2.PSG_Member__c = true;
		airlineContact2.PaConf_Representative__c = true; 

		Contact agencyContact = new Contact();
		agencyContact.FirstName = 'FirstName';
		agencyContact.LastName = 'LastName';
		agencyContact.Email = 'mail@test.com';
		agencyContact.AccountId = agency.Id;
		insert new List<Contact> {airlineContact1, airlineContact2, agencyContact};

		Case cse = new Case();
		cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
		cse.AccountId = agency.Id;
		cse.ContactId = agencyContact.Id;
		cse.Region__c = 'Europe';
		cse.BSPCountry__c = 'Portugal';
		cse.BSP_CASS__c = 'BSP';
		cse.IATAcode__c = '24125';
		cse.Subject = 'Major Default';
		cse.Short_Payment_Amount__c = 200000000.00;
		cse.Outstanding_Amount__c = 100;
		insert cse;

		Services_Rendered__c service = new Services_Rendered__c();
		service.Services_Rendered_to_Airline__c = airline.Id;
		service.Services_Rendered_Status__c  = 'Active';
		service.Services_Rendered_Type__c  = 'BSP Participation';
		insert service;
	}
	
	@isTest static void testDefaultNotification() {
		User admin = [SELECT Id, ProfileId FROM User WHERE Id <> :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];

		//Avoid MIXED_DML_OPERATION on setup and non-setup objects exception
		System.runAs(admin) {
			Group g = [SELECT Id FROM Group WHERE DeveloperName = 'AMS_Agency_Default_Notification'];
			GroupMember gm = new GroupMember();
			gm.GroupId = g.Id;
			gm.UserOrGroupId = UserInfo.getUserId();
			insert gm;

			Contact c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'test2@mail.com'];
			User u = ISSP_WS_Utilities.createUser(c.FirstName, c.LastName, c.email, 'OtherCompany', c.Id, false);
        	u.FederationIdentifier = String.valueOf(c.Id).substring(0, 15);
        	u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline Delegated Admin User'].Id;
        	insert u;
		}

		Test.startTest();
		Case cse = [SELECT Id, AccountId FROM Case];
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c();
		cc.Account__c = cse.AccountId;
		cc.SIDRA_Case__c = cse.Id;
		cc.Change_Code__c = 'DEF';
		insert cc;

		Test.stopTest();
	}
	

}