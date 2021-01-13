@isTest
private class IDCard_ConfirmationPageControllerTest {

	@isTest static void testIDCard_ConfirmationPageController() {

		Test.startTest();

		//selected language default is 'en_US'
		IDCard_ConfirmationPageController pc = new IDCard_ConfirmationPageController();
		System.assertEquals('en_US', pc.getSelectedLanguage());

		//get language options
		List<SelectOption> langItems = pc.getLangItems();

		//set 'es' as selectedlanguage
		pc.setSelectedLanguage(langItems[1].getValue());
		System.assertEquals('es', pc.getSelectedLanguage());

		//set selectedLanguage('es') as cookie value
		Cookie langCookie = new Cookie('idcard_portal_lang', pc.getSelectedLanguage(), null,-1,false);
		ApexPages.currentPage().setCookies(new Cookie[]{langCookie});

		//because cookie is not null constructor will set value of Cookie('es') as selectedLanguage
		pc = new IDCard_ConfirmationPageController();
		System.assertEquals('es', pc.getSelectedLanguage());

		Test.stopTest();
	}
}
