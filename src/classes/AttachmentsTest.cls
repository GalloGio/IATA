@IsTest
private class AttachmentsTest {
	@TestSetup
	static void makeData(){
		//create attachment for a case with case items
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

		// insert a value in Custom Setting (required for pre-existing attachmentTrigger logic)
		Apex_Setting__c apexSetting = new Apex_Setting__c();
		apexSetting.Name = 'RT valid to reopen attachment trigger';
		apexSetting.Text_1__c = 'CasesEurope,';
		insert apexSetting;
		
		Attachment attachment = new Attachment(Body=Blob.valueOf('SGVsbG8='), Name='Test Attachment', ParentId = caseRecord.Id);
		insert attachment;
	}

	@IsTest
	static void testSetup(){
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c];
		System.assertEquals(1, caseItemList.size());

		List<Attachment> attachmentList = [SELECT Id FROM Attachment];
		System.assertEquals(1, attachmentList.size());
	}

	@IsTest static void testOnAfterInsert(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		Attachment attachment = new Attachment(Body=Blob.valueOf('SGVsbG8='), Name='Test Attachment 1', ParentId = caseRecord.Id);
		Database.SaveResult saveResult = Database.insert(attachment);
		Test.stopTest();
		System.assert(saveResult.isSuccess());
	}

	@IsTest static void testOnAfterUpdate(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		Attachment attachment = [SELECT Id, Name FROM Attachment LIMIT 1];
		attachment.Name='Test Attachment 1.1';
		Database.SaveResult saveResult = Database.update(attachment);
		Test.stopTest();
		System.assert(saveResult.isSuccess());        
	}

	@IsTest static void testOnAfterDelete(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		Attachment attachment = [SELECT Id FROM Attachment LIMIT 1];
		Database.DeleteResult deleteResult = Database.delete(attachment);
		Test.stopTest();
		System.assert(deleteResult.isSuccess());
	}

	@IsTest static void testOnAfterUndelete(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		Attachment attachment = [SELECT Id FROM Attachment LIMIT 1];
		delete attachment;
		Database.UndeleteResult undeleteResult = Database.undelete(attachment);
		Test.stopTest();
		System.assert(undeleteResult.isSuccess());
	}
}