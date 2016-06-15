trigger AMS_InspectionTrigger on AMS_Inspection__c (before insert, before update, after insert, after update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Inspection__c.getSObjectType(), 'AMS_InspectionTrigger')) { return; }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate)
            AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);

        AMS_InspectionHelper.setStatusCodeOnAgency(Trigger.new);
    	AMS_InspectionHelper.setRecertExpiryDateOnAccount(Trigger.oldMap, Trigger.newMap);
    }
/*trigger AMS_InspectionTrigger on AMS_Inspection__c (after update) {
	if(Trigger.isAfter)
        if(Trigger.isUpdate)
            AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);*/
/*
    list<AMS_Appointment__c> checkAgencies = new list<AMS_Appointment__c>();
    
    if(Trigger.isInsert){
        for(AMS_Appointment__c ap : trigger.new){
            if(ap.Agency__c!=null)
                checkAgencies.add(ap);
        }
    
    }else if(Trigger.isUpdate){
        for(AMS_Appointment__c ap : trigger.new){
            if(ap.Agency__c!=null && trigger.oldMap.get(ap.Id).Agency__c != ap.Agency__c )
                checkAgencies.add(ap);
        }
    }

    if(checkAgencies.size()>0)
        AMS_AppointmentHelper.EnsureMax1ManagerPerAgency(checkAgencies);*/
}