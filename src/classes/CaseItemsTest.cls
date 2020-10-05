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
		Case caseRecord2 = new Case();
		insert caseRecord2;
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Item__c', 'MASTER');
		Case_Item__c caseItem1 = new Case_Item__c(Status__c = 'Open', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord.Id);
		insert caseItem1;
		Case_Item__c caseItem2 = new Case_Item__c(Status__c = 'Closed', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord2.Id);
		insert caseItem2;
	}

	@IsTest static void testSetup(){
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(2, caseItemList.size(), 'Expected 2 Case Item record but instead there are ' + caseItemList.size());
	}

	@IsTest static void testOnAfterInsert(){
		Test.startTest();
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
		Case_Item__c caseItem = new Case_Item__c(Status__c = 'Open', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord.Id);
		insert caseItem;
		Test.stopTest();

		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(false, caseItemList.isEmpty(), 'Expected non empty Case Item list');
	}

	@IsTest static void testOnAfterUpdate(){
		Test.startTest();
		Case_Item__c caseItem = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Open' LIMIT 1];
		caseItem.Status__c = 'Closed';
		update caseItem;
		Test.stopTest();

		caseItem = [SELECT Id, Status__c FROM Case_Item__c WHERE Id = :caseItem.Id];
		System.assertEquals('Closed', caseItem.Status__c);
	}

	@IsTest static void testOnAfterDelete(){
		Test.startTest();
		Case_Item__c caseItem = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Closed' LIMIT 1];
		
		delete caseItem;
		Test.stopTest();

		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Closed'];
		System.assertEquals(0, caseItemList.size(), 'Expected no Case Items with Status Closed');
	}
	
	@IsTest static void  testOnAfterUndelete(){
		Case_Item__c caseItem = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Closed' LIMIT 1];
		delete caseItem;
		
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Closed'];
		System.assertEquals(0, caseItemList.size(), 'Expected no Case Items with Status Closed');

		undelete(caseItem);
		caseItemList = [SELECT Id FROM Case_Item__c WHERE Status__c = 'Closed'];
		System.assertEquals(1, caseItemList.size(), 'Expected 1 Case Items with Status Closed');
	}

	@IsTest static void testOnBeforeDelete(){
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		Database.delete(caseItemList, false);
		caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(0, caseItemList.size(), 'Expected 1 Case Item to be deleted and 0 to remain. Instead there are ' + caseItemList.size());
	}

	@IsTest static void testOnBeforeUpdate(){
		Case_Item__c caseItem = [SELECT Id, Status__c FROM Case_Item__c LIMIT 1];
		caseItem.Status__c = 'Completed';
		Database.SaveResult saveResult = Database.update(caseItem, false);
		caseItem = [SELECT Id, Status__c FROM Case_Item__c WHERE Id = :caseItem.Id];
		System.assertEquals('Completed', caseItem.Status__c);

		User user = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = :CaseItems.integrationUserProfileName LIMIT 1];
		System.runAs(user){
			saveResult = Database.update(caseItem, false);
		}
		System.assertEquals(true, saveResult.success);
	}
}