@isTest
private class AMS_ValidateAccSpecialChars_Batch_Test
{
	
	@testSetup static void setup() {		

		list<UtilityCS__c> utilities = new list<UtilityCS__c>{
		   new UtilityCS__c(name ='AMS_ValidateAccSpecialChars_Countries',value__c = 'Test1'),
		   new UtilityCS__c(name = 'AMS_ValidateAccSpecialChars_emails',value__c = 'test@test.org') };
		 
		insert utilities;

		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());
		
		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
		Account a1 = new Account(Name='Test1 Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		
		Account a2 = new Account(Name='Test2 – Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345679', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a3 = new Account(Name='Test3 Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345689', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		
		agencylist.add(a1);
		agencylist.add(a2);
		agencylist.add(a3);
		insert agencylist;

	}
	
	static testMethod void runStartTest() {		
		Test.startTest();
		AMS_ValidateAccSpecialChars_Batch a = new AMS_ValidateAccSpecialChars_Batch();
		Database.executeBatch(a, 2000);		
		Test.stopTest();	
	}
	
}