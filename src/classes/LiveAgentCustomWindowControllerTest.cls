@isTest
private class LiveAgentCustomWindowControllerTest {

	static void createTestData() {
		LiveAgentButtonSettings__c cs = new LiveAgentButtonSettings__c();
		cs.Name = 'spanish';
		cs.ButtonId__c = 'someid';
		cs.DeploymentId__c = 'someid';
		cs.Language__c = 'es';
		insert cs;
	}

	@isTest static void testLiveAgentCustomWindow() {

		createTestData();

		PageReference pg = Page.LiveAgentCustomWindow;
		Test.setCurrentPage(pg);
		LiveAgentCustomWindowController ctrl = new LiveAgentCustomWindowController();
		System.assertEquals('en',ctrl.language);

		pg = Page.LiveAgentCustomWindow;
		pg.getHeaders().put('Referer','csButton=spanish&');
		Test.setCurrentPage(pg);
		ctrl = new LiveAgentCustomWindowController();
		System.assertEquals('es',ctrl.language);

		pg = Page.LiveAgentCustomWindow;
		System.Cookie cookie = new System.Cookie('lang','fr','somepath',5,false);
		pg.getCookies().put('lang',cookie);
		Test.setCurrentPage(pg);
		ctrl = new LiveAgentCustomWindowController();
		System.assertEquals('fr',ctrl.language);

	}
}