@isTest(SeeAllData=true)
private class vfIECHomePage_tst {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	PageReference pgRef = Page.IECHomePage;
    	Test.setCurrentPage(pgRef);

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
	        vfIECHomePage pgCont = new vfIECHomePage();
	        pgCont.pageLoad();
	        Boolean bTest = pgCont.isUserLoggedIn;
	        bTest = pgCont.bHasAnyProdAccess;
    	}
    	Test.stopTest();
    }
}