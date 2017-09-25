/**  
  * Description: Trigger Handler for the SAP Invoice object of the IEC project
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECSAPInvoice {

	public static void OnBeforeInsert (List<IEC_SAP_Invoice__c> newRecords){ // INC295559
		system.debug('trgHndlrIECSAPInvoice - OnBeforeInsert() starting...');
		List<IEC_SAP_Invoice__c> toUpdate = new List<IEC_SAP_Invoice__c>();
		Set<String> invoiceNumber = new Set<String>();
		Map<String,Id> invoiceIdMap = new Map<String,Id>();
		
		for(IEC_SAP_Invoice__c zInvoice : newRecords ){
			if(zInvoice.Name != null){
			 invoiceNumber.add(zInvoice.Name);
			}
		    system.debug(LoggingLevel.ERROR, 'invoiceNumber ' + invoiceNumber);
		}

		if(invoiceNumber.isEmpty() == false){
			for(OrderItem oi : [SELECT Id, Zuora_InvoiceNumber__c, OrderId from OrderItem where Zuora_InvoiceNumber__c IN :invoiceNumber]){
				invoiceIdMap.put(oi.Zuora_InvoiceNumber__c,oi.OrderId);
			}
		}

		system.debug('invoiceIdMap' + invoiceIdMap);

			for(IEC_SAP_Invoice__c iecsap : newRecords){				
				String sapInvoiceNumber = iecsap.Name;
				Id orderId = invoiceIdMap.get(sapInvoiceNumber);

				if(orderId != null)
					iecsap.Order__c = orderId;
					
			}

			
	}


	public static void OnAfterUpdate(List<IEC_SAP_Invoice__c> newRecords, Map<Id, IEC_SAP_Invoice__c> newRecordsMap, List<IEC_SAP_Invoice__c> oldRecords, Map<Id, IEC_SAP_Invoice__c> oldRecordsMap) {
		

		/* 
		 * NOTE: Commented on 2014/07/14 following feedback from David. Will be used in the future when we create inexisting users in SAP, but it's not the case now.
		 * 
		Map<Id, String> mapAccountIdToSAPBillTo = new Map<Id, String>();
		for (IEC_SAP_Invoice__c SAPInv : newRecords) {
			IEC_SAP_Invoice__c oldSAPInv = oldRecordsMap.get(SAPInv.Id);

			if (oldSAPInv.Status__c == IECConstants.IECSAPInvoice_Status_SentToSAP
				&& (SAPInv.Status__c == IECConstants.IECSAPInvoice_Status_SAPPaymentConfirmationReceived
					|| SAPInv.Status__c == IECConstants.IECSAPInvoice_Status_ZuoraReady)
				&& String.isEmpty(SAPInv.Bill_To__c)
				&& !String.isEmpty(SAPInv.SAP_Bill_To_Number__c)
				&& !mapAccountIdToSAPBillTo.containsKey(SAPInv.Account__c)) {
					
				mapAccountIdToSAPBillTo.put(SAPInv.Account__c, SAPInv.SAP_Bill_To_Number__c);
			}
		}
		
		CreateMissingSAPAccounts(mapAccountIdToSAPBillTo);
		*/
	}
	
/* 
 * NOTE: Commented on 2014/07/14 following feedback from David. Will be used in the future when we create inexisting users in SAP, but it's not the case now.
 * 
	private static void CreateMissingSAPAccounts(Map<Id, String> mapAccountIdToSAPBillTo) {

		if (!mapAccountIdToSAPBillTo.isEmpty()) {
			// Determine whether there is existing SAP Accounts first
			Set<Id> setAccountsWithExistingSAPAcc = new Set<Id>();
			for (SAP_Account__c SAPAcc :
				[SELECT Account__c
				FROM SAP_Account__c
				WHERE Account__c IN :mapAccountIdToSAPBillTo.keySet()
					AND SAP_Account_type__c = :IECConstants.SAPAccount_InvoiceType_Invoices]) {
				
				setAccountsWithExistingSAPAcc.add(SAPAcc.Account__c);
			} 
			
			List<SAP_Account__c> lstSAPAcc = new List<SAP_Account__c>(); 
			
			for (Id AccId : mapAccountIdToSAPBillTo.keySet()) {
				// Exclude Accounts that already have SAP Account
				if (!setAccountsWithExistingSAPAcc.contains(AccId)) {
					lstSAPAcc.add(
						new SAP_Account__c (
							Account__c = AccId
							, SAP_Account_type__c = IECConstants.SAPAccount_InvoiceType_Invoices
							, SAP_ID__c = mapAccountIdToSAPBillTo.get(AccId)
						)
					);
				}
			}
			
			if (!lstSAPAcc.isEmpty()) {
				insert lstSAPAcc;
			}
		}
	}
		*/
		
	
	
}