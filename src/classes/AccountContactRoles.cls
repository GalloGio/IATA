public with sharing class AccountContactRoles {
	public List<Account_Contact_Role__c> records { get; private set; }

	public AccountContactRoles(){
		records = new List<Account_Contact_Role__c>();
		// initialise();
	}
	public AccountContactRoles(List<Account_Contact_Role__c> accountContactRoleList){
		records = accountContactRoleList.clone();
		// initialise();
	}
	
	// perform any domain class initialisation logic
	// private void initialise(){
	// }

	public List<Account_Contact_Role__c> assignRole(List<Contact> contactList, String functionalRoleName, Map<Id, Id> accountIdAccountRoleIdMap){
		List<Account_Contact_Role__c> accountContactRoleList = new List<Account_Contact_Role__c>();
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndName('Account_Contact_Role__c', 'Functional');

		if(FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountContactRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');
		
		for(Contact contact : contactList){
			Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c(
				RecordTypeId = recordTypeId,
				Contact__c = contact.Id,
				Account_Role__c = accountIdAccountRoleIdMap.get(contact.AccountId),
				Functional_Role__c = functionalRoleName,
				Contact_Role_Name__c = functionalRoleName);
			accountContactRoleList.add(accountContactRole);
		}
		return accountContactRoleList;
	}

	public List<Account_Contact_Role__c> unAssignRole(List<Contact> contactList, String functionalRoleName){
		if(FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountContactRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');
		
		return AccountContactRoleSelector.selectByContactsAndFunctionalRole(contactList , functionalRoleName);
	}

	// public void onAfterInsert(){
	// }
	// public void onAfterUpdate(){
	// }
	// public void onAfterDelete(){
	// }
	// public void onAfterUndelete(){
	// }
	
	// public void onBeforeInsert(){
	// }
	// public void onBeforeDelete(){
	// }
	
	public class AccountContactRoleDomainException extends Exception {}
}