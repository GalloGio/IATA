global class AMS_HierarchyAnalyserBatch implements Database.Batchable<sObject>, Database.Stateful {

	String query;

	public final Set<Id> parentsIds;
	public Map<Id, Id> accountHierarchies;

	public Map<Id, Id> childHierarchies;
	public Set<Id> hierarchiesToDelete;

	global AMS_HierarchyAnalyserBatch(Map<Id, Id> accountHierarchies) {
		this.parentsIds = accountHierarchies.keySet();
		this.accountHierarchies = accountHierarchies;

		childHierarchies = new Map<Id, Id>();
		hierarchiesToDelete = new Set<Id>();

		this.query = 'SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c WHERE Parent_Account__c IN :parentsIds';

		System.debug(loggingLevel.Debug, '____ [cls AMS_HierarchyAnalyserBatch - constructor] parentsIds - ' + parentsIds);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	 	global void execute(Database.BatchableContext BC, List<AMS_Agencies_relationhip__c> scope) {

	 		List<AMS_Agencies_relationhip__c> relsToUpdate = new List<AMS_Agencies_relationhip__c>();

		for(AMS_Agencies_relationhip__c rel : scope){

			Id parentHierarchy = accountHierarchies.get(rel.Parent_Account__c);

			if(rel.Hierarchy__c != parentHierarchy){
				hierarchiesToDelete.add(rel.Hierarchy__c);

				rel.Hierarchy__c = parentHierarchy;
				relsToUpdate.add(rel);
			}
			childHierarchies.put(rel.Child_Account__c, rel.Hierarchy__c);
		}

		if(!relsToUpdate.isEmpty()) update relsToUpdate;
	}

	global void finish(Database.BatchableContext BC) {
		if(!childHierarchies.isEmpty()) Database.executeBatch(new AMS_HierarchyAnalyserBatch(childHierarchies));

		try {
			if(!hierarchiesToDelete.isEmpty()){
				List<AMS_Agencies_Hierarchy__c > deleteList = new List<AMS_Agencies_Hierarchy__c >();

				for(Id hierarchyId : hierarchiesToDelete) deleteList.add(new AMS_Agencies_Hierarchy__c ( Id = hierarchyId));

				//delete deleteList;
			}
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls AMS_HierarchyAnalyserBatch - finish] ***Error deleting hierarchies');
			System.debug(loggingLevel.ERROR, '____ [cls AMS_HierarchyAnalyserBatch - finish] hierarchiesToDelete.size() - ' + hierarchiesToDelete.size());
			System.debug(loggingLevel.ERROR, '____ [cls AMS_HierarchyAnalyserBatch - finish] hierarchiesToDelete - ' + hierarchiesToDelete);
		}
	}

}
