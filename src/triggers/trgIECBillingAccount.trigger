/**
	* Description: Trigger for the Zuora Billing Account object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
trigger trgIECBillingAccount on Zuora__CustomerAccount__c (before insert, before update) {
		if(Trigger.isInsert && Trigger.isBefore) {
		trgHndlrIECBillingAccount.OnBeforeInsert(Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		trgHndlrIECBillingAccount.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}
