@IsTest
private class AmazonFilesTest {
	@TestSetup
	static void makeData(){
		//create amazon file for a case with case items
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
		AmazonFile__c amazonFile = new AmazonFile__c(Name = 'Test Amazon File', Full_Name_Unique__c = 'Test_Amazon_File', Case__c = caseRecord.Id);
		insert amazonFile;
	}

	@isTest static void testSetup(){
		Test.startTest();
		AmazonFile__c amazonFile = [SELECT Id, Name FROM AmazonFile__c LIMIT 1];
		Test.stopTest();
		System.assertEquals('Test Amazon File', amazonFile.Name, 'Unexpected value');
	}

	@IsTest static void testOnAfterInsert(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		AmazonFile__c amazonFile = new AmazonFile__c(Name = 'Test Amazon File 2', Full_Name_Unique__c = 'Test_Amazon_File_2', Case__c = caseRecord.Id);
		Database.SaveResult saveResult = Database.insert(amazonFile);
		Test.stopTest();
		System.assert(saveResult.isSuccess());
	}

	@IsTest static void testOnAfterUpdate(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		AmazonFile__c amazonFile = [SELECT Id, Name FROM AmazonFile__c LIMIT 1];
		amazonFile.Name='Test Amazon File 1.1';
		Database.SaveResult saveResult = Database.update(amazonFile);
		Test.stopTest();
		System.assert(saveResult.isSuccess());
	}

	@IsTest static void testOnAfterDelete(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		AmazonFile__c amazonFile = [SELECT Id FROM AmazonFile__c LIMIT 1];
		Database.DeleteResult deleteResult = Database.delete(amazonFile);
		Test.stopTest();
		System.assert(deleteResult.isSuccess());
	}

	@IsTest static void testOnAfterUndelete(){
		Test.startTest();
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		AmazonFile__c amazonFile = [SELECT Id FROM AmazonFile__c LIMIT 1];
		delete amazonFile;
		Database.UndeleteResult undeleteResult = Database.undelete(amazonFile);
		Test.stopTest();
		System.assert(undeleteResult.isSuccess());
	}
}