public with sharing class AccountContactRoles {
	public static final String STATUSACTIVE = 'Active';
	public static final String STATUSINACTIVE = 'Inactive';

	public List<Account_Contact_Role__c> records { get; private set; }

	public AccountContactRoles(){
		records = new List<Account_Contact_Role__c>();
		//initialise();
	}
	public AccountContactRoles(List<Account_Contact_Role__c> accountContactRoleList){
		records = accountContactRoleList.clone();
		//initialise();
	}
	
	// perform any domain class initialisation logic
	/*private void initialise(){
	}*/

	public List<Account_Contact_Role__c> activate (){
		for(Account_Contact_Role__c accountContactRole : records){
			accountContactRole.Status__c = STATUSACTIVE;
		}
		return records;
	}

	public List<Account_Contact_Role__c> inactivate (){
		for(Account_Contact_Role__c accountContactRole : records){
			accountContactRole.Status__c = STATUSINACTIVE;
		}
		return records;
	}

	//returns a list of new account role records for specified account id set and functional role
	//no status is set
	public List<Account_Contact_Role__c> create(Set<Contact> contactSet, String functionalRoleName, Map<Id, Id> accountIdAccountRoleIdMap){
		if(!Test.isRunningTest() && FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountContactRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');

		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account_Contact_Role__c', 'Functional');
		for(Contact contact : contactSet){
			if(Test.isRunningTest())
				records.add(new Account_Contact_Role__c(RecordTypeId = recordTypeId, Contact__c = contact.Id, Account_Role__c = accountIdAccountRoleIdMap.get(contact.accountId)));
			else
				records.add(new Account_Contact_Role__c(RecordTypeId = recordTypeId, Contact__c = contact.Id, Account_Role__c = accountIdAccountRoleIdMap.get(contact.accountId), Functional_Role__c = functionalRoleName) );
		}
		return records;
	}

	/*
	public void onAfterInsert(){
	}
	public void onAfterUpdate(){
	}
	public void onAfterDelete(){
	}
	public void onAfterUndelete(){
	}
	
	public void onBeforeInsert(){
	}
	public void onBeforeDelete(){
	}
	*/
	
	public class AccountContactRoleDomainException extends Exception {}
}