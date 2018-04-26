@isTest
private class AMS_OscarChangesHelperTest {
	
	@testSetup static void setup() {
		AMS_OSCAR_TestDataFactory.createOSCARtestData();

		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		IATA_ISO_Country__c ctry = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
		Account acc = new Account(IATA_ISO_Country__c = ctry.Id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert acc;
	}

	@isTest static void testMethod1() {
		AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c LIMIT 1];
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Hierarchy');
		insert hierarchy;

		List<Account> accounts = [SELECT Id FROM Account WHERE Id <> :oscar.Account__c LIMIT 1];

		AMS_Agencies_relationhip__c relation = new AMS_Agencies_relationhip__c(Hierarchy__c= hierarchy.Id, Parent_Account__c= oscar.Account__c, Child_Account__c= accounts[0].Id);
		insert relation;

		AMS_Account_Role__c role = new AMS_Account_Role__c(Account__c= oscar.Account__c);
		insert role;

		Test.startTest();
		AMS_OscarChangesHelper.createSavepoint(new Set<Id> {oscar.Id});
		AMS_OscarChangesHelper.rollbackOscarChanges(new Set<Id> {oscar.Id});
		Test.stopTest();
	}

}