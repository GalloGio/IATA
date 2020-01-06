/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger is used to prevent the inactivation or deletion of an ICCS Bank Account record that is linked to an active Product Assignment.
 *		If such an assignment exists, an error is raised and the update or delete of the record is blocked.
 */

trigger trgPreventBankAccountInactivation on ICCS_Bank_Account__c (before delete, before update) {

	Boolean ThereAreCasesOfInterest = false;
	for (ICCS_Bank_Account__c pc : Trigger.old) {
		if (Trigger.isDelete || ( Trigger.isUpdate && pc.Status__c == 'Active' && Trigger.newMap.get(pc.Id).Status__c == 'Inactive' ) ) {
			ThereAreCasesOfInterest = true;
		}
	}

	if (ThereAreCasesOfInterest) {
		// Get the count of appearances of the triggering records in Product Assignments
		AggregateResult[] lstNbOfUses = [SELECT ICCS_Bank_Account__c, COUNT(Id)
											FROM Product_Assignment__c
											WHERE ICCS_Bank_Account__c IN :Trigger.oldMap.keySet()
												AND Status__c = 'Active'
											GROUP BY ICCS_Bank_Account__c];

		// Create a map with the results, where the key is the ICCS_Product_Currency__c record Id and the value is its number of uses
		Map<Id, Integer> mapNbOfUsesPerId = new Map<Id, Integer>();
		for (AggregateResult ar : lstNbOfUses) {
			mapNbOfUsesPerId.put( (Id)ar.get('ICCS_Bank_Account__c'), Integer.valueOf(ar.get('expr0')));
		}

		// Check if the records are being deleted or set as inactive, and if so, check that they are not used in active assignments
		for (ICCS_Bank_Account__c pc : Trigger.old) {
			if (mapNbOfUsesPerId.get(pc.Id) != null &&
				mapNbOfUsesPerId.get(pc.Id) > 0 ) {

				if (Trigger.isDelete) {
					pc.addError(' This ICCS Bank Account record is used in ' + mapNbOfUsesPerId.get(pc.Id) + ' active Product Assignment(s) and cannot be inactivated, nor deleted.');
				} else if (Trigger.isUpdate && pc.Status__c == 'Active' && Trigger.newMap.get(pc.Id).Status__c == 'Inactive'){
					ICCS_Bank_Account__c actualRecord = Trigger.newMap.get(pc.Id);
					actualRecord.addError(' This ICCS Bank Account record is used in ' + mapNbOfUsesPerId.get(pc.Id) + ' active Product Assignment(s) and cannot be inactivated, nor deleted.');
				}
			}
		}
	}

}
