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
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c];

		Test.startTest();

		par.Right__c = 'Access Granted';
		update par;

		Test.stopTest();

		User u = [SELECT Id FROM User WHERE ContactId = :par.Contact__c];

		Integer assignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ANG_App' AND AssigneeId IN (SELECT Id FROM User WHERE ContactId = :par.Contact__c)].size();
		System.assertEquals(1, assignments);
	}
	
	static testMethod void test_removingRequest() {
		Portal_Application_Right__c par = [SELECT Id, Contact__c FROM Portal_Application_Right__c];
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
	
}