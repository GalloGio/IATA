@isTest
private class CountryProfileInlineHistoryCtrlTest {

	static Country_Profile__c cp;
	static Country_Profile_History__c cph1;
	
	private static void init(){

		Test.startTest();
        cp = new Country_Profile__c();
        cp.Name = 'Test Country';
        insert cp;
        
        cph1 = new Country_Profile_History__c();
        cph1.Country_Profile__c = cp.Id;
        cph1.OldValue__c = '';
        cph1.NewValue__c = 'someValue';
        insert cph1;

	}

	@isTest static void checkCustomTracking() {
		PageReference pageRef = Page.CountryProfileInlineHistory;
        Test.setCurrentPage(pageRef);

        init();
        Test.stopTest();

        ApexPages.StandardController con = new ApexPages.StandardController(cp);
        CountryProfileInlineHistoryController extension = new CountryProfileInlineHistoryController(con);

        //we should only have 1 record in history
        system.assertEquals(1,extension.historiesList.size());
	}

	@isTest static void checkStandardTracking() {
		PageReference pageRef = Page.CountryProfileInlineHistory;
        Test.setCurrentPage(pageRef);

        init();

        /*
        cp.Issue_Started__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        update cp;
        */

        //We cannot truly test the standad history tracking, hence dummy record is inserted to ensure coverage...
        Country_Profile__History dummyHistory = new Country_Profile__History(Field='Issue_Started__c',ParentId=cp.Id);
        insert dummyHistory;
        Test.stopTest();

        ApexPages.StandardController con = new ApexPages.StandardController(cp);
        CountryProfileInlineHistoryController extension = new CountryProfileInlineHistoryController(con);

        //we should have 2 records in history, 1 custom + 1 standard
        system.assertEquals(2,extension.historiesList.size());
	}


	
}