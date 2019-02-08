public with sharing class AMS_InspectionTriggerHandler {

	/*AMSU-161 - begin*/
	public static void handleBeforeInsert(List<AMS_Inspection__c> newValues) {
		AMS_InspectionHelper.processGSA_GSSA_HASLagency(newValues);
	}
	/*AMSU-161 - end*/

	public static void handleAfterInsert(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues) {

		processAgency(cleanListWithoutAgencyId(oldValues),cleanListWithoutAgencyId(newValues));
		enforce1To1RelationshipAppointmentMSO();
		AMS_InspectionHelper.createTerritoryForAppointments(newValues); //AMSU-188
	
	}

	public static void handleAfterUpdate(List<AMS_Inspection__c> oldValues,List<AMS_Inspection__c> newValues) {

		//FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyUpdate(cleanListWithoutAgencyId(newValues));

		processAgency(cleanListWithoutAgencyId(oldValues),cleanListWithoutAgencyId(newValues));
		enforce1To1RelationshipAppointmentMSO();
	
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

	private static void enforce1To1RelationshipAppointmentMSO(){

		Set<Id> appointmentAgencies = new Set<Id>();
		Map<Id, Integer> appointmentsPerAccount = new Map<Id, Integer>();

		for(AMS_Inspection__c app: (List<AMS_Inspection__c>)Trigger.New){
			if(app.Account__c != null)
				appointmentAgencies.add(app.Account__c);
		}

		List<AMS_Inspection__c> allAppointments = new List<AMS_Inspection__c>([SELECT Id, Account__c FROM AMS_Inspection__c WHERE Account__c IN :appointmentAgencies AND Account__r.Category__c = 'MSO Member Sales Office']);

		for(AMS_Inspection__c app: allAppointments){
			if(app.Account__c!=null){
				if(!appointmentsPerAccount.containsKey(app.Account__c))
					appointmentsPerAccount.put(app.Account__c, 0);

				Integer nAppointments = appointmentsPerAccount.get(app.Account__c) + 1;
				if(nAppointments > 1)
					throw new AMS_ApplicationException('##An MSO Agency can only have 1 Appointment##');

				appointmentsPerAccount.put(app.Account__c, nAppointments);
			}
		}
	}


}