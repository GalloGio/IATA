public with sharing class LocalGovernanceMeetingTriggerHelper {
	
	public static void deleteOnlyIfLocalGovernanceIsActive(map<Id, LocalGovernance_Meeting__c> triggerOldMap){
		//list containing master fields
		List<LocalGovernance_Meeting__c> lgm = [Select id, Local_Governance__r.Active__c from LocalGovernance_Meeting__c where id in :triggerOldMap.keySet()];

		for(LocalGovernance_Meeting__c meeting : lgm){
			//Verifies if group is active
		    if (!meeting.Local_Governance__r.Active__c){
		       triggerOldMap.get(meeting.Id).addError('Cannot delete meetings for inactive groups');
		    } 
		}

	}

}