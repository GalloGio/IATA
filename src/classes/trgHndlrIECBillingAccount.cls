/**
	* Description: Trigger Handler for the Zuora Subscription Product Charge object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class trgHndlrIECBillingAccount {
	public static void OnBeforeInsert(List<Zuora__CustomerAccount__c> newRecords, Map<Id, Zuora__CustomerAccount__c> newRecordsMap) {
		PopulateContactLookup(newRecords);
	}

	public static void OnBeforeUpdate(List<Zuora__CustomerAccount__c> newRecords, Map<Id, Zuora__CustomerAccount__c> newRecordsMap, List<Zuora__CustomerAccount__c> oldRecords, Map<Id, Zuora__CustomerAccount__c> oldRecordsMap) {
		PopulateContactLookup(newRecords);
	}

	private static void PopulateContactLookup(List<Zuora__CustomerAccount__c> lstBillingAccounts) {
		for (Zuora__CustomerAccount__c billingAccount : lstBillingAccounts) {
			if (billingAccount.CRMContactID__c != null)
				billingAccount.Contact__c = Id.valueOf(billingAccount.CRMContactID__c);
		}
	}
}
