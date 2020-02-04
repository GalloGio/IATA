trigger AMS_AccreditationOnlineTrigger on AMS_Pax_Accreditation_Form__c (before insert, before update) {

	if(trigger.isInsert) {
		for(AMS_Pax_Accreditation_Form__c ac : trigger.new)
			AMS_AccreditationOnlineTriggerHelper.prepopulateAbbreviatedFields(ac, null);

		AMS_AccreditationOnlineTriggerHelper.runPopulateStates(trigger.new, null);
	}
	else if(trigger.isUpdate) {
		Set<Id> citiesIds = new Set<Id>();
		for(AMS_Pax_Accreditation_Form__c ac : trigger.new){
			AMS_AccreditationOnlineTriggerHelper.prepopulateAbbreviatedFields(ac, trigger.oldMap.get(ac.id));
			citiesIds.add(ac.Geoname_Billing_City__c);
            citiesIds.add(ac.Geoname_Shipping_City__c);
		}
		AMS_AccreditationOnlineTriggerHelper.runPopulateStates(trigger.new, trigger.oldMap);
		AMS_AccreditationOnlineTriggerHelper.updateAddressAccordingToLookup(trigger.new, citiesIds, trigger.oldMap);
	}
}
