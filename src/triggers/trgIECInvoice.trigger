/**
	* Description: Trigger for the Zuora Invoice object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
trigger trgIECInvoice on Zuora__ZInvoice__c (after insert) {
		if(Trigger.isInsert && Trigger.isAfter) {
		trgHndlrIECInvoice.OnAfterInsert(Trigger.new, Trigger.newMap);
	}
}
