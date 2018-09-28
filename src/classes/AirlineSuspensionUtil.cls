public with sharing class AirlineSuspensionUtil {
	/*
	 * Create the child Airline Suspension records for the newly created cases with the Airline Suspension RT
	 */
	public static void CreateAirlineSuspensionRecords (Set<Id> setCaseIds) {
		List<Airline_Suspension__c> lstASRecords = new List<Airline_Suspension__c>();
		for (Id caseId : setCaseIds) {
			Airline_Suspension__c newAS = new Airline_Suspension__c(Case__c = caseId);
			lstASRecords.add(newAS);
		}
		
		try {
			if(!lstASRecords.isEmpty())
				insert lstASRecords;
		} catch (Exception e) {
			system.debug(e.getMessage());
		}
	}
}