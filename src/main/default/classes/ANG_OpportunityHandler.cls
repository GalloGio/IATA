public class ANG_OpportunityHandler {
	
	public static void updateOscarIfOfferIdInserted(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		List<Id> opportunitiesToProcess = getGdiOpportunitiesAfterSettingOfferId(oldMap, newMap);
		
		for (Id opId : opportunitiesToProcess)
			updateOscarEndorsementRequest(opId);
	}
	
	private static List<Id> getGdiOpportunitiesAfterSettingOfferId(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		List<Id> opportunitiesToProcess = new List<Id>();
		
		String gdiRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity');
		
		for (Opportunity op : newMap.values()) {
			String newValue = op.GDI_Offer_Id__c;
			String oldValue = op.Id != null && oldMap != null && oldMap.containsKey(op.Id)
				? oldMap.get(op.Id).GDI_Offer_Id__c
				: null;
			
			// check GDI type
			if (op.RecordTypeId == null || op.RecordTypeId != gdiRecordTypeId)
				continue;
			
			if (String.isNotBlank(newValue) && newValue != oldValue)
				opportunitiesToProcess.add(op.Id);
		}

		List<Id> oscars = new List<Id>();
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
	
	@future(callout=true)
	private static void updateOscarEndorsementRequest(Id oscarId) {
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = oscarId, Endorsement_Requested__c = true);
		update oscar;
	}
}