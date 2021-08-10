@IsTest
private with sharing class UserSelectorTest {
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
			user.FederationIdentifier = String.valueOf(contact.Id).substring(0,15);
			user.Portal_User_Frozen_Checkbox__c = true;
			insert user;
		}
	}

	@IsTest
	static void testSelectUserStatusFields(){
		Contact contact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0' LIMIT 1];
		User user = UserSelector.selectUserStatusFields(new List<Id>{contact.Id}).get(0);

		System.assertEquals(TRUE, user.Portal_User_Frozen_Checkbox__c);		
		System.assertEquals(contact.Id, user.FederationIdentifier);
	}
}
