trigger EF_RelatedRecordsTrigger on EF_Related_Records__c (
	before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete
)
{
	Set<Id> efRelationshipRtIds = new Set<Id>();
	Id efRelationshipRtId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Relationship');
	if(efRelationshipRtId != null)
		efRelationshipRtIds.add(efRelationshipRtId);
	
	List<EF_Related_Records__c> efRRList = new List<EF_Related_Records__c>();
	Map<Id, EF_Related_Records__c> efRRMap = new Map<Id, EF_Related_Records__c>();
	if(Trigger.new != null)
	{
		for(EF_Related_Records__c r : Trigger.new)
		{
			if(efRelationshipRtIds.contains(r.RecordTypeId))
			{
				efRRList.add(r);
				if(r.Id != null)
					efRRMap.put(r.Id, r);
			}
		}
	}

	if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
	{
		EF_RelatedRecordsHandler.validateOnlyContractOrBaSelected(efRRList);
	}
	if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
	{
		EF_RelatedRecordsHandler.updateHistoryOfRelationshipChanges(efRRMap);
	}
}