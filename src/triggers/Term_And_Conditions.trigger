trigger Term_And_Conditions on Term_And_Condition__c (before insert, before update, before delete, after insert, after update, after delete) 
{
    String firstElementRecordTypeName = '';
    //get all Term_and_Condition__c record types detail object 
    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Term_and_Condition__c.getRecordTypeInfosById();

    //Get record type name of the new Term_And_Condition__c item to be insert/updated
    if (Trigger.new != null && Trigger.new.size() > 0 && Trigger.new[0].RecordTypeId != null){
        firstElementRecordTypeName = rtMap.get(trigger.new[0].RecordTypeId).Name;
    }
    
    //If the first element of the list of itens to be insert or update is from a record type "Bypass Trigger Behavior"
    // will BYPASS the existent trigger processing method Term_And_Condition_Dom.triggerHandler
    if (firstElementRecordTypeName != 'Bypass Trigger Behavior'){
        Term_And_Condition_Dom.triggerHandler();
    }
}