trigger ISSP_CreateNotificationForPortal_Application_Right on Portal_Application_Right__c (before update, after update, after insert, before insert, after delete) {
    
    NewGen_PortalRightTriggerHandler newgenHandler = new NewGen_PortalRightTriggerHandler();
    NewGenApp_Custom_Settings__c newgenCS = NewGenApp_Custom_Settings__c.getOrgDefaults();

    if(Trigger.isAfter && Trigger.isUpdate){
        if(newgenCS.Push_Notifications_State__c){
            newgenHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        } 
    } 

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
     
    if(trigger.isUpdate && trigger.isAfter) {
       PortalServiceAccessTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
    }
    
    if(trigger.isDelete && trigger.isAfter) {
       PortalServiceAccessTriggerHandler.onAfterDelete(trigger.old);
    }
     
    if(trigger.isInsert || trigger.isUpdate) {
         //Mconde
         SCIMServProvManager.syncTechProvStatus(trigger.new, trigger.oldMap);
    }
}