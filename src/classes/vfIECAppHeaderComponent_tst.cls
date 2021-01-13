/**  
  * Description: This class contains unit tests for the (App Header) component 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest
private class vfIECAppHeaderComponent_tst {
	private static Datetime dtNow;
	
	static void Init() {
		dtNow = DateTime.newInstance(1999, 1, 1);
        IECUtil.SetBatchReplication('GDP Replicate: Account Update', dtNow);
    }
    
    static testMethod void TestAppHeader() {
    	System.debug('Unit Test: Start: TestAppHeader');

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	    	Init();

			//Instantiate Controller
	        vfIECAppHeaderComponent pgCont = new vfIECAppHeaderComponent();
	        
	        // Test 001: Load Data refresh date
	        system.assertEquals(pgCont.dtDBLastUpdate, dtNow, 'Refresh Dates must match');
	        
	        // Misc coverage
	        Boolean bTest = pgCont.isUserLoggedIn;
	        pgCont.logout();
	        pgCont.switchToSubscriptionInfo();
	        pgCont.switchToSearchOptions();
	        pgCont.switchToSavedFilters();
	        pgCont.sApplicationTitle = 'IECProductCode';
	        pgCont.subscriptionInfoCtr = New vfIECSubscriptionInfo();
	        pgCont.savedFiltersCtr = new vfIECSavedFilters();
	        String sProductCode = pgCont.sProductCode;
    	}
    	
    	System.debug('Unit Test: Finish: TestAppHeader');
    }
}