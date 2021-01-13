@isTest
private class ISSP_CurrencyCenterManageNotifCtrlTest {
    
	/*
	At the time of writing this class, there was no way to insert Network, NetworkMemberGroup
	to then insert EntitySubscription to do a proper test...
	That's why I ended up writing a "dummy" one for coverage.
	*/

    @isTest static void testCtrl() {
        Test.startTest();

		Country_Profile__c cp1 = new Country_Profile__c(Name='Country BF',Listed_In__c='Blocked Funds');
		insert cp1;

		Country_Profile__c cp2 = new Country_Profile__c(Name='Country WL',Listed_In__c='Watch List');
		insert cp2;

		ISSP_CurrencyCenterManageNotifCtrl ctrl = new ISSP_CurrencyCenterManageNotifCtrl();
        ctrl.SaveSubscriptions();

        system.assertEquals(2,ctrl.lstCountryProfiles.size());

        Test.stopTest();
    }
    
}