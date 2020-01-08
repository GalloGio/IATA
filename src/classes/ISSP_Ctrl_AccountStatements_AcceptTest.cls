@istest
public class ISSP_Ctrl_AccountStatements_AcceptTest {

	public static User createPortalUser() {
		Account account = ISSP_ObjectFactory.createNewAccount();
		insert account;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= account.Id;
		con.Email = 'Test@test11.com';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);
		System.debug('newUser Id: ' + newUser.Id);
		con.OwnerId = newUser.Id;
		update con;

		newUser = [Select Id, ContactId from User where Id = :newUser.Id];
		return newUser;
	}

	public static Portal_Applications__c createAccountStatementApp(User user) {
		Portal_Applications__c app = new Portal_Applications__c(
			Name = ISSP_Ctrl_AccountStatements.APP_NAME
		);
		insert app;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
			Portal_Application__c = app.Id,
			Right__c = 'Access Granted',
			Contact__c = user.ContactId
		);
		insert appRight;
		return app;
	}

	@istest
	static void test_controllerError() {

		Test.startTest();
		ISSP_Ctrl_AccountStatements_Accept controller = new ISSP_Ctrl_AccountStatements_Accept();
		Test.stopTest();

		System.AssertEquals(null, controller.appRight);
	}

	@istest
	static void test_controllerOk() {
		User user = createPortalUser();
		Portal_Applications__c app = createAccountStatementApp(user);
		Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

		ISSP_Ctrl_AccountStatements_Accept controller;
		Test.startTest();
		System.runAs(user) {
			controller = new ISSP_Ctrl_AccountStatements_Accept();
			System.AssertEquals(appRight.Id, controller.appRight.Id);

			// reject terms function
			PageReference pageref = controller.rejectTerms();
			System.Assert(pageref!=null);

			// accept terms function without checking
			pageref = controller.acceptTerms();
			System.AssertEquals(null, pageref);

			// accept terms function with checking
			controller.appRight.Terms_Acceptance__c = true;
			pageref = controller.acceptTerms();
			System.Assert(pageref!=null);
		}
		Test.stopTest();
	}
}
