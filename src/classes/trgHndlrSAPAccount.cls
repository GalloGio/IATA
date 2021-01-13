/**
  * Description: Trigger Handler for the SAP Account object
  * Author: Samy Saied, Raymond Afara
  * Version: 1.0
  * History:
  */

public with sharing class trgHndlrSAPAccount {
	public static void OnAfterInsert(List<SAP_Account__c> newRecords, Map<Id, SAP_Account__c> newRecordsMap) {
		List<Id> lstAccountId = new List<Id>();
		List<String> lstSAPId = new List<String>();

		for (SAP_Account__c SAPAcc : newRecords) {
			if (SAPAcc.GDP__c == true){  //SAP_Account_type__c == IECConstants.SAPAccount_InvoiceType_Invoices) {
				lstAccountId.add(SAPAcc.Account__c);
				lstSAPId.add(SAPAcc.SAP_ID__c);
			}
		}

		if (!lstAccountId.isEmpty()) {
			UpdateZuoraBillingAccount(lstAccountId, lstSAPId);
		}
	}

	public static void OnAfterUpdate(List<SAP_Account__c> newRecords, Map<Id, SAP_Account__c> newRecordsMap, List<SAP_Account__c> oldRecords, Map<Id, SAP_Account__c> oldRecordsMap) {
		List<Id> lstAccountId = new List<Id>();
		List<String> lstSAPId = new List<String>();

		for (SAP_Account__c SAPAcc : newRecords) {
			SAP_Account__c oldSAPAcc = oldRecordsMap.get(SAPAcc.Id);
			if (SAPAcc.GDP__c == true  //SAP_Account_type__c == IECConstants.SAPAccount_InvoiceType_Invoices
				&& SAPAcc.SAP_ID__c != oldSAPAcc.SAP_ID__c) {
				lstAccountId.add(SAPAcc.Account__c);
				lstSAPId.add(SAPAcc.SAP_ID__c);
			}
		}

		if (!lstAccountId.isEmpty()) {
			UpdateZuoraBillingAccount(lstAccountId, lstSAPId);
		}
	}

	public static void OnAfterDelete(List<SAP_Account__c> oldRecords, Map<Id, SAP_Account__c> oldRecordsMap) {
		List<Id> lstAccountId = new List<Id>();
		List<String> lstSAPId = new List<String>();

		for (SAP_Account__c SAPAcc : oldRecords) {
			if (SAPAcc.GDP__c == true ){ //SAP_Account_type__c == IECConstants.SAPAccount_InvoiceType_Invoices) {
				lstAccountId.add(SAPAcc.Account__c);
				lstSAPId.add('');
			}
		}

		if (!lstAccountId.isEmpty()) {
			UpdateZuoraBillingAccount(lstAccountId, lstSAPId);
		}
	}

	/**
	 * Updates all related Billing Account with the new SAP Bill-To Id
	 * @param lstAccountId: Holds all Salesforce Accounts that requires to be updated
	 * @param lstSAPId: Holds all related SAP Bill-To Id
	 */
	@future (callout=true)
	private static void UpdateZuoraBillingAccount(List<Id> lstAccountId, List<String> lstSAPId) {
		// Put the parameters into a map for easier access
		Map<Id, String> mapAccIdToSAPId = new Map<Id, String>();

		for (Integer x = 0; x < lstAccountId.size(); x++) {
			mapAccIdToSAPId.put(lstAccountId.get(x), lstSAPId.get(x));
		}

		// Now retrieve all related billing accounts that require updating
		List<Zuora__CustomerAccount__c> lstBillingAccount =
			[SELECT Zuora__Account__c, Zuora__External_Id__c
			FROM Zuora__CustomerAccount__c
			WHERE Zuora__Account__c IN :lstAccountId];

		// Build Zuora Update objects
		try {
			List<Zuora.zObject> lstZAccount = new List<Zuora.zObject>();

			for (Zuora__CustomerAccount__c billAcc : lstBillingAccount) {
				Zuora.zObject zAcc = new Zuora.zObject('Account');

				zAcc.setValue('Id', billAcc.Zuora__External_Id__c);
				zAcc.setValue('SAPBillTo__c', (String.isBlank(mapAccIdToSAPId.get(billAcc.Zuora__Account__c)) ? '' : mapAccIdToSAPId.get(billAcc.Zuora__Account__c)));

				lstZAccount.add(zAcc);
			}

			// perform the update
			List<Zuora.zApi.SaveResult> lstZAccountResult = null;

			if (!Test.isRunningTest())
				lstZAccountResult = IECZuoraHelper.updateApiCall(lstZAccount);
			else
				lstZAccountResult = new List<Zuora.zApi.SaveResult> { IECTestUtil.createSampleSaveResult(true)};//!lstZAccount.isEmpty()) };

			// check for errors
			for (Zuora.zApi.SaveResult result : lstZAccountResult) {
				if (result.Success) {
					system.debug('DEBUG CALLOUT - Account sync success for SaveResult id ' + result.Id);
				}
				else {
					for (Zuora.zObject error: result.errors) {
						throw new IECApplicationException((String)error.getValue('Code') + ': ' + (String)error.getValue('Message'));
					}
				}
			}
		}
		catch (Exception ex) {
			throw new IECApplicationException('Could not sync Account SAP Bill-To Id to Zuora: ' + ex.getMessage());
		}
	}
}
