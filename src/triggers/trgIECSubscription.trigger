/**
	* Description: Trigger for the Zuora Subscription object
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*   - 20151222: Sonny Leman: add call to trgHndlrIECSubscriptionToDetail in rebuilding/updating GSS_Subscription_Detail
	*   - 20160627: Sonny Leman: add call to processEBCSubscription, to update related Zuora__CustomerAccount
	*
	*/
trigger trgIECSubscription on Zuora__Subscription__c (after insert, after update) {

		if(Trigger.isInsert && Trigger.isAfter) {
				trgHndlrIECSubscription.OnAfterInsert(Trigger.new, Trigger.newMap);
		}
		else if(Trigger.isUpdate && Trigger.isAfter) {
				trgHndlrIECSubscription.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
				trgHndlrIECSubscriptionToDetail.processRelatedSubscriptionDetail(Trigger.newMap);
				trgIECEBC_SubscriptionHandler.processEbcSubscription(Trigger.newMap, Trigger.oldMap);
		}

}
