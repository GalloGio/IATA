/*
 * This trigger fires on every opportunity event and calls the appropriate method from the RCRMUtil class.
 */
trigger OpportunityHandler on Opportunity (after insert, after update, before update) {

	if (Trigger.isInsert && Trigger.isAfter) {

		RCRMUtil.HandleRCRMOpportunityAfterInsert(Trigger.newMap);
		ANG_OpportunityHandler.updateOscarIfOfferIdInserted(Trigger.oldMap, Trigger.newMap);

	} else if (Trigger.isUpdate) { 

		if (Trigger.isBefore) {
			RCRMUtil.HandleRCRMOpportunityBeforeUpdate(Trigger.newMap, Trigger.oldMap);
		} 
		else if (Trigger.isAfter) {
			ANG_OpportunityHandler.updateOscarIfOfferIdInserted(Trigger.oldMap, Trigger.newMap);
		}

	} 

}
