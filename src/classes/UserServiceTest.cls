@IsTest
private class UserServiceTest {
	@TestSetup
	static void makeData(){
		User adminUser = TestDataFactory_Users.createInternalSystemAdminUsers(1).get(0);
		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		adminUser.UserRoleId = userRole.Id;
		insert adminUser;

		System.runAs(adminUser){
			Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert account;
			List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(account.Id, 2);
			insert contactList;
			List<User> portalUserList = TestDataFactory_Users.createPortalUsers(contactList);
			portalUserList.get(1).LastName = 'Run As User';
			insert portalUserList;
			contactList.get(0).OwnerId = portalUserList.get(0).Id;
			update contactList.get(0);
		}
	}

	@IsTest
	static void testCheckUserStatus(){
		Contact contact = [SELECT Id FROM Contact LIMIT 1];
		User user = [SELECT Id, Portal_User_Frozen_Checkbox__c, FederationIdentifier, ContactId FROM User WHERE ContactId = :contact.Id];
		user.Portal_User_Frozen_Checkbox__c = true;
		update user;

		user = [SELECT Id, Portal_User_Frozen_Checkbox__c, FederationIdentifier, ContactId FROM User WHERE ContactId = :contact.Id];
		System.assertEquals(true, user.Portal_User_Frozen_Checkbox__c);

		//runAsPortalUser simulates a portal user triggering the invocable method in UserService
		User runAsPortalUser = [SELECT Id FROM User WHERE LastName = 'Run As User'];
		System.runAs(runAsPortalUser){
			UserService.checkUserStatus(new List<Id>{contact.Id});
		}
		
		user = [SELECT Id, Portal_User_Frozen_Checkbox__c, FederationIdentifier, ContactId FROM User WHERE ContactId = :contact.Id];
		System.assertEquals(FALSE, user.Portal_User_Frozen_Checkbox__c);
	}
}