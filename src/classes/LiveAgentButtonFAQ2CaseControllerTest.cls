@isTest
private class LiveAgentButtonFAQ2CaseControllerTest {

	static void generateTestData() {

		LiveAgentButtonSettings__c cs = new LiveAgentButtonSettings__c();
		cs.Name = 'english';
		cs.ButtonId__c = 'someid';
		cs.DeploymentId__c = 'someid';
		cs.Language__c = 'en';
		insert cs;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'United Kingdom';
		country.ISO_Code_Numeric__c = 123;
		country.ISO_Code__c = 'GB';
		country.Region__c = 'Europe';
		country.Case_BSP_Country__c  = 'United Kingdom';
		insert country;

		Id AirlineId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');

		Account acc = new Account();
		acc.name ='testAcc';
		acc.IATACode__c = '123';
		acc.Airline_designator__c='AA';
		acc.IATA_ISO_Country__c=country.id;
		acc.recordtypeID = AirlineId;
		insert acc;

		Contact con = new Contact();
		con.FirstName = 'test';
		con.LastName = 'test';
		con.Email = '123test@123.test';
		con.Phone = '123456789';
		con.AccountId = acc.Id;
		insert con;

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'].Id;

		User testUser = new User();
		testuser.ContactId = con.Id;
		testUser.FirstName = 'test';
		testUser.LastName = 'test';
		testUser.Alias = 'test';
		testUser.Email = 'user@test.com';
		testUser.Username = 'user@test.com';
		testUser.CommunityNickname = 'someNick';
		testUser.ProfileId = profileId;
		testUser.TimeZoneSidKey = 'America/Mexico_City';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';
		insert testUser;
	}

	@isTest static void testChatButtonController() {
		generateTestData();

		User testUser = [SELECT FirstName, LastName, ContactId, Email FROM User Where Email = 'user@test.com'][0];
		System.runAs(testUser){

			PageReference pg = Page.LiveAgentButtonFAQ2Case;
			pg.getParameters().put('selTopics','testselTopics');
			pg.getParameters().put('topiclbl','testtopiclbl');
			pg.getParameters().put('subtopiclbl','testsubtopiclbl');
			pg.getParameters().put('csButton','english');
			pg.getParameters().put('concernedCountry','GB');
            pg.getParameters().put('csButtonsList','BUT_CAT_EMERGENCY, BUT_CAT_SLB');
			Test.setCurrentPage(pg);

			LiveAgentButtonFAQ2CaseController ctrl = new LiveAgentButtonFAQ2CaseController();
			System.assert(ctrl.getCaseRecordTypeId() != null);
			System.assert(ctrl.getContactFirstName() != null);
			System.assertEquals(ApexPages.currentPage().getParameters().get('selTopics'), 'testselTopics');
			System.assertEquals(ApexPages.currentPage().getParameters().get('topiclbl'), 'testtopiclbl');
			System.assertEquals(ApexPages.currentPage().getParameters().get('subtopiclbl'), 'testsubtopiclbl');
			System.assert(ctrl.liveAgentBtn.ButtonId__c != null);
			System.assertEquals(ctrl.selectedTopics, 'testselTopics');
			System.assertEquals(ctrl.topicLabel, 'testtopiclbl');
			System.assertEquals(ctrl.subTopicLabel, 'testsubtopiclbl');
            System.assertEquals(ctrl.buttonLanguage, 'en');
			System.assertEquals(ctrl.getContactFirstName(),'Guest');
			ctrl.getContactId();
			ctrl.getAccountId();
			ctrl.country.region__c='Americas';
			System.assert(ctrl.getCaseRecordTypeId() != null);
			ctrl.country.region__c='Africa & Middle East';
			System.assert(ctrl.getCaseRecordTypeId() != null);
			ctrl.country.region__c='Asia & Pacific';
			System.assert(ctrl.getCaseRecordTypeId() != null);
			ctrl.country.region__c='China & North Asia';
			System.assert(ctrl.getCaseRecordTypeId() != null);
			ctrl.country.region__c='testnull';
			System.assert(ctrl.getCaseRecordTypeId() == null);
		}
	}
}
