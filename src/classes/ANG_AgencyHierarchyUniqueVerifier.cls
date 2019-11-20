public class ANG_AgencyHierarchyUniqueVerifier extends TriggerAction {

	/**
	 * Method that checks if the relevant fields for this action were changed
	 * @param s the affected record
	 * @return true if the relevant fields for this action were changed and false if not
	 */
	protected override Boolean isRelevant(SObject s) {

		if(Trigger.isInsert){
			return s.get('Main_Account__c') <> null;
		}
		
		if(Trigger.isUpdate){
		
			Map<Id, AMS_Agencies_Hierarchy__c> oldMap = (Map<Id, AMS_Agencies_Hierarchy__c>) Trigger.oldMap;

			return oldMap.get(s.Id).Main_Account__c <> s.get('Main_Account__c') && s.get('Main_Account__c') <> null;
		}

		return false;
	}

		/**
	 * Method to process mass applications 
	 * @param records relevant records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {
		  
		// first understand if there are any duplicates in the list to update.

		Set<Id> mainAccountsInTrigger = new Set<Id>();
		Set<Id> allHierarchiesAnalyzed = new Set<Id>();

		for(AMS_Agencies_Hierarchy__c record: (List<AMS_Agencies_Hierarchy__c>) Trigger.new){

			allHierarchiesAnalyzed.add(record.Id);

			if(record.Main_Account__c  == null)
				continue;

			if(mainAccountsInTrigger.contains(record.Main_Account__c)){
				record.addError('There can be only one Hierarchy with the Main Account ' + record.Main_Account__c);
			}else {
				mainAccountsInTrigger.add(record.Main_Account__c);
			}

		}

		if(mainAccountsInTrigger.isEmpty()) return; // should not happen if we are running execute but ... :)
			
		// now let's look at the database (excluding the trigger context records)

		Map<Id,AMS_Agencies_Hierarchy__c> toAnalyseMap = new Map<Id,AMS_Agencies_Hierarchy__c>();

		for(SObject r:records){
			toAnalyseMap.put((Id) r.get('Main_Account__c'),(AMS_Agencies_Hierarchy__c)r);
		}

		for(AMS_Agencies_Hierarchy__c h : [Select Id, Main_Account__c from AMS_Agencies_Hierarchy__c where Main_Account__c in:mainAccountsInTrigger and Id not in:allHierarchiesAnalyzed]){
			if(toAnalyseMap.get(h.Main_Account__c) <> null){
				toAnalyseMap.get(h.Main_Account__c).addError('There can be only one Hierarchy with the Main Account ' + h.Main_Account__c);
			}
		}
	}
}