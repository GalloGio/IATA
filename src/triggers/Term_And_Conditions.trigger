trigger Term_And_Conditions on Term_And_Condition__c (before insert, before update, before delete, after insert, after update, after delete) 
{
    String firstElementRecordTypeName = '';

    //Get record type name of the new Term_And_Condition__c item to be insert/updated
    if (Trigger.new != null && Trigger.new.size() > 0 && Trigger.new[0].RecordTypeId != null){
        firstElementRecordTypeName = RecordTypeSingleton.getInstance().getRecordTypeById('Term_and_Condition__c', trigger.new[0].RecordTypeId).Name;
    }
    
    //If the first element of the list of itens to be insert or update is from a record type "Bypass Trigger Behavior"
    // will BYPASS the existent trigger processing method Term_And_Condition_Dom.triggerHandler
    if (firstElementRecordTypeName != 'Bypass Trigger Behavior'){
        Term_And_Condition_Dom.triggerHandler();
    }
}