@isTest
private class IDCardPendingCaseControllerTest{

	static testMethod void Testing() {


			Case myTest = new Case();
			Insert myTest;

			Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);

			PageReference pendingPage = Page.IDCard_PendingCase_Details;
			pendingPage.getParameters().put('cid', IDCardUtil.EncryptEncodeParameter(myTest.Id));
			pendingPage.setCookies(new Cookie[]{languageCookies});



			Test.setCurrentPage(pendingPage);

			IDCardPendingCaseController cont = new IDCardPendingCaseController();
				cont.getLangItems();
			cont.setSelectedLanguage('en');
			cont.getSelectedLanguage();
	}

}
