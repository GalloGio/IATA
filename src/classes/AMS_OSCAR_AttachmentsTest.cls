@isTest
private class AMS_OSCAR_AttachmentsTest {
	
	@testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
	}
	
	static testMethod void AMS_OSCAR_Attachments() {
		AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];

        Test.setCurrentPage(Page.AMS_OSCAR_Attachment_List);
		AMS_OSCAR_Attachments extension = new AMS_OSCAR_Attachments(new ApexPages.StandardController(oscar));
		System.assertNotEquals(null, extension.oscCase);
	}
	
}