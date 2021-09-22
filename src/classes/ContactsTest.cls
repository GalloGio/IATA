@IsTest
private class ContactsTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;
	}

	@IsTest
	static void testConstructors(){
		Contacts contacts = new Contacts();
		System.assertEquals(0, contacts.records.size());

		Contact contact = [SELECT Id FROM Contact WHERE Email =: TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		contacts = new Contacts(new List<Contact>{contact});
		System.assertEquals(1, contacts.records.size());
	}

	@IsTest
	static void testUpdateStatus(){
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Contacts contacts = new Contacts(new List<Contact>{contact});
		String originalStatus = String.valueOf(contacts.statusValueMap.get(contacts.statusValueMap.values().get(0).name()));
		contact.Status__c = originalStatus;
		update contact;

		String newStatus = String.valueOf(contacts.statusValueMap.get(contacts.statusValueMap.values().get(1).name()));
		contacts.updateStatus(newStatus);

		System.assertEquals(newStatus,contacts.records.get(0).Status__c, 'Expected Contact.Status__c = ' + newStatus + ' but received ' + contacts.records.get(0).Status__c);
	}

	@IsTest
	static void testcreateDefaultContact(){
		Contacts contacts = new Contacts();
		List<Contact> contactList = contacts.createDefaultContact(1);
		System.assertEquals(TestDataFactory_Contacts.DEFAULTLASTNAME + '0', contactList.get(0).LastName);
		System.assertEquals(TestDataFactory_Contacts.DEFAULTEMAIL + '0', contactList.get(0).Email);
	}
}