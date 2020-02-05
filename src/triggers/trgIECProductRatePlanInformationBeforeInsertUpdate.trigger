/**
	* Description: Trigger for before Insert/Update for the ProductRatePlanInformation object
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
 */
trigger trgIECProductRatePlanInformationBeforeInsertUpdate on Product_Rate_Plan_Information__c (before insert, before update) {

	if(Trigger.isInsert && Trigger.isBefore) {
		trgIECProductRatePlanInformation.OnBeforeInsert(Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isBefore) {
		trgIECProductRatePlanInformation.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}
