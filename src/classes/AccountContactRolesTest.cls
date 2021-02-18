@IsTest
private class AccountContactRolesTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
		Account_Role__c accountRole = TestDataFactory_AccountRoles.createDefaultAccountRoles(new List<Account>{account}).get(0);
		insert accountRole;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(account.Id, 1).get(0);
		insert contact;
	}

	@IsTest
	static void testAssignRole(){
		Test.startTest();
		List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Account_Role__c accountRole = AccountRoleSelector.selectByAccountsAndRole(new List<Account>{account}, 'FAKE ROLE').get(0);
		Test.stopTest();

		AccountContactRoles accountContactRoles = new AccountContactRoles();
		try{
			accountContactRoles.assignRole(contactList, 'FAKE ROLE', new Map<Id, Id>{account.Id => accountRole.Id});
		} catch(Exception e){
			System.assertEquals('AccountContactRoles.AccountContactRoleDomainException', e.getTypeName(), 'Expected AccountContactRoleDomainException to be thrown but instead got ' + e.getTypeName());
		}
	}

	@IsTest
	static void testUnAssignRole(){
		Test.startTest();
		List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		Test.stopTest();

		AccountContactRoles accountContactRoles = new AccountContactRoles();
		try{
			accountContactRoles.unAssignRole(contactList, 'ROLE');
		} catch(Exception e){
			System.assertEquals('AccountContactRoles.AccountContactRoleDomainException', e.getTypeName(), 'Expected AccountContactRoleDomainException to be thrown but instead got ' + e.getTypeName());
		}
	}
}