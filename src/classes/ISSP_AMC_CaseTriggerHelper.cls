public with sharing class ISSP_AMC_CaseTriggerHelper {
	
	public static void isOwnerChanged() {
		Map<Id, Case> oldMap = (Map<Id, Case>)Trigger.oldMap;
		Id airlineRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');

		Map <Id, Id> caseIdsWithNewOwners = new Map <Id, Id>();
		for(Case c : (List<Case>) Trigger.New){
			if(oldMap != null){
				if(oldMap.get(c.Id) != null ){
					if(c.OwnerId != oldMap.get(c.Id).OwnerId ){
						if(c.RecordTypeId == airlineRecordTypeId){
							caseIdsWithNewOwners.put(c.Id, c.OwnerId);
						}
					}
				}
			}
		}

		if(!caseIdsWithNewOwners.isEmpty()){
			List <IATA_Process_Orchestrator__c> orchestrators = new List <IATA_Process_Orchestrator__c>([SELECT Id, Associated_Case__c
																										 FROM 	IATA_Process_Orchestrator__c 
																										 WHERE 	Associated_Case__c IN :caseIdsWithNewOwners.keySet()]);

			if(!orchestrators.isEmpty()){
				for(IATA_Process_Orchestrator__c orchestrator : orchestrators){
					orchestrator.OwnerId = caseIdsWithNewOwners.get(orchestrator.Associated_Case__c);
				}

				update orchestrators;
			}
		}
	}
}