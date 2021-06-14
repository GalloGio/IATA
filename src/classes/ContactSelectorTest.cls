@IsTest
private class ContactSelectorTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;
	}

	@IsTest
	static void testSelectByEmails(){
		List<Contact> contactList = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'});
		System.assertEquals(1, contactList.size(), 'Expected 1 Contact but got ' + contactList.size());
	}

	@IsTest
	static void testSelectIdMapByContactSet(){
		Set<Contact> contactSet = new Set<Contact>(ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}));
		System.assertEquals(1, ContactSelector.selectIdMapByContactSet(contactSet).size());
	}

	@IsTest
	static void testSelectByIds(){
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		List<Contact> contactList = ContactSelector.selectByIds(new Set<Id>{contact.Id}).values();
		System.assertEquals(1, contactList.size(), 'Expected 1 Contact but got ' + contactList.size());
	}

	@IsTest
	static void testSelectAccountIdByIds(){
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		List<Contact> contactList = ContactSelector.selectAccountIdByIds(new Set<Id>{contact.Id});
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		System.assertEquals(account.Id, contactList.get(0).AccountId, 'Expected Account Id ' + contactList.get(0).AccountId + ' but received ' + account.Id);
	}

	@IsTest
	static void testSelectEmailContactMapByEmails(){
		Map<String,Contact> contactMap = ContactSelector.selectEmailContactMapByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'});
		System.assert(!contactMap.isEmpty());
	}
}