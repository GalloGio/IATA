/*
	Class Name: Part_Online_App_ReqTriggerHandler
	Related Trigger: Part_Online_App_ReqTriggerHandler

	Copyright @Right IT Services

	Purpose: Trigger handler for the Participant_Online_App_Requirement__c object 

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	João Ferreira		2019-01-14   	INITIAL DEVELOPMENT
*/
public class Part_Online_App_ReqTriggerHandler {
	private static Map<String, Schema.SobjectField> objectFieldsMap = Participation_Online_Application__c.sObjectType.getDescribe().fields.getMap();
	
	public static void handleBeforeDelete (List<Participant_Online_App_Requirement__c> junctionToDelete) {
		Set<Id> poaIdSet = new Set<Id>();
		Set<Id> parIdSet = new Set<Id>();

		System.debug('TM junctionToDelete :: ' + junctionToDelete);
		
		List<Participation_Online_Application__c> poaToCleanList = new List<Participation_Online_Application__c>();
		for (Participant_Online_App_Requirement__c acc : junctionToDelete) {
			poaIdSet.add(acc.Participation_Online_Application__c);
			parIdSet.add(acc.Participation_Application_Requirement__c);
		}

		List<Participation_Online_Application__c> poaList = ISSP_AMC_DAO.getCompleteDesignatorCodeList(poaIdSet);
		Map<Id, List<String>> parClearMap = Part_Online_App_ReqTriggerHandler.getparClearMap(parIdSet);
		
		List<String> parFields;
		List<Participation_Online_Application__c> poaUpdateList = new List<Participation_Online_Application__c>();
		Map<Id,Participation_Online_Application__c> poaRecordMap = new Map<Id,Participation_Online_Application__c>();
		Participation_Online_Application__c poaUpdateRecord;
		Schema.DisplayType fieldType;
		if(!parClearMap.isEmpty()) {
			for(Participation_Online_Application__c poaRecord : poaList) {
			    for (Participant_Online_App_Requirement__c poar : junctionToDelete) {
			    	
			    	

			    	if(poar.Participation_Online_Application__c == poaRecord.Id && parClearMap.containsKey(poar.Participation_Application_Requirement__c)){
			    		if(poaRecordMap.containsKey(poar.Participation_Online_Application__c)) {
			    			poaUpdateRecord = poaRecordMap.get(poar.Participation_Online_Application__c);
			    		} else{
			    			poaUpdateRecord = poaRecord;
			    			
			    			poaRecordMap.put(poaUpdateRecord.id,poaUpdateRecord);
			    		}
			    		parFields = parClearMap.get(poar.Participation_Application_Requirement__c);
			    		for (String fieldName : parFields) {
			    			if (Part_Online_App_ReqTriggerHandler.objectFieldsMap.containsKey(fieldName)) {
			    				fieldType = Part_Online_App_ReqTriggerHandler.objectFieldsMap.get(fieldName).getDescribe().getType();
			    				switch on fieldType {
			    					when Boolean {
										poaUpdateRecord.put(fieldName, false);
			    					}
			    					when else {
			    						poaUpdateRecord.put(fieldName, null);
			    					}

			    				}
			    				
		    				} else {
		    					System.debug(LoggingLevel.ERROR, 'Participant_Online_App_ReqTriggerHandler - Delete Junction : Field ' + fieldName + ' does not exist in Participation_Online_Application__c. Please check Participation_Application_Requirement__c.ACLI_Requirement_Fields__c');
		    				}
						}
			    	}
			    }
			}
		}

		
	
		if(!poaRecordMap.isEmpty()) {
			for(Participation_Online_Application__c poaRecord : poaRecordMap.values()) {
				poaUpdateList.add(poaRecord);
			}
			update poaUpdateList;
		}
	}

	private static Map<Id, List<String>> getparClearMap(Set<Id> parIdSet) {
		Map<Id, List<String>> parClearMap = new Map<Id, List<String>>();
		List<Participation_Application_Requirement__c> parList = [
			SELECT 
				Id, ACLI_Requirement_Fields__c
			FROM 
				Participation_Application_Requirement__c
			WHERE 
				Id IN :parIdSet
		];

		List<String> clearFieldsList = new List<String>(); 
		if (!parList.isEmpty()) {
			for (Participation_Application_Requirement__c parRecord : parList) {
				if (parRecord.ACLI_Requirement_Fields__c != null) {
					clearFieldsList = parRecord.ACLI_Requirement_Fields__c.split(';');
					parClearMap.put(parRecord.Id, clearFieldsList);
				}
			}
		}
		return parClearMap;
	}

	public static void handleAfterDelete(List<Participant_Online_App_Requirement__c> junctionToDelete){
		Set<Id> amazonIdToDelete = new Set<Id>();
		List<AmazonFile__c> allAmazon = new List<AmazonFile__c>();

		System.debug('TM junctionToDelete :: ' + junctionToDelete);
		
		for (Participant_Online_App_Requirement__c acc : junctionToDelete) {
			if(acc.AmazonFile__c != null){
	    		amazonIdToDelete.add(acc.AmazonFile__c);
	    	}
		}

		if(!amazonIdToDelete.isEmpty()){
			for(ID amazonid : amazonIdToDelete){
				allAmazon.add(new AmazonFile__c(id=amazonid));
			}
			System.debug('TM allAmazon:: ' + allAmazon);
			if(!allAmazon.isEmpty()){
				delete allAmazon;
			}
		}
	}
}