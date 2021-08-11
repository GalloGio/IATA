@isTest
private  class ISSP_UtilitiesTest {
	static testMethod void ISSP_UtilitiesTest() {
		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;

		Case testCase = ISSP_ObjectFactory.createNewCase();
		insert testCase;
		ISSP_Utilities.SendErrorNotificationEMail('test');
		ISSP_Utilities.getContactTypeById(contact.Id);
		ISSP_Utilities.sendEmailToAdmins(contact.Id);
		ISSP_Utilities.DMLOpt(new set<ID>{testCase.Id});
		ISSP_Utilities.isCNS();
	}

	static testMethod void ISSP_UtilitiesTest2() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User user;
		Contact con;
		Case testCase;

		System.runAs(thisUser){
			Account acc = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
			acc.CNS_Account__c = true;
			insert acc;

			con = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
			insert con;

			testCase = ISSP_ObjectFactory.createNewCase();
			insert testCase;

			String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
			user = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
			user.ProfileId = profileId;
			insert user;
			con.OwnerId = user.Id;
			update con;
		}

		System.runAs(user) {
			ISSP_Utilities.SendErrorNotificationEMail('test');
			ISSP_Utilities.getContactTypeById(con.Id);
			ISSP_Utilities.sendEmailToAdmins(con.Id);
			ISSP_Utilities.DMLOpt(new set<ID>{testCase.Id});
			ISSP_Utilities.isCNS();
		}
	}

	static testMethod void ISSP_UtilitiesTest3() {
		List<Account> a = new List<Account>();
		System.assert(ISSP_Utilities.isEmpty(a));
		a.add(new Account());
		System.assert(ISSP_Utilities.isNotEmpty(a));
		System.assert(ISSP_Utilities.isNumeric('1'));
	}

	static testMethod void test_grantAccessToSIS() {
		// Create portal App
		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = ISSP_SISMembershipApplication_Ctrl.APP_NAME;
		insert app;
		//test account
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
		// test contacts
		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(account.id,2);
		insert contactList;
		// create portal right as denied to test the change to granted
		Portal_Application_Right__c par = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(app.Id, contactList[1].Id);
		par.Right__c = TestDataFactory_PortalApplicationRights.DENIED;
		insert par;

		Test.StartTest();
		ISSP_WS_Utilities.grantAccessToSIS(new list<Id>{contactList[0].Id,contactList[1].Id});
		Test.stopTest();

		list<Portal_Application_Right__c> listResult = [
			SELECT Id
			FROM Portal_Application_Right__c
			WHERE Right__c = 'Access Granted'
		];
		System.assertEquals(2,listResult.size());
	}
}