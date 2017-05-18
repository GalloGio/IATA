@isTest
private class ANG_PortalApplicationRightTest {
	
	static {
		//initilize static variables
	}

	@testSetup static void createData() {
		Account acc = ISSP_ObjectFactory.createNewAccount();  

		insert acc;
		
		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		insert contact;

		insert new Connected_App_Roles__c(
			Name = 'ANG Test'
			, Connected_App__c = 'ANG_App'
			, Permission_set_SSO__c = 'ANG_App'
			, Role__c = 'Tester'
		);

		Portal_Applications__c app = new Portal_Applications__c(Name = 'ANG_App');
		insert app;

		insert new Portal_Application_Right__c(
			Contact__c = contact.Id
			, Portal_Application__c = app.Id
			, Right__c = 'Access Requested'
			, ANG_Portal_Service_Role__c = 'Tester'
		);

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
		contact.AccountId = acc.Id;
		contact2.AccountId = acc2.Id;
		contact3.AccountId = acc3.Id;

		insert new List<Contact>{contact, contact2, contact3};

		Connected_App_Roles__c car = new Connected_App_Roles__c(
			Name = 'ANG Test',
			Connected_App__c = 'ANG_App',
			Permission_set_SSO__c = 'ANG_App',
			Role__c = 'Tester',
			Min_Users_With_Role__c = 0
		);

		Connected_App_Roles__c car2 = new Connected_App_Roles__c(
			Name = 'ANG Test2',
			Connected_App__c = 'IATA EasyPay',
			Permission_set_SSO__c = 'IATA EasyPay',
			Role__c = 'IEP Admin',
			Min_Users_With_Role__c = 2
		);

		Connected_App_Roles__c car3 = new Connected_App_Roles__c(
			Name = 'ANG Test3',
			Connected_App__c = 'IATA EasyPay',
			Permission_set_SSO__c = 'IATA EasyPay',
			Role__c = 'Wallet Gone',
			Min_Users_With_Role__c = 1
		);		

		insert new List<Connected_App_Roles__c>{car, car2, car3};

		Portal_Applications__c app = new Portal_Applications__c(Name = 'ANG_App');
		Portal_Applications__c app2 = new Portal_Applications__c(Name = 'IATA EasyPay');
		
		insert new List<Portal_Applications__c>{app, app2};

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

		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){

			insert new PermissionSet(
				Name = 'ANG_App'
				, Label = 'ANG_App'
			);
			
			insert new User(
				Alias = 'dsfsdfds', 
				Email = contact.email, 
				Emailencodingkey = 'UTF-8', 
				Firstname = contact.firstName, 
				Lastname = contact.lastname, 
				Languagelocalekey = 'en_US', 
				Localesidkey = 'en_US', 
				ContactId = contact.Id,
				Timezonesidkey = 'Asia/Dubai',
				Username = contact.email+'dfgdf',
				PortalRole = 'Manager',
				CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
				ProfileId = ISSP_Constant.TEST_User_ProfileID,
				IsActive = true
			);
			
		}
	}
	
	static testMethod void test_grantingRequest() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];

		Test.startTest();

		par.Right__c = 'Access Granted';
		update par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer assignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ANG_App' AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(1, assignments);
	}
	
	static testMethod void test_removingRequest() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'Tester'];

		par.Right__c = 'Access Granted';
		update par;

		Test.startTest();

		par.Right__c = 'Access Denied';
		update par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer assignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ANG_App' AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(0, assignments);
	}

	static testMethod void test_checkMinimumUsersAllowedUpdateAndDelete() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c WHERE ANG_Portal_Service_Role__c = 'IEP Admin' AND Right__c = 'Access Requested'];

		Test.startTest();

		par.Right__c = 'Access Denied';

		try {
			update par;	
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
		}

		try {
			delete par;	
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
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
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
		}

		try {
			delete par;	
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
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
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
		}

		try {
			delete par;	
			System.assert(false);
		} catch(Exception e) {
			System.assert(e.getMessage().contains('The following contact is the sole remaining'));
		}

		Test.stopTest();
	}
}