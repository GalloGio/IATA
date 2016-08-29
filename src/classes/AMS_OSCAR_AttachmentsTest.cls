@isTest
private class AMS_OSCAR_AttachmentsTest {
	
	@testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
	}
	
	static testMethod void AMS_OSCAR_Attachments() {
		AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];
		
		PageReference pg = Page.AMS_OSCAR_Attachment_List;
		pg.getParameters().put('Id', oscar.Id);
        Test.setCurrentPage(pg);
		AMS_OSCAR_Attachments extension = new AMS_OSCAR_Attachments();
	}
	
}