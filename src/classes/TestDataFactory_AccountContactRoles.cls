@IsTest
public class TestDataFactory_AccountContactRoles {

	//creates a default Account_Contact_Role but without a functional role (this is a picklist value set)
	//and cannot be created in apex for testing purposes
	//NOTE: the Account_Role__c lookup should not be mandatory but legacy from IFTP means we need it
	public static Account_Contact_Role__c createDefaultAccountContactRole(Id contactId, Id accountRoleId){
		return new Account_Contact_Role__c(Contact__c = contactId, Account_Role__c = accountRoleId);
	}

	public static List<Account_Contact_Role__c> createAccountContactRoles(Map<Id, Id> contactIdAccountRoleIdMap, String functionalRoleName){
		List<Account_Contact_Role__c> accountContactRoleList = new List<Account_Contact_Role__c>();
		for(Id contactId : contactIdAccountRoleIdMap.keySet()){
			accountContactRoleList.add(new Account_Contact_Role__c(Contact__c = contactId, Account_Role__c = contactIdAccountRoleIdMap.get(contactId), Functional_Role__c = functionalRoleName));
		}
		return accountContactRoleList;
	}
}