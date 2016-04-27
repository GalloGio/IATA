/**  
  * Description: Trigger for the IECAddress__c object of the IEC project
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
trigger trgIECAddress on IECAddress__c (before insert, after update) {

	if(Trigger.isInsert && Trigger.isBefore) {
		trgHndlrIECAddress.OnBeforeInsert(Trigger.new);
	}
	else if(Trigger.isUpdate && Trigger.isAfter) {
		trgHndlrIECAddress.OnAfterUpdate(Trigger.new, Trigger.newMap);
	}
}