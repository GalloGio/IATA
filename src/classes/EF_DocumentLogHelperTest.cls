@isTest
private class EF_DocumentLogHelperTest
{
	@isTest
	static void testCreatingAttachment()
	{
		User u = EF_TestDataFactory.getEfProfileAndRole(1, 2);
		Group g = [SELECT Id FROM Group WHERE DeveloperName ='EF_Document_Mass_Uploaders'];

		GroupMember gm = new GroupMember();
		gm.GroupId = g.Id;
		gm.UserOrGroupId = u.Id;
		insert gm;
		// List<GroupMember> massUploaders = [SELECT Id, Group.Id FROM GroupMember WHERE Group.DeveloperName = AND :UserInfo.getUserId()];
		System.runAs(u)
		{
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			Test.startTest();
				Attachment a = new Attachment();
				a.Body = Blob.valueOf('attBody');
				a.ParentId = customer.Id;
				a.Name = 'testName';
				insert a;

				List<EF_Document_Log__c> lsDocumentLogs = [SELECT Id FROM  EF_Document_Log__c WHERE AttachmentId__c = :a.Id];
				System.AssertEquals(1,lsDocumentLogs.size(),'there should be 1 document log created');

				lsDocumentLogs[0].FileName__c = 'testName';
				lsDocumentLogs[0].Category__c = 'Contractual';
				lsDocumentLogs[0].Created_On__c = System.now();
				lsDocumentLogs[0].AttachmentId__c = a.Id;
				lsDocumentLogs[0].ParentId__c = customer.Id;
				// launch the update trigger
				update lsDocumentLogs;

				lsDocumentLogs[0].Status__c = 'Amazon - Upload Successful';
				update lsDocumentLogs;

				Id efFileRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', 'EF_File');
				AmazonFile__c af = EF_DocumentLogHelper.createAmazonFileRecord('String fileName', 'String amazonKey', 1000, 'String parentId', efFileRtId, lsDocumentLogs[0]);

				EF_DocumentLogHelper dlh = new EF_DocumentLogHelper();
				dlh.isTestCompliant();
			Test.stopTest();

			List<Attachment> lsAttachments = [SELECT Id FROM Attachment WHERE ParentId = :customer.Id];
			System.AssertEquals(0,lsAttachments.size(),'Attachments should have been deleted');
		}


	}
}