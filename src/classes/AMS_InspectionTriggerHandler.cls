public with sharing class AMS_InspectionTriggerHandler {


	public static void handleBeforeInsert(List<AMS_Inspection__c> inspections) {

	}

	public static void handleBeforeUpdate(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues) {

	}

	public static void handleAfterInsert(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues) {

		processAgency(cleanListWithoutAgencyId(oldValues),cleanListWithoutAgencyId(newValues));
	
	}

	public static void handleAfterUpdate(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues) {

		//FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyUpdate(cleanListWithoutAgencyId(newValues));

		processAgency(cleanListWithoutAgencyId(oldValues),cleanListWithoutAgencyId(newValues));
	
	}

	private static void processAgency(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues){

		AMS_InspectionHelper.setStatusCodeOnAgency(newValues);

        AMS_InspectionHelper.setRecertExpiryDateOnAccount(new Map<Id,AMS_Inspection__c>(oldValues), new Map<Id,AMS_Inspection__c>(newValues) );

	}

	// as this object is used for OSCAR process, sometimes we want inspections without agencies. For that matter, we should remove them from trigger processing
	private static List<AMS_Inspection__c> cleanListWithoutAgencyId(List<AMS_Inspection__c> inspections){

		if(inspections == null)
			return new List<AMS_Inspection__c>();

		List<AMS_Inspection__c> toReturn = new List<AMS_Inspection__c>();

		for(AMS_Inspection__c insp: inspections){
			if(insp.Account__c != null)
				toReturn.add(insp);
		}

		return toReturn;
	}


}