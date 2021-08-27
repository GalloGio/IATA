@IsTest
private class UsersTest {
	@TestSetup
	static void makeData(){
		User adminUser = TestDataFactory_Users.createInternalSystemAdminUsers(1).get(0);
		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		adminUser.UserRoleId = userRole.Id;
		insert adminUser;

		System.runAs(adminUser){
			Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert account;
			List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(account.id,1);
			insert contactList;
			List<User> userList = TestDataFactory_Users.createPortalUsers(contactList);
			insert userList;
			contactList[0].OwnerId = userList[0].Id;
			update contactList;
 
		}
	}

	@IsTest
	static void testCreateDefaultPortalUser(){
		Users users = new Users();
		System.assertEquals(0, users.records.size());
		List<Contact> contactList = [SELECT Id, Email, LastName FROM Contact];
		List<User> userList = users.createDefaultPortalUser(contactList);
		System.assertEquals(1, users.records.size());
		users = new Users(userList);
		System.assertEquals(1, users.records.size());

		//test disallowed email domain (email domain must be added to custom metadata IATA_Email_Domain_Name__mdt)
		contactList.get(0).Email = 'testemail@iata.org';
		users = new Users();
		try{
			userList = users.createDefaultPortalUser(contactList);
		} catch(Exception e){
			System.assertEquals(true, e.getMessage().contains('Email Domain is disallowed'));
		}
	}
}