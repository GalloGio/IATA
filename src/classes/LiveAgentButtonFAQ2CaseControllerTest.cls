@isTest
private class LiveAgentButtonFAQ2CaseControllerTest {

	@testSetup static void generateTestData() {

		LiveAgentButtonSettings__c cs = new LiveAgentButtonSettings__c();
		cs.Name = 'AirlineEnglishEurope';
		cs.ButtonId__c = 'AirlineEnglishEurope_BId';
		cs.DeploymentId__c = 'AirlineEnglishEurope_DId';
		cs.Language__c = 'en';
		cs.Region__c = 'Europe';
		cs.Sectors__c = 'Travel Agent';
		insert cs;

		LiveAgentButtonSettings__c cs2 = new LiveAgentButtonSettings__c();
		cs2.Name = 'AirlinePortugeseEurope';
		cs2.ButtonId__c = 'AirlinePortugeseEurope_BId';
		cs2.DeploymentId__c = 'AirlinePortugeseEurope_DId';
		cs2.Language__c = 'pt';
		cs2.Region__c = 'Europe';
		cs2.Sectors__c = 'Travel Agent, Airline';
		insert cs2;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'United Kingdom';
		country.ISO_Code_Numeric__c = 123;
		country.ISO_Code__c = 'GB';
		country.Region__c = 'Europe';
		country.LVA_CountryLanguage__c = 'en, pt, it, fr';
		country.Case_BSP_Country__c  = 'United Kingdom';
		insert country;

		Id AirlineId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');

		Account acc = new Account();
		acc.name ='testAcc';
		acc.IATACode__c = '123';
		acc.Airline_designator__c='AA';
		acc.IATA_ISO_Country__c=country.id;
		acc.recordtypeID = AirlineId;
		acc.sector__c = 'Airline';
		insert acc;

		Contact con = new Contact();
		con.FirstName = 'testFirstContact';
		con.LastName = 'test';
		con.Email = '123test@123.test';
		con.Phone = '123456789';
		con.AccountId = acc.Id;
		insert con;

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'].Id;

		User testUser = new User();
		testuser.ContactId = con.Id;
		testUser.FirstName = 'testFirstUser';
		testUser.LastName = 'test';
		testUser.Alias = 'test';
		testUser.Email = 'user@test.com';
		testUser.Username = 'user@test.com';
		testUser.CommunityNickname = 'someNick';
		testUser.ProfileId = profileId;
		testUser.TimeZoneSidKey = 'America/Mexico_City';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'pt_BR';
		insert testUser;
	}

	@isTest static void testChatButtonController() {

		User testUser = [SELECT FirstName, LastName, ContactId, Email FROM User Where Email = 'user@test.com'][0];
		System.runAs(testUser){

			PageReference pg = Page.LiveAgentButtonFAQ2Case;
			pg.getParameters().put('selTopics','testselTopics');
			pg.getParameters().put('topiclbl','testtopiclbl');
			pg.getParameters().put('subtopiclbl','testsubtopiclbl');
			pg.getParameters().put('csButton','AirlineEnglishEurope');
			pg.getParameters().put('concernedCountry','GB');

			Map<String,vfISSP_FAQ2Case.buttonsInfoType> csButtonsList=new Map<String, vfISSP_FAQ2Case.buttonsInfoType>();

			vfISSP_FAQ2Case.buttonsInfoType buttonAux1=new vfISSP_FAQ2Case.buttonsInfoType();
			buttonAux1.Name='AirlineEnglishEurope';
			buttonAux1.ButtonId='AirlineEnglishEurope_BId';
			buttonAux1.Category=vfISSP_FAQ2Case.BUT_CAT_COUNTRY;
			buttonAux1.Language='en';
			buttonAux1.DeploymentId='AirlineEnglishEurope_DId';
			buttonAux1.Order=1;
			csButtonsList.put(vfISSP_FAQ2Case.BUT_CAT_COUNTRY,buttonAux1);

			vfISSP_FAQ2Case.buttonsInfoType buttonAux2=new vfISSP_FAQ2Case.buttonsInfoType();
			buttonAux2.Name='AirlinePortugeseEurope';
			buttonAux2.ButtonId='AirlinePortugeseEurope_BId';
			buttonAux2.Category=vfISSP_FAQ2Case.BUT_CAT_PORTAL;
			buttonAux2.Language='pt';
			buttonAux2.DeploymentId='AirlinePortugeseEurope_DId';
			buttonAux2.Order=2;
			csButtonsList.put(vfISSP_FAQ2Case.BUT_CAT_PORTAL,buttonAux2);

                        pg.getParameters().put('csButtonsListJson',JSON.serialize(csButtonsList));
			pg.getParameters().put('csButtonCategory',vfISSP_FAQ2Case.BUT_CAT_COUNTRY);
			Test.setCurrentPage(pg);

		system.debug('basto1p - JSON.serialize(csButtonsList)='+JSON.serialize(csButtonsList));
			LiveAgentButtonFAQ2CaseController ctrl = new LiveAgentButtonFAQ2CaseController();
		system.debug('basto1p - AFTER CREATE OBJ LiveAgentButtonFAQ2CaseController');

			System.assert(ctrl.getCaseRecordTypeId() != null);
			System.assert(ctrl.getContactFirstName() != null);
			System.assertEquals(ApexPages.currentPage().getParameters().get('selTopics'), 'testselTopics');
			System.assertEquals(ApexPages.currentPage().getParameters().get('topiclbl'), 'testtopiclbl');
			System.assertEquals(ApexPages.currentPage().getParameters().get('subtopiclbl'), 'testsubtopiclbl');
			System.assert(ctrl.liveAgentBtn.ButtonId__c != null);
			System.assertEquals(ctrl.selectedTopics, 'testselTopics');
			System.assertEquals(ctrl.topicLabel, 'testtopiclbl');
			System.assertEquals(ctrl.subTopicLabel, 'testsubtopiclbl');

			//basto1p - Live Agent v2
		system.debug('basto1p - Live Agent V2 Checks START...');
            System.assertEquals(ctrl.buttonLanguage, 'en');
			System.assertEquals(ctrl.isEmergency, false);
			System.assertEquals(ctrl.NumberOfButtons, 2);
			System.assertEquals(ctrl.liveAgentBtnEng.Name, null);
			System.assertEquals(ctrl.liveAgentBtnCountry.Name, 'AirlineEnglishEurope');
			System.assertEquals(ctrl.liveAgentBtnPortal.Name, 'AirlinePortugeseEurope');
			System.assertEquals(ctrl.csButtonAbreviation,'EN');

			//System.assertEquals(ctrl.getContactFirstName(), 'Guest');

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
