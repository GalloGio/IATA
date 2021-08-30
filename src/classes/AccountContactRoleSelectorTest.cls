@IsTest
private class AccountContactRoleSelectorTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		insert contact;
		Account_Role__c accountRole = TestDataFactory_AccountRoles.createBaseAccountRoles(new List<Account>{account}).get(0);
		insert accountRole;
		Account_Contact_Role__c accountContactRole = TestDataFactory_AccountContactRoles.createDefaultAccountContactRole(contact.Id, accountRole.Id);
		accountContactRole.Account__c = account.Id;
		insert accountContactRole;

		User adminUser = [SELECT Id, UserRoleId FROM User WHERE IsActive = TRUE AND UserRoleId != NULL AND Profile.Name='System Administrator' LIMIT 1];

		System.runAs(adminUser){
			User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			insert user;
		}
	}

	@IsTest
	static void testSelectMapByServiceAndContactIdSet(){
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Map<Id, Account_Contact_Role__c> assignedContactRoleForServiceAndContactSet = AccountContactRoleSelector.selectMapByServiceAndContactIdSet('', new Set<Id>{contact.Id});
		System.assert(assignedContactRoleForServiceAndContactSet.keySet().contains(contact.Id), 'Expected Contact Id to be in returned assigned role map');
	}

	@IsTest
	static void testSelectByContactsAndFunctionalRole(){
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		List<Account_Contact_Role__c> accountContactRoleList = AccountContactRoleSelector.selectByContactsAndFunctionalRole(new List<Contact>{contact}, '');
		System.assertEquals(1, accountContactRoleList.size());
	}

	@IsTest
	static void testSelectMapByAccountIdSetAndFunctionalRole(){
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Map<Id, Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectMapByAccountIdSetAndFunctionalRole(new Set<Id>{account.Id}, '');
		System.assertEquals(1, accountContactRoleMap.size());
	}
}