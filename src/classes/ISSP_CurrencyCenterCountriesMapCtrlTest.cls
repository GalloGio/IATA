@isTest
private class ISSP_CurrencyCenterCountriesMapCtrlTest {
	
	@isTest static void testBlockedFunds() {
        Test.startTest();

        // insert cp
        Country_Profile__c cp1 = new Country_Profile__c(Name='Country BF',Listed_In__c='Blocked Funds', Issue_Started__c = Date.today());
		insert cp1;
		Country_Profile__c cp2 = new Country_Profile__c(Name='Country WL',Listed_In__c='Watch List', Issue_Started__c = Date.today());
		insert cp2;

		Country_Profile_History__c cph = new Country_Profile_History__c(Country_Profile__c=cp1.Id);
		insert cph;

		// initialize page & ctrl for Blocked Funds
		PageReference pageRef = Page.ISSP_CurrencyCenterCountriesMap;		
		pageRef.getParameters().put('type', 'Blocked Funds');
		Test.setCurrentPage(pageRef);
    	ISSP_CurrencyCenterCountriesMapCtrl ctrl = new ISSP_CurrencyCenterCountriesMapCtrl();

    	// list should contain only 1 country (as the 2nd one is on watch list)
    	system.assertEquals(1,ctrl.lstCountries.size());
    	// listType should be Blocked Funds
    	system.assertEquals('Blocked Funds',ctrl.listType);

		List<Boolean> icl = ctrl.isChangedList;
		PageReference pr = ctrl.checkAccess();

        Test.stopTest();
    }
	
}