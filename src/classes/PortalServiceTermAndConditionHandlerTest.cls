@isTest
private class PortalServiceTermAndConditionHandlerTest {

	@TestSetup
	static void createData(){
		Portal_Applications__c pa = new Portal_Applications__c(
			Name = 'Portal Application Test'
		);
		insert pa;

		Term_and_Condition__c tc = new Term_and_Condition__c(
			Name = 'Term and Condition Test',
			Is_Latest__c = true,
			Effective_Start_Date__c = Date.today(),
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
		);
		insert tc;

		Service_Term_and_Condition__c stc = new Service_Term_and_Condition__c(
			Portal_Service__c = pa.Id,
			Term_Condition__c = tc.Id
		);
		insert stc;
	}

	static testMethod void testUpdate() {

		List<Term_and_Condition__c> tcs = [SELECT Id FROM Term_and_Condition__c WHERE Name = 'Term and Condition Test' LIMIT 1];

		System.assertEquals(1, tcs.size());

		List<Service_Term_and_Condition__c> stcs = [SELECT Id FROM Service_Term_and_Condition__c WHERE Term_Condition__r.Id =: tcs[0].Id];

		System.assertEquals(1, stcs.size());

		Term_and_Condition__c tc2 = new Term_and_Condition__c(
			Name = 'GCS Private Policy',
			Previous_Version__c = tcs[0].Id,
			Is_Latest__c = true,
			Effective_Start_Date__c = Date.today(),
			Version_Number__c = 2,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
		);
		insert tc2;

		Term_and_Condition__c tc = [SELECT Id, Is_Latest__c FROM Term_and_Condition__c WHERE Id =: tcs[0].Id];

		System.assertEquals(false, tc.Is_Latest__c);

		Service_Term_and_Condition__c stc = [SELECT Id,Term_Condition__r.Id FROM Service_Term_and_Condition__c WHERE Id =: stcs[0].Id];

		System.assertEquals(stc.Term_Condition__r.Id, tc2.Id);
	}
}