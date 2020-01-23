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


	static testMethod void test4(){
		ArchiveAttachmentListController temp = new ArchiveAttachmentListController();
		ArchivedAttachmentControllerExtension t;
	}

	static testMethod void test5(){
		ArchiveMessageExtensionController t = new ArchiveMessageExtensionController();
		t.originalMessage = null;
		string t1= t.archivedMessageId;
		t1 = t.getArchivedMessageId();
	}

	static testMethod void test6(){
		ChatterAnswersAuthProviderRegistration aa = new  ChatterAnswersAuthProviderRegistration();
		ChatterAnswersRegistration aaa = new ChatterAnswersRegistration();
	}

	static testMethod void test8(){
		ifap_reminderScheduler ifa = new ifap_reminderScheduler();
	}

}
