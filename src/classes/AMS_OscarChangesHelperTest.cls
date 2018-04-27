@isTest
private class AMS_OscarChangesHelperTest {
	
	@testSetup static void setup() {
		AMS_OSCAR_TestDataFactory.createOSCARtestData();

		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		IATA_ISO_Country__c ctry = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
		Account acc = new Account(IATA_ISO_Country__c = ctry.Id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert acc;

		AMS_OSCAR__c oscar = [SELECT Id, Account__c, Account__r.IATA_ISO_Country__r.Name FROM AMS_OSCAR__c LIMIT 1];
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Hierarchy');
		insert hierarchy;

		AMS_Agencies_relationhip__c relation = new AMS_Agencies_relationhip__c(Hierarchy__c= hierarchy.Id, Parent_Account__c= oscar.Account__c, Child_Account__c= acc.Id);
		insert relation;

		AMS_Account_Role__c role = new AMS_Account_Role__c(Account__c= oscar.Account__c);
		insert role;

		Test.setCreatedDate(oscar.Id, DateTime.newInstance(2012,12,12));
		String cseStr = '{"attributes":{"type":"Case"},"ClosedDate":"2012-10-05T17:54:26.000+0000",' +
	    '"Subject":"Test","Status":"Closed","BSPCountry__c":"All region","Origin":"Email","CreatedDate":"2012-10-04T17:54:26.000+0000",'+
	    '"Reason1__c":"Refund","CaseArea__c":"Finance","Region__c":"Europe","Oscar__c":"'+oscar.Id+'"}';

		Case cse = (Case) JSON.deserialize(cseStr, Case.class);
		insert cse;

		Test.setCreatedDate(cse.Id, DateTime.newInstance(2012,12,12));
	}

	@isTest static void testMethod1() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Account__c, Account__r.IATA_ISO_Country__r.Name FROM AMS_OSCAR__c LIMIT 1];
		AMS_OscarChangesHelper.createSavepoint(new Set<Id> {oscar.Id});
		AMS_OscarChangesHelper.rollbackOscarChanges(new Set<Id> {oscar.Id});
		Database.executeBatch(new AMS_OscarChangeHistoryCleanBatch(1), 1);
		Test.stopTest();
	}

	@isTest static void testMethod2() {
		Test.startTest();
		AMS_OscarChangeHistoryCleanBatch.start('0 1 * * * ?', 1);
		AMS_OscarChangeHistoryCleanBatch.stop();
		Test.stopTest();
	}

}