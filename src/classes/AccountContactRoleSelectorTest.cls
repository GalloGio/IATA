@IsTest
private class AccountContactRoleSelectorTest {
  @TestSetup
  static void makeData(){
	AccountRoles accountRoles = new AccountRoles();
	AccountContactRoles accountContactRoles = new AccountContactRoles();

	Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
	insert account;
	Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
	contact.AccountId = account.Id;
	insert contact;
	Account_Role__c accountRole = TestDataFactory_AccountRoles.createBaseAccountRoles(new List<Account>{account}).get(0);
	accountRole.Status__c = accountRoles.STATUSACTIVE;
	insert accountRole;
	Account_Contact_Role__c accountContactRole = TestDataFactory_AccountContactRoles.createDefaultAccountContactRole(contact.Id, accountRole.Id);
	accountContactRole.Status__c = accountContactRoles.STATUSACTIVE;
	accountContactRole.Account__c = account.Id;
	accountContactRole.Functional_Role__c = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
	accountContactRole.Is_Service_Administrator__c = true;
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

  //AccountContactRoleSelector.selectUserIdMapByUserIdSetAndFunctionalRole() cannot be tested correctly
  //because it relies on custom metadata that is configuration and not reference data
  //so the method is called with a meaningless assertion for code coverage
  @IsTest
  static void testSelectUserIdMapByUserIdSetAndFunctionalRole(){
	String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
	User user = [SELECT Id, ContactId FROM User WHERE Contact.Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0' LIMIT 1];
	Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectUserIdMapByUserIdSetAndFunctionalRole(new Set<Id>{user.Id}, functionalRole);
	System.assert(!accountContactRoleMap.isEmpty());
	System.assert(accountContactRoleMap.get(user.Id).Is_Service_Administrator__c);
  }

  @IsTest
  static void testSelectContactIdAccountRolesByContactIdMap() {
	Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
	Map<Id,List<Account_Contact_Role__c>> accountContactRoleMap = AccountContactRoleSelector.selectContactIdAccountRolesByContactIdMap(new Set<Id>{contactId});
	System.assert(!accountContactRoleMap.isEmpty());
  }

  @IsTest
  static void testSelectAccountContactRoleMap() {
	Account_Contact_Role__c accountContactRole = [SELECT Id, Contact__c FROM Account_Contact_Role__c LIMIT 1];
	Map<Id, Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectAccountContactRoleMap(new Set<Id>{accountContactRole.Contact__c});
	System.assertEquals(accountContactRole.Contact__c, accountContactRoleMap.values().get(0).Contact__c);
  }
}