/**
	* Description: This class contains unit tests for the App Menu Controller
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
@isTest(SeeAllData=true)
private class vcIECAppMenu_tst {
		static testMethod void TestMenu() {
				vcIECAppMenu obj = new vcIECAppMenu();
				obj.sSubscriptionNumber = 'TEST';
				obj.sPageName = 'TEST';
				obj.sProductCode  = 'TestProductCode';
				obj.NavigateTo();
		}
}
