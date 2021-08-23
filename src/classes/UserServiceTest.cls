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
			Contact contact = TestDataFactory_Contacts.createDefaultContact(account.Id, 1).get(0);
			insert contact;
			User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			insert user;
			contact.OwnerId = user.Id;
			update contact;
		}
	}

	@IsTest
	static void testCheckUserStatus(){
		Contact contact = [SELECT Id FROM Contact LIMIT 1];
		User user = [SELECT Id, Portal_User_Frozen_Checkbox__c, ContactId FROM User WHERE ContactId = :contact.Id];
		user.Portal_User_Frozen_Checkbox__c = true;
		update user;

		UserService.checkUserStatus(new List<Id>{contact.Id});
		System.assertEquals(FALSE, [SELECT Portal_User_Frozen_Checkbox__c FROM User WHERE ContactId = :contact.Id].Portal_User_Frozen_Checkbox__c);
	}
}