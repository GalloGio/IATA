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

		Portal_Applications__c app = new Portal_Applications__c(Name = 'ANG_App');
		insert app;

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

			System.debug(loggingLevel.ERROR, '____ [cls ANG_PortalApplicationRightTest - createData] ang_ssoapp - ' + ang_ssoapp);
			System.debug(loggingLevel.ERROR, '____ [cls ANG_PortalApplicationRightTest - createData] ang_provapp - ' + ang_provapp);
			
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
			

			insert new Connected_App_Roles__c(
				Name = 'ANG Test'
				, Connected_App__c = 'ANG_App'
				, Permission_set_SSO__c = 'ANG_SSOApp'
				, PermissionSet_Provisioning__c = 'ANG_ProvApp'
				, Provisioning_Id__c = capp.Id
				, Role__c = 'Tester'
			);
		}

		insert new Portal_Application_Right__c(
			Contact__c = contact.Id
			, Portal_Application__c = app.Id
			, Right__c = 'Access Requested'
			, ANG_Portal_Service_Role__c = 'Tester'
		);
	}
	
	static testMethod void test_grantingAccess() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c];

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
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c];
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
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c];
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
	
}