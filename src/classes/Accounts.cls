public with sharing class Accounts {
	public List<Account> records { get; private set; }

	public Accounts(){
		records = new List<Account>();
		// initialise();
	}

	public Accounts(List<Account> accountList){
		records = accountList.clone();
		// initialise();
	}

	// perform any domain class initialisation logic
	// private void initialise(){

	// }

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

	//return a 'default' Account record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Account> createDefaultAccount(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Account account = (Account) Schema.getGlobalDescribe().get('Account').newSObject();
			account.Name = TestDataFactory_Accounts.DEFAULTNAME + x;
			records.add(account);
		}
		return records;
	}

	public class AccountDomainException extends Exception {}
}