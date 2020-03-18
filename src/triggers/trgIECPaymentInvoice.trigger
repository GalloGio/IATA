/**
	* Description: Trigger for the Zuora Payment Invoice object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
trigger trgIECPaymentInvoice on Zuora__PaymentInvoice__c (after insert) {
	if(Trigger.isInsert && Trigger.isAfter) {
		trgHndlrIECPaymentInvoice.OnAfterInsert(Trigger.new, Trigger.newMap);
	}
}
