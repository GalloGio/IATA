global class AMS_HierarchyAnalyser implements Schedulable {

	@ReadOnly
	global void execute(SchedulableContext sc) {

		AMS_HierarchyAnalyserBatch b = new AMS_HierarchyAnalyserBatch(getParentHierarchyIds());
		database.executebatch(b);
	}

	public static Map<Id,Id> getParentHierarchyIds() {

		Set<Id> allIDs = new Set <Id> ();

		for(AMS_Agencies_relationhip__c rel : [SELECT  Child_Account__c from AMS_Agencies_relationhip__c])
		{
			allIDs.add(rel.Child_Account__c);
		}


		Map<Id,Id> parentIDs = new Map <Id,Id> ();

		for(AMS_Agencies_relationhip__c rel : [SELECT  Parent_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c not in :allIDs])
		{
			parentIDs.put(rel.Parent_Account__c,rel.Hierarchy__c);
		}


		return parentIDs;
	}
}
