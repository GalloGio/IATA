/**
  * Description: Trigger for the IECAddress__c object of the IEC project
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
trigger trgIECAddress on IECAddress__c (after update) {

	/* Commented by Samy Saied (2016-02-29) for using the new Location model instead of only iecaddress
	if(Trigger.isInsert && Trigger.isBefore) {
		//trgHndlrIECAddress.OnBeforeInsert(Trigger.new);
	}
	else */
	if(Trigger.isUpdate && Trigger.isAfter) {
		//On demand test run
		//if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger IECAddress') != 1) return;
		if (Utility.getNumericSetting('Stop Trigger:IECAddress') == 1) return;

		trgHndlrIECAddress.OnAfterUpdate(Trigger.new, Trigger.newMap);
	}
}
