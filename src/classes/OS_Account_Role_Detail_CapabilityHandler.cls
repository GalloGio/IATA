/**
 * @description Handler for Account_Role_Detail_Capability__c trigger (One Source Capabilities Object)
 */
public with sharing class OS_Account_Role_Detail_CapabilityHandler {
	public static void handleBeforeInsert(List<Account_Role_Detail_Capability__c> newValuesList) {
		for (Account_Role_Detail_Capability__c newValues : newValuesList) {
			updateLastModificationFieldIfRequired(newValues, null);
		}
	}

	public static void handleBeforeUpdate(List<Account_Role_Detail_Capability__c> newValuesList, Map<Id, Account_Role_Detail_Capability__c> previousValuesMap) {
		for (Account_Role_Detail_Capability__c newValues : newValuesList) {
			updateLastModificationFieldIfRequired(newValues, previousValuesMap.get(newValues.Id));
		}
	}

	/**
	 * @description             It checks if some picklist fields has been changed, and if true, update the record setting the last modification date field for each them
	 * @param  newValues        The new values for the record
	 * @param  previousValues   The previous values for the record
	 */
	private static void updateLastModificationFieldIfRequired(Account_Role_Detail_Capability__c newValues, Account_Role_Detail_Capability__c previousValues) {
		if (previousValues == null || (newValues.Screeners_Performance__c != previousValues.Screeners_Performance__c)) {
			newValues.Screeners_Performance_Date__c = Date.today();
		}

		if (previousValues == null || (newValues.Quality_Control_Compliance__c != previousValues.Quality_Control_Compliance__c)) {
			newValues.Quality_Control_Compliance_Date__c = Date.today();
		}

		if (previousValues == null || (newValues.Security_Equipment__c != previousValues.Security_Equipment__c)) {
			newValues.Security_Equipment_Date__c = Date.today();
		}

		if (previousValues == null || (newValues.System_Assurance__c != previousValues.System_Assurance__c)) {
			newValues.System_Assurance_Date__c = Date.today();
		}

		if (previousValues == null || (newValues.Contract_Management__c != previousValues.Contract_Management__c)) {
			newValues.Contract_Management_Date__c = Date.today();
		}
	}
}