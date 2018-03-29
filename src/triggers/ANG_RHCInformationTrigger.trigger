trigger ANG_RHCInformationTrigger on ANG_RHC_Information__c (before insert, after insert, before update, after update, before delete, after delete) {

	ANG_RHCInformationTriggerHandler handler = new ANG_RHCInformationTriggerHandler();

	NewGen_ANG_RHCInformationTriggerHandler newgenHandler = new NewGen_ANG_RHCInformationTriggerHandler();
	NewGenApp_Custom_Settings__c newgenCS = NewGenApp_Custom_Settings__c.getOrgDefaults();
	
	if(Trigger.isAfter && Trigger.isUpdate){
		handler.onAfterUpdate();
		if(newgenCS.Push_Notifications_State__c){
			newgenHandler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
		}
	} 

	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isAfter && Trigger.isInsert) handler.onAfterInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
	if(Trigger.isBefore && Trigger.isDelete) handler.onBeforeDelete();
	if(Trigger.isAfter && Trigger.isDelete) handler.onAfterDelete();
}