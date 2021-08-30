public with sharing class AccountRoles {
	public final String STATUSACTIVE = 'Active';
	public final String STATUSINACTIVE = 'Inactive';

	public List<Account_Role__c> records { get; private set; }

	public AccountRoles(){
		records = new List<Account_Role__c>();
		//initialise();
	}
	public AccountRoles(List<Account_Role__c> accountRoleList){
		records = accountRoleList.clone();
		//initialise();
	}
	
	// perform any domain class initialisation logic
	/*private void initialise(){
	}*/

	public List<Account_Role__c> activate (){
		for(Account_Role__c accountRole : records){
			accountRole.Status__c = STATUSACTIVE;
		}
		return records;
	}

	public List<Account_Role__c> inactivate (){
		for(Account_Role__c accountRole : records){
			accountRole.Status__c = STATUSINACTIVE;
		}
		return records;
	}

	//returns a list of new account role records for specified account id set and functional role
	//no status is set
	public List<Account_Role__c> create(Set<Id> accountIdSet, String functionalRoleName){
		if(!Test.isRunningTest() && FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');

		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account_Role__c', 'Default');
		for(Id accountId : accountIdSet){
			records.add(new Account_Role__c(RecordTypeId = recordTypeId, Account__c = accountId, Functional_Role__c = functionalRoleName) );
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
	
	public class AccountRoleDomainException extends Exception {}
}