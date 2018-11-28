@isTest
private class ISSP_CurrencyCenterRegOutlookCtrlTest {
	
	@isTest static void testCtrl() {
		Test.startTest();

		Id rt = RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c','X4_Regional_Outlook_News');

		// insert 1 comment record for americas + 1 for europe
		Comment__c americasEntry = new Comment__c(Region__c='Americas', RecordTypeId=rt);
		insert americasEntry;
		Comment__c europeEntry = new Comment__c(Region__c='Europe', RecordTypeId=rt);
		insert europeEntry;

		// initialize page & ctrl for Americas
		PageReference pageRef = Page.ISSP_CurrencyCenterCountry;		
		pageRef.getParameters().put('region', 'Americas');
		Test.setCurrentPage(pageRef);
    	ISSP_CurrencyCenterRegOutlookCtrl ctrl = new ISSP_CurrencyCenterRegOutlookCtrl();

    	/*
    	list should have only 1 record, the 'Europe' one should be ignored
    	(cannot check if it's right region, as it's not retrieved in query in ctrl)
    	*/
    	system.assertEquals(1,ctrl.commentsList.size());
    	system.assertEquals('Americas',ctrl.selectedRegion);

    	Test.stopTest();
	}
	
}