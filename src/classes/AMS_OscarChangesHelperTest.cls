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
		AMS_OSCAR__c oscar = [SELECT Id, Account__c, Account__r.IATA_ISO_Country__r.Name FROM AMS_OSCAR__c LIMIT 1];	
		IATA_ISO_Country__c ctry = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];

		Test.startTest();
		Account childAccount = new Account(Name='Child', Top_Parent__c= oscar.Account__c, ParentId= oscar.Account__c, IATA_ISO_Country__c= ctry.Id);
		insert childAccount;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Test');
		insert hierarchy;
		AMS_Agencies_relationhip__c relation = new AMS_Agencies_relationhip__c(Hierarchy__c= hierarchy.Id, Parent_Account__c= oscar.Account__c, Child_Account__c= childAccount.Id);
		insert relation;
		AMS_OscarChangesHelper.HierarchyWrapper hw = new AMS_OscarChangesHelper.HierarchyWrapper(hierarchy.Id, relation.Id, oscar.Account__c, childAccount.Id);

		AMS_Account_Role__c role = new AMS_Account_Role__c(Account__c= oscar.Account__c);
		insert role;
			
		AMS_OscarChangesHelper.createSavepoint(new Set<Id> {oscar.Id});
		AMS_OscarChangesHelper.createAccountsSavepoint(new Map<Id,Id> {oscar.Account__c => oscar.Id});

		AMS_OscarChangesHelper.rollbackOscarChanges(new Set<Id> {oscar.Id});		
		AMS_OscarChangesHelper.rollbackHierarchies(new List<AMS_OscarChangesHelper.HierarchyWrapper> {hw});
		AMS_OscarChangesHelper.rollbackRoles(new List<AMS_Account_Role__c> {role});

		Database.executeBatch(new AMS_OscarChangeHistoryCleanBatch(1), 1);
		Test.stopTest();
	}

	@isTest static void testMethod2() {
		AMS_OSCAR__c oscar = [SELECT Id, Account__c, Account__r.IATA_ISO_Country__r.Name FROM AMS_OSCAR__c LIMIT 1];
		Test.setCreatedDate(oscar.Id, DateTime.now().addMonths(-4));
		Technical_Logs__c log = new Technical_Logs__c(Record__c= oscar.Id, Operation__c= 'Rollback');
		insert log;
		Test.setCreatedDate(log.Id, DateTime.now().addMonths(-4));

		Test.startTest();
		AMS_OscarChangeHistoryCleanBatch.start('0 1 * * * ?', 1);
		AMS_OscarChangeHistoryCleanBatch.stop();
		Test.stopTest();
	}

}