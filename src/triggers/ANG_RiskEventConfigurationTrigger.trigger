trigger ANG_RiskEventConfigurationTrigger on ANG_Risk_Event_Configuration__c (before insert, before update) {

	if(!AMS_TriggerExecutionManager.checkExecution(ANG_Risk_Event_Configuration__c.getSObjectType(), 'ANG_RiskEventConfigurationTrigger')) { return; }

	ANG_RiskEventConfigurationTriggerHandler handler = new ANG_RiskEventConfigurationTriggerHandler();

	//add other validations if necessary (and add on the trigger declaration as well)
	if(Trigger.isBefore && Trigger.isInsert) handler.onBeforeInsert();
	if(Trigger.isBefore && Trigger.isUpdate) handler.onBeforeUpdate();
}