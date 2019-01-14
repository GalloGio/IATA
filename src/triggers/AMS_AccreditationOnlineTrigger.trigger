trigger AMS_AccreditationOnlineTrigger on AMS_Pax_Accreditation_Form__c (before insert, before update) {

    if(trigger.isInsert) {
        for(AMS_Pax_Accreditation_Form__c ac : trigger.new)
        	AMS_AccreditationOnlineTriggerHelper.prepopulateAbbreviatedFields(ac, null);

        AMS_AccreditationOnlineTriggerHelper.runPopulateStates(trigger.new, null);
    }
    else if(trigger.isUpdate) {
        for(AMS_Pax_Accreditation_Form__c ac : trigger.new)
        	AMS_AccreditationOnlineTriggerHelper.prepopulateAbbreviatedFields(ac, trigger.oldMap.get(ac.id));

        AMS_AccreditationOnlineTriggerHelper.runPopulateStates(trigger.new, trigger.oldMap);
    }
}