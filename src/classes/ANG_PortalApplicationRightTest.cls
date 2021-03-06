@isTest
private class ANG_PortalApplicationRightTest {

	static {
		//initilize static variables
	}

	@testSetup static void createData() {

		Account acc = ISSP_ObjectFactory.createNewAccount();

		acc.Location_Type__c = 'HO';
		acc.Location_Class__c = 'P';

		insert acc;

		Account acc2 = ISSP_ObjectFactory.createNewAccount();
		acc2.Location_Type__c = 'BR';
		acc2.Location_Class__c = 'P';
		acc2.ParentId = acc.id;
		acc2.Top_Parent__c = acc.id;

		Account acc3 = ISSP_ObjectFactory.createNewAccount();

		insert new List<Account>{acc2, acc3};

		Contact contact = ISSP_ObjectFactory.createNewContact();
		Contact contact2 = ISSP_ObjectFactory.createNewContact();
		Contact contact3 = ISSP_ObjectFactory.createNewContact();
		Contact contactShare = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		contactShare.AccountId = acc.Id;
		contact2.AccountId = acc2.Id;
		contact3.AccountId = acc3.Id;

		insert new List<Contact>{contact, contact2, contact3, contactShare};

		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c app = portalApplicationList.get(0);
		app.Name = 'IATA EasyPay - Tester';
		Portal_Applications__c app2 = portalApplicationList.get(1);
		app2.Name = 'IATA EasyPay';

		insert portalApplicationList;

		ConnectedApplication capp;

		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){

			capp = UserProvisioning.ConnectorTestUtil.createConnectedApp('ANG Provisioning App');

			PermissionSet ang_ssoapp = new PermissionSet(
				Name = 'ANG_SSOApp'
				, Label = 'ANG_SSOApp'
			);

			PermissionSet ang_provapp = new PermissionSet(
				Name = 'ANG_ProvApp'
				, Label = 'ANG_ProvApp'
			);

			insert new List<PermissionSet>{ang_ssoapp, ang_provapp};

			insert new List<User>{
				new User(
					Alias = 'dsfsdfds',
					Email = contact.email,
					Emailencodingkey = 'UTF-8',
					Firstname = contact.firstName,
					Lastname = contact.lastname,
					Languagelocalekey = 'en_US',
					Localesidkey = 'en_US',
					ContactId = contact.Id,
					Timezonesidkey = 'Asia/Dubai',
					Username = contact.email+System.now().getTime()+'portalappright.test1',
					PortalRole = 'Manager',
					CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
					ProfileId = ISSP_Constant.TEST_User_ProfileID,
					IsActive = true
				),
				new User(
					Alias = 'stest',
					Email = contactShare.email,
					Emailencodingkey = 'UTF-8',
					Firstname = contactShare.firstName,
					Lastname = 'share Test',
					Languagelocalekey = 'en_US',
					Localesidkey = 'en_US',
					ContactId = contactShare.Id,
					Timezonesidkey = 'Asia/Dubai',
					Username = contactShare.email+System.now().getTime()+'portalappright.test2',
					PortalRole = 'Manager',
					CommunityNickname = contactShare.email.substring(0, contactShare.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
					ProfileId = ISSP_Constant.TEST_User_ProfileID,
					IsActive = true
				)
			};

			Connected_App_Roles__c car = new Connected_App_Roles__c(
				Name = 'ANG Test'
				, Connected_App__c = 'IATA EasyPay - Tester'
				, Permission_set_SSO__c = 'ANG_SSOApp'
				, PermissionSet_Provisioning__c = 'ANG_ProvApp'
				, Provisioning_Id__c = capp.Id
				, Connected_App_Provisioning_Name__c = capp.Name
				, Role__c = 'Tester'
				, Min_Users_With_Role__c = 0
			);

			Connected_App_Roles__c car2 = new Connected_App_Roles__c(
				Name = 'ANG Test2',
				Connected_App__c = 'IATA EasyPay',
				Permission_set_SSO__c = 'IATA EasyPay',
				Role__c = 'IEP Admin',
				Min_Users_With_Role__c = 1
			);

			Connected_App_Roles__c car3 = new Connected_App_Roles__c(
				Name = 'ANG Test3',
				Connected_App__c = 'IATA EasyPay',
				Permission_set_SSO__c = 'IATA EasyPay',
				Role__c = 'Wallet Gone',
				Min_Users_With_Role__c = 1
			);

			insert new List<Connected_App_Roles__c>{car, car2, car3};
		}

		Portal_Application_Right__c par = new Portal_Application_Right__c(
			Contact__c = contact.Id,
			Portal_Application__c = app.Id,
			Right__c = 'Access Requested',
			ANG_Portal_Service_Role__c = 'Tester'
		);

		Portal_Application_Right__c par2 = new Portal_Application_Right__c(
			Contact__c = contact.Id,
			Portal_Application__c = app2.Id,
			Right__c = 'Access Requested',
			ANG_Portal_Service_Role__c = 'IEP Admin'
		);

		Portal_Application_Right__c par3 = new Portal_Application_Right__c(
			Contact__c = contact2.Id,
			Portal_Application__c = app2.Id,
			Right__c = 'Access Granted',
			ANG_Portal_Service_Role__c = 'IEP Admin'
		);

		Portal_Application_Right__c par4 = new Portal_Application_Right__c(
			Contact__c = contact3.Id,
			Portal_Application__c = app2.Id,
			Right__c = 'Access Granted',
			ANG_Portal_Service_Role__c = 'Wallet Gone'
		);

		insert new List<Portal_Application_Right__c>{par, par2, par3, par4};

		ISSP_External_Reports_Config__c erc = new ISSP_External_Reports_Config__c(Name = 'test', Report_ID__c = 'test', Portal_Service_ID__c = app.Id);
		insert erc;

		insert new ISSP_External_Report__c(Account__c = acc.Id, Report_ID__c = erc.Report_ID__c);
	}

	static testMethod void test_grantingAccess() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];

		Integer provAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ANG_ProvApp' AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(1, provAssignments);

		Test.startTest();

		par.Right__c = 'Access Granted';
		update par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer ssoAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ANG_SSOApp' AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(1, ssoAssignments);
	}

	static testMethod void test_removingAccess() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];
		par.Right__c = 'Access Granted';
		update par;

		Test.startTest();

		delete par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer assignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name in ('ANG_ProvApp', 'ANG_SSOApp') AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(0, assignments);
	}

	static testMethod void test_denyingAccess() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];

		par.Right__c = 'Access Granted';
		update par;

		Test.startTest();

		par.Right__c = 'Access Denied';
		update par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer assignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name in ('ANG_ProvApp', 'ANG_SSOApp') AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(0, assignments);
	}

	static testMethod void test_failProvisioning() {
		UserProvisioningRequest request = [SELECT Id, SalesforceUserId, AppName, State FROM UserProvisioningRequest];

		Test.startTest();

		request.State = 'Failed';
		update request;

		Test.stopTest();

		List<Portal_Application_Right__c> parList = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];
		System.debug(loggingLevel.ERROR, '____ [cls ANG_PortalApplicationRightTest - test_failProvisioning] parList - ' + parList);
		System.assert(parList.isEmpty());
	}

	static testMethod void test_checkMinimumUsersAllowedUpdateAndDelete() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'IEP Admin' AND Right__c = 'Access Requested'];

		Test.startTest();

		par.Right__c = 'Access Denied';

		try {
			update par;
			System.assert(true);
		} catch(Exception e) {
			System.assert(false);
		}

		try {
			delete par;
			System.assert(true);
		} catch(Exception e) {
			System.assert(false);
		}

		Test.stopTest();
	}

	static testMethod void test_checkMinimumUsersAllowedUpdateAndDelete2() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Wallet Gone'];
		par.Right__c = 'Access Granted';
		update par;

		Test.startTest();

		par.Right__c = 'Access Denied';

		try {
			update par;
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains(Label.ANG_ISSP_Min_Users_With_Role_Error_Msg));
		}

		try {
			delete par;
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains(Label.ANG_ISSP_Min_Users_With_Role_Error_Msg));
		}

		Test.stopTest();
	}

	static testMethod void test_checkMinimumUsersAllowedUpdateAndDelete3() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'IEP Admin' AND Right__c = 'Access Granted'];

		Test.startTest();

		par.Right__c = 'Access Denied';

		try {
			update par;
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains(Label.ANG_ISSP_Min_Users_With_Role_Error_Msg));
		}

		try {
			delete par;
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains(Label.ANG_ISSP_Min_Users_With_Role_Error_Msg));
		}

		Test.stopTest();
	}

	@isTest
	private static void manageShareUsersTest(){
		System.debug('[ANG_PortalApplicationRightTest.manageShareUsersTest](before insert) Number of Queries used in this apex code so far: ' + Limits.getQueries());
		//test on insert
		Portal_Application_Right__c par = new Portal_Application_Right__c(
											Contact__c = [SELECT Id, ContactId FROM User WHERE Lastname = 'share Test' LIMIT 1].ContactId,
											Portal_Application__c = [SELECT Id FROM Portal_Applications__c WHERE Name = 'IATA EasyPay - Tester' LIMIT 1].Id,
											Right__c = 'Access Granted'
											);
		Test.startTest();
			insert par;
			System.debug('[ANG_PortalApplicationRightTest.manageShareUsersTest](after insert) Number of Queries used in this apex code so far: ' + Limits.getQueries());
			par.Right__c = 'Access Denied';
			update par;
			System.debug('[ANG_PortalApplicationRightTest.manageShareUsersTest](after update \'Access Denied\') Number of Queries used in this apex code so far: ' + Limits.getQueries());
			//test on update (needs to be on Access Granted)
			par.Right__c = 'Access Granted';
			update par;
		Test.stopTest();
		System.debug('[ANG_PortalApplicationRightTest.manageShareUsersTest](after update \'Access Granted\') Number of Queries used in this apex code so far: ' + Limits.getQueries());
	}
}
