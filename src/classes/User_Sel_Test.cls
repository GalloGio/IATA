@isTest
private class User_Sel_Test {

	@isTest static void test_User_Sel() {

		User user = TestDataGenerator.generateUser('Standard User', false);
		insert user;
		new User_Sel().getUserById(user.Id);

		List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts

		new User_Sel().getUserByContactId(contacts[0].Id);
		List<User> lstUser = [select Username from User where UserType='PowerPartner' and IsActive=true LIMIT 1];
		if(lstUser != null && lstUser.size() > 0){
			new User_Sel().getPortalUser(lstUser[0].Username);
		}

		system.assertEquals(1,accounts.size());
		system.assertEquals(2,contacts.size());
	}

}
