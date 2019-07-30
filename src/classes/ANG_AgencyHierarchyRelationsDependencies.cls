public class ANG_AgencyHierarchyRelationsDependencies extends TriggerAction {

	/**
	 * Method that checks if the relevant fields for this action were changed
	 * @param s the affected record
	 * @return true if the relevant fields for this action were changed and false if not
	 */
	protected override Boolean isRelevant(SObject s) {
        return true;
    }

    	/**
	 * Method to process mass applications 
	 * @param records relevant records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

        Set<Id> hierarchiesToDeleteIds = new Set<Id>();
        Map<Id, AMS_Agencies_Hierarchy__c> oldMap = (Map<Id, AMS_Agencies_Hierarchy__c>) Trigger.oldMap;

        for(sObject r: records){
            hierarchiesToDeleteIds.add(r.id);
        }

        for(AMS_Agencies_relationhip__c rel: [Select Id,Hierarchy__c from AMS_Agencies_relationhip__c where Hierarchy__c in:hierarchiesToDeleteIds]){
            oldMap.get(rel.Hierarchy__c).addError('You cannot remove hierarchy ' + rel.Hierarchy__c + ' because it has relations attached to it.');
        }

    }
}