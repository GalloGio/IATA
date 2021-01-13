/**
	* Description: Trigger Handler for the Zuora Payment Invoice object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class trgHndlrIECPaymentInvoice {
	public static void OnAfterInsert(List<Zuora__PaymentInvoice__c> newRecords, Map<Id, Zuora__PaymentInvoice__c> newRecordsMap) {
		FixSAPInvoicePaymentDates(newRecordsMap);
	}

	public static void FixSAPInvoicePaymentDates(Map<Id, Zuora__PaymentInvoice__c> mapPaymentInvoice) {
		Map<String, DateTime> mapInvNumToPmtDate = new Map<String, DateTime>();
		for (Zuora__PaymentInvoice__c zPmtInv :
			[SELECT Zuora__Invoice__r.Name, Zuora__Payment__r.Zuora__EffectiveDate__c
			FROM Zuora__PaymentInvoice__c
			WHERE Id IN :mapPaymentInvoice.keySet()
				AND Zuora__Payment__r.Zuora__PaymentMethod__c like 'Credit Card%'])
			mapInvNumToPmtDate.put(zPmtInv.Zuora__Invoice__r.Name, zPmtInv.Zuora__Payment__r.Zuora__EffectiveDate__c);

		if (mapInvNumToPmtDate.size() > 0) {
			List<IEC_SAP_Invoice__c> lstSAPInv =
				[SELECT Name, Payment_Date__c
				FROM IEC_SAP_Invoice__c
				WHERE Name IN :mapInvNumToPmtDate.keySet()
					AND Payment_Date__c = NULL];

			if (lstSAPInv.size() > 0) {
				for (IEC_SAP_Invoice__c sapInv : lstSAPInv) {
					if (mapInvNumToPmtDate.containsKey(sapInv.Name))
						sapInv.Payment_Date__c = mapInvNumToPmtDate.get(sapInv.Name).date();
				}

				update lstSAPInv;
			}
		}
	}
}
