@IsTest
public class TestDataFactory_AccountRoles {

	public static List<Account_Role__c> createBaseAccountRoles(List<Account> accountList){
		List<Account_Role__c> accountRoleList = new List<Account_Role__c>();

		for(Integer x = 0; x < accountList.size(); x++){
			Account_Role__c accountRole = new Account_Role__c(Account__c = accountList.get(x).Id);
			accountRoleList.add(accountRole);
		}
		return accountRoleList;
	}

	public static List<Account_Role__c> createAccountRoles(List<Account> accountList, String functionalRoleName){
		List<Account_Role__c> accountRoleList = createBaseAccountRoles(accountList);
		for(Account_Role__c accountRole : accountRoleList){
			accountRole.Functional_Role__c = functionalRoleName;
		}
		return accountRoleList;
	}
}