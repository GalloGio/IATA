@isTest
private class ANG_RHCHelperTest {
	

	@testSetup static void createData() {
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US');
		insert ctry;

		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		insert new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
	}
	
	

	static testMethod void rhcInfoInitialization() {
		Account a = [SELECT Id FROM Account LIMIT 1];

		System.assertEquals(0, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());
	}
	
}