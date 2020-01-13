/**
	* Description: Trigger for the Contact object for the IEC project
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*/

trigger trgIECContact on Contact (after update) {
	if(Trigger.isUpdate && Trigger.isAfter) {
		trgHndlrIECContact.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}
