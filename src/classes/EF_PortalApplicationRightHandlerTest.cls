@isTest
private class EF_PortalApplicationRightHandlerTest {

	@TestSetup
	static void makeData(){

		Portal_Applications__c efApps = new Portal_Applications__c(Name = 'E&F APPS');
		insert efApps;

		Account acc = new Account();
		acc.Name = 'test_EF_PortalApplicationRightHandler';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		insert acc;

		Account_Role__c accRole = new Account_Role__c();
		accRole.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
		accRole.Functional_Role__c = 'E&F';
		accRole.Account__c = acc.Id;
		insert accRole;

		E_and_F_Account_Role_Detail__c efAccRoleDet = new E_and_F_Account_Role_Detail__c();
		efAccRoleDet.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Account_Role_Detail__c', 'Operator');
		efAccRoleDet.Account_Role__c = accRole.Id;
		insert efAccRoleDet;

		Contact con = new Contact();
		con.FirstName = 'efapps';
		con.LastName = 'handler';
		con.Email = 'efportalapp@right.handler';
		con.Salutation = 'Ms.';
		con.AccountId = acc.Id;
		insert con;

		User usr = TestDataGenerator.generatePortalUser('ISS Portal Airline Delegated Admin User', con.Id, false);
		usr.Email = 'efportalapp@right.handler';
		usr.Phone = '9999999999';
		usr.MobilePhone = '8888888888';
		insert usr;

		Account_Contact_Role__c accConRole = new Account_Contact_Role__c();
		accConRole.Account_Role__c = accRole.Id;
		accConRole.Contact__c = con.Id;
		accConRole.Functional_Role__c = 'E&F';
		accConRole.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		insert accConRole;

		E_and_F_Contact_Role_Detail__c efConRoleDet = new E_and_F_Contact_Role_Detail__c();
		efConRoleDet.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Service_Admin');
		efConRoleDet.Contact_Role__c = accConRole.Id;
		efConRoleDet.E_F_Account_Role_Detail__c = efAccRoleDet.Id;
		insert efConRoleDet;

		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){

			ConnectedApplication conApp = UserProvisioning.ConnectorTestUtil.createConnectedApp('E&F App Test');

			PermissionSet pS = new PermissionSet();
			pS.Name = 'APPS_SSO_Test';
			pS.Label = 'APPS_SSO_Test';
			insert pS;

			Connected_App_Roles__c cAR = new Connected_App_Roles__c();
			cAR.Name = 'E&F APPS';
			cAR.PermissionSet_Provisioning__c = 'APPS_SSO_Test';
			cAR.Provisioning_Id__c = conApp.Id;
			cAR.Connected_App_Provisioning_Name__c = conApp.Name;
			insert cAR;
		}

	}

	@isTest
	static void test_onAfterInsert(){

		Portal_Applications__c pApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS' LIMIT 1];
		Contact con = [SELECT Id FROM Contact WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		PermissionSet pS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'APPS_SSO_Test' LIMIT 1];

		List<UserProvAccount> uPABefore = [SELECT Id FROM UserProvAccount];
		System.assert(uPABefore.isEmpty());

		List<PermissionSetAssignment> psABefore = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assert(psABefore.isEmpty());

		Portal_Application_Right__c pAR = new Portal_Application_Right__c();
		pAR.Contact__c = con.Id;
		pAR.Portal_Application__c = pApp.Id;
		pAR.Right__c = 'Access Granted';
		Test.startTest();
		insert pAR;
		Test.stopTest();

		List<UserProvAccount> uPAAfter = [SELECT Id FROM UserProvAccount];
		List<PermissionSetAssignment> psAAfter = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assertEquals(1, uPAAfter.size());
		System.assertEquals(1, psAAfter.size());
	}

	@isTest
	static void test_onAfterUpdate_Add(){

		Portal_Applications__c pApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS' LIMIT 1];
		Contact con = [SELECT Id FROM Contact WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		PermissionSet pS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'APPS_SSO_Test' LIMIT 1];

		Portal_Application_Right__c pAR = new Portal_Application_Right__c();
		pAR.Contact__c = con.Id;
		pAR.Portal_Application__c = pApp.Id;
		pAR.Right__c = 'Access Denied';
		insert pAR;

		List<UserProvAccount> uPABefore = [SELECT Id FROM UserProvAccount];
		System.assert(uPABefore.isEmpty());

		List<PermissionSetAssignment> psABefore = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assert(psABefore.isEmpty());

		pAR.Right__c = 'Access Granted';
		Test.startTest();
		update pAR;
		Test.stopTest();

		List<UserProvAccount> uPAAfter = [SELECT Id FROM UserProvAccount];
		List<PermissionSetAssignment> psAAfter = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assertEquals(1, uPAAfter.size());
		System.assertEquals(1, psAAfter.size());
	}

	@isTest
	static void test_onAfterUpdate_Remove(){

		Portal_Applications__c pApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS' LIMIT 1];
		Contact con = [SELECT Id FROM Contact WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		PermissionSet pS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'APPS_SSO_Test' LIMIT 1];

		Portal_Application_Right__c pAR = new Portal_Application_Right__c();
		pAR.Contact__c = con.Id;
		pAR.Portal_Application__c = pApp.Id;
		pAR.Right__c = 'Access Granted';
		insert pAR;

		pAR.Right__c = 'Access Denied';
		Test.startTest();
		update pAR;
		Test.stopTest();

		List<PermissionSetAssignment> psAAfter = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assert(psAAfter.isEmpty());
	}

	@isTest
	static void test_onAfterDelete(){

		Portal_Applications__c pApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS' LIMIT 1];
		Contact con = [SELECT Id FROM Contact WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		User u = [SELECT Id FROM User WHERE Email = 'efportalapp@right.handler' LIMIT 1];
		PermissionSet pS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'APPS_SSO_Test' LIMIT 1];

		Portal_Application_Right__c pAR = new Portal_Application_Right__c();
		pAR.Contact__c = con.Id;
		pAR.Portal_Application__c = pApp.Id;
		pAR.Right__c = 'Access Granted';
		insert pAR;

		Test.startTest();
		delete pAR;
		Test.stopTest();

		List<PermissionSetAssignment> psAAfter = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :pS.Id];
		System.assert(psAAfter.isEmpty());
	}

}