/*
 * This trigger copies the Product Manager and Alternate Product Manager info to the Opportunity when a new RCRM Product is added to an Opportunity (overwriting not an issue,
 * since the PM is supposed to be the same on the same Opportunity).
 */

trigger RCRMCopyPMandAPMFromOppProductToOpportunity on OpportunityLineItem (after insert) {
	// list of the related OLIs with the product info included
	// only interested in those that have a RCRM product attached >> this means that the opportunity is / will become a RCRM opportunity
	List<OpportunityLineItem> lstOLIs = [SELECT Id, OpportunityId, Product2.Alternate_Product_Manager__c, Product2.Product_Manager_lookup__c, Product2.Family
												FROM OpportunityLineItem
												WHERE Id IN :Trigger.newMap.keyset() AND Product2.RCRM_Product__c = true];

	// list of the relatd opportunity ids
	Set<Id> lstRelatedOpps = new Set<Id>();
	for (OpportunityLineItem oli : lstOLIs) {
		lstRelatedOpps.add(oli.OpportunityId);
	}

	if (!lstRelatedOpps.isEmpty()) {
		// creat a map of the related opportunities per opportunity id
		map<Id, Opportunity> mapOppPerOppId = new map<Id, Opportunity>([SELECT Id, Product_Family__c, RCRM_Product_Manager__c, Alternate_RCRM_Product_Manager__c FROM Opportunity WHERE Id IN :lstRelatedOpps]);

		for (OpportunityLineItem oli : lstOLIs) {
			if (mapOppPerOppId.get(oli.OpportunityId) != null) {
				mapOppPerOppId.get(oli.OpportunityId).RCRM_Product_Manager__c = oli.Product2.Product_Manager_lookup__c;
				mapOppPerOppId.get(oli.OpportunityId).Alternate_RCRM_Product_Manager__c = oli.Product2.Alternate_Product_Manager__c;

				// if the product family is empty, fill it from the OLI - this happens when a RCRM product is added to an opportunity which is not RCRM
				if (mapOppPerOppId.get(oli.OpportunityId).Product_Family__c == null) {
					mapOppPerOppId.get(oli.OpportunityId).Product_Family__c = oli.Product2.Family;
				}
			}
		}

		update mapOppPerOppId.values();
	}


}
