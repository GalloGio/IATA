@IsTest
private class UserServiceTest {
	@TestSetup
	static void makeData(){
		User adminUser = [SELECT Id, UserRoleId FROM User Where IsActive = TRUE AND Profile.Name='System Administrator' Limit 1];
		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		adminUser.UserRoleId = userRole.Id;
		update adminUser;
		System.runAs(adminUser){
			Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert account;
			Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
			contact.AccountId = account.Id;
			insert contact;
			User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			insert user;
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
		System.assertEquals(String.valueOf(contact.Id).substring(0,15), [SELECT FederationIdentifier FROM User WHERE ContactId = :contact.Id].FederationIdentifier);
	}
}