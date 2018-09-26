@isTest
private class AMS_OSCAR_AttachmentsTest {
	
	@testSetup static void setup(){
		WrapperAttachTest.loadTestCredentials();
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
	}
	
	static testMethod void AMS_OSCAR_Attachments() {
		AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];
		Case cse = [SELECT Id FROM Case WHERE OSCAR__c = :oscar.Id];
		AmazonFile amazonFile = WrapperAttachTest.createAmazonFile(cse);
	
		Attachment a = new Attachment(
			OwnerId = UserInfo.getUserId(),
			IsPrivate = true,
			ParentId = cse.Id,
			Body = Blob.valueOf('Test'),
			Name = 'test'
		);
		insert a;
	
		Archived_Attachment__c att = new Archived_Attachment__c(
			Case__c = cse.Id,
			Bucket__c = 'bucket',
			Name = 'testname'
		);
		insert att;
	
		EF_AttachmentListController.runningForEF = false;
	
		PageReference pg = Page.AMS_OSCAR_Attachment_List;
		pg.getParameters().put('Id', oscar.Id);
		Test.setCurrentPage(pg);
	
		AMS_OSCAR_Attachments con = new AMS_OSCAR_Attachments();
	
		System.assertEquals(cse.Id, con.caseId);
	
		System.assertEquals(3, con.listAttachments.size());
		System.assert(con.getCanAttachFilesToCase(), 'Impossible to attach');
	
		System.assertEquals('No records to display', con.emptyList[0]);
	
		con.makeAllPrivate();
		System.assert(!con.listAttachments[0].isPublic);
	
		try{
			con.makeAllPublic();
			System.assert(con.listAttachments[0].isPublic);
		}catch(Exception e){
			System.assert(e.getMessage().contains('Id not specified'));
		}
		try{
			con.listAttachments[0].isPublic = false;
			con.updateAllAttach();
		}catch(Exception e){
			System.assert(e.getMessage().contains('Id not specified'));
		}
	
		Test.startTest();
		con.refreshList();
		System.assert(!con.listAttachments[0].isPublic);
	
		System.assert(con.getTransferAttachmentsUrl().indexOf(cse.Id) > -1);
		System.assert(con.goToAttachmentPage().getUrl().indexOf(cse.Id) > -1);
	
		System.assertEquals(3, AMS_OSCAR_Attachments.getAllExpiringLink(cse.Id).size());
		System.assertEquals(AMS_OSCAR_Attachments.getExpiringLink('testfileName.pdf'), AMS_OSCAR_Attachments.getExpiringLinkWS('testfileName.pdf'));
	
		System.assertEquals(1, AMS_OSCAR_Attachments.getSelectedExpiringLink(cse.Id, new List<String>{a.Id}).size());
	
		//read
		System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.amazonPath - ' + con.amazonPath);
		System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.amazonURL - ' + con.amazonURL);
		System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.credentialName - ' + con.credentialName);
	
		System.assert(AMS_OSCAR_Attachments.deleteAttachment(a.Id, a.Name));
		System.assert(!AMS_OSCAR_Attachments.deleteAttachment(att.Id, att.Name));
		System.assert(!AMS_OSCAR_Attachments.deleteAttachment(amazonFile.getId(), amazonFile.getFullName()));
		Test.stopTest();
	}

	static testMethod void AMS_OSCAR_Attachments_2() {
		AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];
		Case cse = [SELECT Id FROM Case WHERE OSCAR__c = :oscar.Id];
		AmazonFile amazonFile = WrapperAttachTest.createAmazonFile(cse);

		EF_AttachmentListController.runningForEF = false;

		PageReference pg = Page.AMS_OSCAR_Attachment_List;
		pg.getParameters().put('Id', oscar.Id);
		Test.setCurrentPage(pg);

		AMS_OSCAR_Attachments con = new AMS_OSCAR_Attachments();
		Test.startTest();
		con.listAttachments[0].isSelected = true;
		con.acceptFiles();
		System.assertEquals('Accepted', con.listAttachments[0].fileAmazon.amazonFile.Review_Status__c);
		con.listAttachments[0].isSelected = true;
		con.rejectFiles();	
		System.assertEquals('Rejected', con.listAttachments[0].fileAmazon.amazonFile.Review_Status__c);	
		Test.stopTest();
	}
	
}