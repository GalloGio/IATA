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

	// TODO: add record type check
	if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
	{
		EF_RelatedRecordsHandler.validateOnlyContractOrBaSelected(Trigger.new);
	}
	if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
	{

		EF_RelatedRecordsHandler.updateHistoryOfRelationshipChanges(Trigger.newMap);
	}


}