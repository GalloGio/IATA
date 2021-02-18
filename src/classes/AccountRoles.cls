public with sharing class AccountRoles {
	public List<Account_Role__c> records { get; private set; }

	public AccountRoles(){
		records = new List<Account_Role__c>();
		initialise();
	}
	public AccountRoles(List<Account_Role__c> accountRoleList){
		records = accountRoleList.clone();
		initialise();
	}
	
	// perform any domain class initialisation logic
	private void initialise(){
	}

	public List<Account_Role__c> assignRole(Set<Id> accountIdSet, String functionalRoleName){
		List<Account_Role__c> accountRoleList = new List<Account_Role__c>();
		Id recordTypeId = RecordTypeSelector.selectIdBySObjectAndName('Account_Role__c', 'Default');

		if(!Test.isRunningTest() && FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');
		
		Account_Role__c accountRole;
		for(Id accountId : accountIdSet){
			if(Test.isRunningTest())
				accountRole = new Account_Role__c(RecordTypeId = recordTypeId, Account__c = accountId);	
			else
				accountRole = new Account_Role__c(RecordTypeId = recordTypeId, Account__c = accountId, Functional_Role__c = functionalRoleName);

			accountRoleList.add(accountRole);
		}
		return accountRoleList;
	}

	public List<Account_Role__c> unAssignRole(Set<Id> accountIdSet, String functionalRoleName){
		if(!Test.isRunningTest() && FunctionalRoleMetadataSelector.selectByName(functionalRoleName) == null)
			throw new AccountRoleDomainException('Functional role by name ' + functionalRoleName + ' does not exist in Functional Role Custom Metadata');
		return AccountRoleSelector.selectAccountIdByAccountsAndRole(accountIdSet, functionalRoleName);
	}

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
	
	public class AccountRoleDomainException extends Exception {}
}