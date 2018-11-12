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
		airline.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
		airline.IATA_ISO_Country__c = country.Id;

		Account agency = new Account();
		agency.Name = 'Agency';
		agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		agency.IATACode__c = '24125';
		agency.Location_Type__c = 'HO';
		agency.Location_Class__c = 'P';
		agency.IATA_ISO_Country__c = country.Id;
		insert new List<Account> {airline, agency};

		Contact airlineContact = new Contact();
		airlineContact.FirstName = 'FirstName';
		airlineContact.LastName = 'LastName';
		airlineContact.Email = 'test@mail.com';
		airlineContact.Status__c = 'Active';
		airlineContact.AccountId = airline.Id;
		airlineContact.PSG_Member__c = true;
		airlineContact.PaConf_Representative__c = true; 

		Contact agencyContact = new Contact();
		agencyContact.FirstName = 'FirstName';
		agencyContact.LastName = 'LastName';
		agencyContact.Email = 'mail@test.com';
		agencyContact.AccountId = agency.Id;
		insert new List<Contact> {airlineContact, agencyContact};

		Case cse = new Case();
		cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();
		cse.AccountId = agency.Id;
		cse.ContactId = agencyContact.Id;
		cse.Region__c = 'Europe';
		cse.BSPCountry__c = 'Portugal';
		cse.BSP_CASS__c = 'BSP';
		cse.IATAcode__c = '24125';
		cse.Subject = 'Major Default';
		cse.Short_Payment_Amount__c = 200000000.00;
		insert cse;

		Services_Rendered__c service = new Services_Rendered__c();
		service.Services_Rendered_to_Airline__c = airline.Id;
		service.Services_Rendered_Status__c  = 'Active';
		service.Services_Rendered_Type__c  = 'BSP Participation';
		insert service;
	}
	
	@isTest static void testDefaultNotification() {
		Test.startTest();
		Case cse = [SELECT Id, AccountId FROM Case];
		System.debug('CHECK: ' + [SELECT Id, Services_Rendered_to_Airline__r.Name, ISO_Country_Code__c FROM Services_Rendered__c]);
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c();
		cc.Account__c = cse.AccountId;
		cc.SIDRA_Case__c = cse.Id;
		cc.Change_Code__c = 'DEF';
		insert cc;
		Test.stopTest();
	}
	

}