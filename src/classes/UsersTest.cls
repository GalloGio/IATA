@IsTest
private class UsersTest {
	@TestSetup
	static void makeData(){
		User adminUser = [Select Id, UserRoleId From User Where IsActive = TRUE AND Profile.Name='System Administrator' Limit 1];
		UserRole userRole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		adminUser.UserRoleId = userRole.Id;
		adminUser.Email = TestDataFactory_Contacts.DEFAULTEMAIL;
		update adminUser;

		System.runAs(adminUser){
			Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert account;
			List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(1);
			contactList.get(0).AccountId = account.Id;
			insert contactList;
			List<User> userList = TestDataFactory_Users.createPortalUsers(contactList);
			insert userList;
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