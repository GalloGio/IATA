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
}