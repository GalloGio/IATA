/**  
  * Description: Trigger for the Zuora Subscription object
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
trigger trgIECSubscription on Zuora__Subscription__c (after insert, after update) {

	if(Trigger.isInsert && Trigger.isAfter) {
		trgHndlrIECSubscription.OnAfterInsert(Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isAfter) {
		trgHndlrIECSubscription.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}