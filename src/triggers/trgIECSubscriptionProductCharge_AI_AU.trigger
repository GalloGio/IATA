/**
	* Description: After Trigger for the Zuora Subscription Product Charge object
	* Author: Sonny Leman
	* History: 2015-12-22: created to reconnect/recreate GSS_Subscription_Detail upon zuora__Subsription/zuora_SubscriptionProductCharge change

	*/

trigger trgIECSubscriptionProductCharge_AI_AU on Zuora__SubscriptionProductCharge__c (after insert, after update) {

	// create/update related GSS_Subscription_Detail
	trgHndlrIECSubscriptionToDetail.processRelatedSubscriptionDetailSpc(trigger.new);
} // end of trgIECSubscriptionProductCharge_AI_AU
