/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger checks that the code of new or updated ICCS Bank Accounts is unique. If it's not,
 *     it raises an error and prevents the insertion or update.
 */
trigger trgBankCodeCheckUnique on ICCS_Bank_Account__c (before insert, before update) {
	// we create a map of all existing bank account codes and their salesforce IDs
	Map<String, Id> mapBankAccountIdsPerAccountCodes = new Map<String, Id>();
	List<ICCS_Bank_Account__c> tmpBankAccounts = [SELECT Id, Name, Account__r.ACLI_Status__c FROM ICCS_Bank_Account__c WHERE Account__r.ACLI_Status__c != 'Inactive Company'];
	for (ICCS_Bank_Account__c iba : tmpBankAccounts) {
		mapBankAccountIdsPerAccountCodes.put(iba.Name, iba.Id);
	}

	// check the uniqueness of the bank account code
	for (ICCS_Bank_Account__c iba : Trigger.new) {
		if ((Trigger.isInsert && mapBankAccountIdsPerAccountCodes.get(iba.Name) != null) ||
			(Trigger.isUpdate && mapBankAccountIdsPerAccountCodes.get(iba.Name) != null
				&& mapBankAccountIdsPerAccountCodes.get(iba.Name) != iba.Id) ) {

			iba.Name.addError('The selected ICCS Bank Account Code is in use. Please choose another ICCS Bank Account Code.');
		}
	}
}
