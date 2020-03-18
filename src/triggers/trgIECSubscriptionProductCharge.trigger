/**
	* Description: Trigger for the Zuora Subscription Product Charge object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
trigger trgIECSubscriptionProductCharge on Zuora__SubscriptionProductCharge__c (before insert, before update) {
		if(Trigger.isInsert && Trigger.isBefore) {
		trgHndlrIECSubscriptionProductCharge.OnBeforeInsert(Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		trgHndlrIECSubscriptionProductCharge.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}
