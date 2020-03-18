/**
	* Description: Trigger for the Swap Configuration object for the IEC project
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/

trigger trgIECSwapConfiguration on Swap_Configuration__c (before insert, before update) {
	if(Trigger.isInsert && Trigger.isBefore) {
		trgHndlrIECSwapConfiguration.OnBeforeInsert(Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		trgHndlrIECSwapConfiguration.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}
