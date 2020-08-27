@IsTest
private class CaseItemsTest {
	@TestSetup
	static void makeData(){
		// get a sample picklist value for business service field
		Schema.DescribeFieldResult businessServiceFieldResult = Case_Item__c.IATA_Business_Service__c.getDescribe();
		List<Schema.PicklistEntry> picklistEntry = businessServiceFieldResult.getPicklistValues();
		String businessService = picklistEntry[0].getValue();

		// get a sample picklist value for business process field
		Schema.DescribeFieldResult businessProcessFieldResult = Case_Item__c.IATA_Business_Process__c.getDescribe();
		picklistEntry = businessProcessFieldResult.getPicklistValues();
		String businessProcess = picklistEntry[0].getValue();

		Case caseRecord = new Case();
		insert caseRecord;
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Item__c', 'MASTER');
		Case_Item__c caseItem1 = new Case_Item__c(Status__c = 'Open', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord.Id);
		insert caseItem1;
		Case_Item__c caseItem2 = new Case_Item__c(Status__c = 'Closed (Closed)', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord.Id);
		insert caseItem2;
	}

	@IsTest static void testSetup(){
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(2, caseItemList.size(), 'Expected 2 Case Item record but instead there are ' + caseItemList.size());
	}

	@IsTest static void testOnBeforeDelete(){
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		Database.delete(caseItemList, false);
		caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(1, caseItemList.size(), 'Expected 1 Case Item to be deleted and 1 to remain. Instead there are ' + caseItemList.size());
	}
}