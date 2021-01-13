public class ANG_OpportunityHandler {
	
	public static void updateOscarIfOfferIdInserted(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		Set<Id> opportunitiesToProcess = getGdiOpportunitiesAfterSettingOfferId(oldMap, newMap);
		updateOscarEndorsementRequest(opportunitiesToProcess);
	}
	
	private static Set<Id> getGdiOpportunitiesAfterSettingOfferId(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		Set<Id> opportunitiesToProcess = new Set<Id>();
		
		for (Opportunity op : newMap.values()) {
			String newValue = op.GDI_Offer_Id__c;
			String oldValue = op.Id != null && oldMap != null && oldMap.containsKey(op.Id)
				? oldMap.get(op.Id).GDI_Offer_Id__c
				: null;
			
			// check GDI type
			if (op.RecordTypeId == null || op.RecordTypeId != AMS_Utils.RECTYPE_GDI_FS)
				continue;
			
			if (String.isNotBlank(newValue) && newValue != oldValue) // GDI offer id changed value
				opportunitiesToProcess.add(op.Id);
		}

		Set<Id> oscars = new Set<Id>();
		if (opportunitiesToProcess.isEmpty())
			return oscars;

		for (Opportunity opp : [SELECT Id, Account.Status__c, Related_Oscar__c, Related_Oscar__r.Process__c, Related_Oscar__r.Endorsement_Requested__c
								FROM Opportunity
								WHERE Id IN :opportunitiesToProcess])
		{
			if (opp.Related_Oscar__c == null || opp.Related_Oscar__r.Process__c != AMS_Utils.NGGDI)
				continue;
			if (opp.Related_Oscar__r.Endorsement_Requested__c) // should be "false"
				continue;
			if (opp.Account.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING)
				continue;
			oscars.add(opp.Related_Oscar__c);
		}

		return oscars;
	}
	
	private static void updateOscarEndorsementRequest(Set<Id> oscarIds) {
		if (oscarIds.isEmpty())
			return;

		List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();
		for (Id oId : oscarIds)
			oscarsToUpdate.add(new AMS_OSCAR__c(Id = oId, Endorsement_Requested__c = true));
		update oscarsToUpdate;
	}
}