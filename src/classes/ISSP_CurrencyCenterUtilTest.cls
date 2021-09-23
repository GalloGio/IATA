@isTest
private class ISSP_CurrencyCenterUtilTest {
	@isTest static void testCheckIfUserHasAccessToServiceWithoutUser() {
		PageReference result = ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
		System.assertNotEquals(new PageReference('/ISSP_Homepage'),result);
	}

	@isTest static void testStampVisitDateTimeWithoutUser() {
		ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
	}

	@isTest static void testMethodsWithUsers() {
		Test.startTest();

		Account acc = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert acc;

		Contact con = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		con.AccountId = acc.id;
		con.User_Portal_Status__c = 'Approved User';
		insert con;

		User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
		insert newUser;
		con.OwnerId = newUser.Id;
		update con;

		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Application_URL__c='/ISSP_CurrencyCenterHome';
		insert app;

		Portal_Application_Right__c par = new Portal_Application_Right__c(
			Contact__c = newUser.ContactId,
			Right__c = 'Access Granted',
			Portal_Application__c = app.Id
		);
		insert par;

		System.runAs(newUser){
			ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
			ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
			ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
		}
		Test.stopTest();
	}

	@isTest static void testGetPreviousVisitDateTime() {
		ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
	}
}