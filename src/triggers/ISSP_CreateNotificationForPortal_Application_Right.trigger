trigger ISSP_CreateNotificationForPortal_Application_Right on Portal_Application_Right__c (before update, after insert, before insert) {
    
     if(PortalServiceAccessTriggerHandler.privetTrigger) return;
     
     if(trigger.isInsert && trigger.isAfter) {
		PortalServiceAccessTriggerHandler.onAfterInsert(trigger.new, trigger.newMap);
		
		PortalServiceAccessTriggerHandler.SubscribeNewUsersToAllCountryProfiles(trigger.newMap);
	}
		 
     if(trigger.isUpdate && trigger.isBefore) {
        if(!ISSP_CreateNotification.privetTrigger) {
            ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);
        }
     }
     
     //Mconde
     SCIMServProvManager.syncTechProvStatus(trigger.new, trigger.oldMap);
}