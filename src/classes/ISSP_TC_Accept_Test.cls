@isTest
private class ISSP_TC_Accept_Test {

	@testSetup static void setup() {
		insert new Preferred_Language_on_ISS_Portal__c(Name = 'Test', Language__c = 'Language', LanguageLocalKey__c = 'Language');
		insert new ISSP_CS__c(name = 'PasswordResetPeriod', value__c = '90');

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Name = 'test';
		acc.Location_Type__c = 'HO';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		acc.Sector__c = 'Travel Agent';
		acc.Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING;
		acc.IATACode__c = '100';
		acc.Type = 'IATA Passenger Sales Agent';

		insert acc;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		contact.User_Portal_Status__c = 'Pending Approval';
		contact.Email = 'testing@test.com';
		contact.Financial_Assessment_Contact__c = true;

		insert contact;

		User newUser = new User(alias = 'dsfsdfds',
								email = contact.email,
								emailencodingkey = 'UTF-8',
								firstname = contact.firstName,
								lastname = contact.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = contact.Id,
								timezonesidkey = 'Asia/Dubai',
								username = contact.email+'dfgdf',
								PortalRole = 'Manager',
								CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
								ProfileId = profileId,
								IsActive = true);
		insert newUser;
	}

	static testMethod void myUnitTest_1() {
		User newUser = [SELECT Id, Alias, Email, Emailencodingkey, Firstname, Lastname, Languagelocalekey, Localesidkey, ContactId,
							Timezonesidkey, Username, PortalRole, CommunityNickname, ProfileId, IsActive, AccountId
						FROM User
						WHERE Contact.Email = 'testing@test.com'];

		//Instantiated outside of the RunAs just to be able to access to a field that a newUser don't have access
		ISSP_TC_Accept cttr = new ISSP_TC_Accept();

		system.runAs(newUser){
			system.setPassword(newUser.id, 'testpassword1');

			cttr.accept = false;
			cttr.redirectChangePassword();
			cttr.redirectTC_Accept();
			cttr.docontinue();
			cttr.accept = true;
			cttr.docontinue();

			Boolean show = cttr.showFinancialInstitution;

			PageReference pageRef = Page.ISSP_TC_Accept;
			Test.setCurrentPage(pageRef);
			PageReference pr1 = cttr.pageLoad();
			Boolean bget = cttr.getCountryRequirementPermission();

			cttr.searchText ='test';
			List<SelectOption> lsoLanguages = cttr.languages;
		}
	}

	static testMethod void myUnitTest_2() {
		User newUser = [SELECT Id, Alias, Email, Emailencodingkey, Firstname, Lastname, Languagelocalekey, Localesidkey, ContactId,
						Timezonesidkey, Username, PortalRole, CommunityNickname, ProfileId, IsActive
						FROM User
						WHERE Contact.Email = 'testing@test.com'];

		Portal_Applications__c newApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		newApp.Name = 'TEST';
		insert newApp;
		Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
		newAppRight.Contact__c = newUser.ContactId;
		newAppRight.Portal_Application__c = newApp.Id;
		newAppRight.Right__c = 'Access Granted';
		insert newAppRight;
		ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
		theIds.BSPLink__c = newApp.Id;
		insert theIds;

		ISSP_TC_Accept cttr = new ISSP_TC_Accept();

		system.runAs(newUser){

			cttr.accept = true;
			cttr.redirectChangePassword();
			cttr.redirectTC_Accept();

			PageReference pageRef = Page.ISSP_TC_Accept;
			Test.setCurrentPage(pageRef);
			PageReference pr1 = cttr.pageLoad();
		}
	}

	static testMethod void myUnitTest_3() {
		User newUser = [SELECT Id, Alias, Email, Emailencodingkey, Firstname, Lastname, Languagelocalekey, Localesidkey, ContactId,
						Timezonesidkey, Username, PortalRole, CommunityNickname, ProfileId, IsActive
						FROM User
						WHERE Contact.Email = 'testing@test.com'];

		ISSPLogoutSurvey__c newSurvey = new ISSPLogoutSurvey__c();
		newSurvey.Name = 'test';
		newSurvey.Survey_Link__c = 'http:\\test&iv=1234';
		newSurvey.isActive__c = true;
		insert newSurvey;
		ISSP_TC_Accept cttr = new ISSP_TC_Accept();

		system.runAs(newUser){

			cttr.CheckLogoutorSurvey();
		}
	}

	static testMethod void myUnitTest_4() {
		User newUser = [SELECT Id, Alias, Email, Emailencodingkey, Firstname, Lastname, Languagelocalekey, Localesidkey, ContactId,
						Timezonesidkey, Username, PortalRole, CommunityNickname, ProfileId, IsActive
						FROM User
						WHERE Contact.Email = 'testing@test.com'];

		ISSPLogoutSurvey__c newSurvey = new ISSPLogoutSurvey__c();
		newSurvey.Name = 'test';
		newSurvey.Survey_Link__c = 'http:\\test&iv=1234';
		newSurvey.isActive__c = true;
		insert newSurvey;
		Instant_Surveys__c newSurvey1 = new Instant_Surveys__c();
		newSurvey1.SurveyUserID__c = newUser.Id;
		newSurvey1.SurveyURL__c = '1234';
		insert newSurvey1;
		ISSP_TC_Accept cttr = new ISSP_TC_Accept();

		system.runAs(newUser){
			cttr.CheckLogoutorSurvey();
			system.assertEquals(cttr.isPortalNavigationBar,false);
		}
	}

	static testMethod void myUnitTest_5() {
		Test.startTest();
		ISSP_TC_Accept cttr = new ISSP_TC_Accept();
		cttr.getOperationalCalendarPermission();
		cttr.CheckLogoutorSurvey();
		PageReference pageRef = Page.ISSP_TC_Accept;
		Test.setCurrentPage(pageRef);
		PageReference pr1 = cttr.pageLoad();
		Test.stopTest();
	}
}
