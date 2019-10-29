trigger AMS_CountrySpecificAttributeTrigger on AMS_Country_Specific_Attribute__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            AMS_CountrySpecificAttributeHandler.beforeInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
             AMS_CountrySpecificAttributeHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else {}

}