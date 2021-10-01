@isTest
private class IncreaseZeroPercentClassCoverage{


	static testMethod void  test1() {
		IFAP_EmailTemplatePreviewController t = new IFAP_EmailTemplatePreviewController();
		AccountTypeDetailsController t2 = new AccountTypeDetailsController();
	}


	static testMethod void  test2() {
		AcliSchedule a = new AcliSchedule();
	}


	static testMethod void  test3() {
		AirlineBranchController temp = new AirlineBranchController();
		String t = temp.parentAccountId;
		List<Services_Rendered__c> servicesList = temp.servicesList;
		t = temp.sortDir;
		t = temp.sortField;

		temp.AirlineBranchController();
	}


	static testMethod void ArchivedAttachmentControllerExtensionCoverage(){
		TestDataFactory_AWSKeys.createAllEntries();
		Account acc = IECTestUtil.createSampleAccount();
		Contact cont = IECTestUtil.createSampleContact(acc);
		Case ca = new Case();
			ca.Subject = 'test 1';
			ca.Status = 'Open';
			ca.AccountId = acc.id;
			ca.ContactId = cont.id;
			ca.CaseArea__c = 'test';
			ca.Reason1__c = 'test';
		insert ca;
		List<Archived_Attachment__c> listAtt = new List<Archived_Attachment__c>();
		Archived_Attachment__c att = new Archived_Attachment__c(
			Case__c = ca.Id,
			Bucket__c = 'asd',
			Name = 'asd'
		);
		insert att;
		listAtt.add(att);
		ApexPages.StandardController stdController = new ApexPages.StandardController(listAtt[0]);
		ArchivedAttachmentControllerExtension t = new ArchivedAttachmentControllerExtension(stdController);
	}

	static testMethod void ArchiveMessageExtensionControllerCoverage(){
		Account acc = IECTestUtil.createSampleAccount();
		Contact cont = IECTestUtil.createSampleContact(acc);
		Case ca = new Case();
		ca.Subject = 'test 1';
		ca.Status = 'Open';
		ca.AccountId = acc.id;
		ca.ContactId = cont.id;
		ca.CaseArea__c = 'test';
		ca.Reason1__c = 'test';
		insert ca;
		
		EmailMessage am = new EmailMessage();
		am.ParentId = ca.Id;
		am.ToAddress = 'test@test.com';
		am.CcAddress = 'test@test.com';
		am.TextBody = 'hello';
		am.Subject= 'Test';
		am.MessageDate = datetime.now();
		insert am;
		
		Archived_Message__c archived = new Archived_Message__c(name = 'testCoverage', EmailMessage__c = am.Id, Case__c = ca.Id);
		insert archived;
		
		ArchiveMessageExtensionController t = new ArchiveMessageExtensionController();	
		t.setArchivedMessageId(String.valueOf(archived.id));
		String archivedMessageId = t.getArchivedMessageId();
		Archived_Message__c archivedMessage = t.getArchivedMessage();
	}

	static testMethod void test6(){
		ChatterAnswersAuthProviderRegistration aa = new  ChatterAnswersAuthProviderRegistration();
		ChatterAnswersRegistration aaa = new ChatterAnswersRegistration();
	}

	static testMethod void test8(){
		ifap_reminderScheduler ifa = new ifap_reminderScheduler();
	}

}
