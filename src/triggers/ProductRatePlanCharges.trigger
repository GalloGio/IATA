/****************************************************************************************************
	Created by David D 2015-09-22
		Trigger handling all events on zqu__ProductRatePlanCharge__c object
****************************************************************************************************/
trigger ProductRatePlanCharges on zqu__ProductRatePlanCharge__c (after delete, after insert, after update, before delete, before insert, before update)
{
	if (!Test.isRunningTest()) {
		ProductRatePlanCharge_Dom.triggerHandler();
	}
}
