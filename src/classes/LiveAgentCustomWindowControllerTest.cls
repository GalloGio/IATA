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
        
        System.assertEquals(false,ctrl.isRTL);
        
        pg = Page.LiveAgentCustomWindow;
		cookie = new System.Cookie('lang','ar','somepath',5,false);
		pg.getCookies().put('lang',cookie);
		Test.setCurrentPage(pg);
		ctrl = new LiveAgentCustomWindowController();
        System.assertEquals(true,ctrl.isRTL);
        
        System.assertNotEquals('', ctrl.defaultChatImg);
	}
    
    @isTest
    static void testGetPhoto() {
        Account record = new Account(Name = 'Test');
        insert record;
        record = [select 
        ownerId,
        createdById,
        lastModifiedById,
        createdDate,
        lastModifiedDate 
        from 
        account 
        where id = :record.id];
        
        User owner = [select name, smallPhotoUrl from user where id = :record.ownerId];
        
        System.assertEquals(owner.SmallPhotoUrl, LiveAgentCustomWindowController.getPhoto(owner.Id).SmallPhotoUrl);
        System.assertEquals(null, LiveAgentCustomWindowController.getPhoto('owner.Id'));
    }
    
    @isTest
    static void testGetLanguages() {
        
        
        Account record = new Account(Name = 'Test');
        insert record;
        record = [select 
        ownerId,
        createdById,
        lastModifiedById,
        createdDate,
        lastModifiedDate 
        from 
        account 
        where id = :record.id];
        
        User owner = [select name, smallPhotoUrl, LVA_Language_Skills__c from user where id = :record.ownerId];
        owner.LVA_Language_Skills__c = 'en_US;it';
        update owner;
               	
        Map <String,String> languages = LiveAgentCustomWindowController.getLanguages(record.ownerId);
        Map <String, String> expectedLanguages = new Map<String, String>();
        expectedLanguages.put('en_US', 'English');
        expectedLanguages.put('it', 'Italian');

        Map <String, String> expectedLanguagesBeforeMS = new Map<String, String>();
        expectedLanguagesBeforeMS.put('en_US', 'en_US');
        expectedLanguagesBeforeMS.put('it', 'it');

        if(expectedLanguagesBeforeMS.equals(languages)){
			System.assertEquals(expectedLanguagesBeforeMS, languages);
        } else {
			System.assertEquals(expectedLanguages, languages);
        }
        
        System.assertEquals(null, LiveAgentCustomWindowController.getLanguages('Id'));
    }
}