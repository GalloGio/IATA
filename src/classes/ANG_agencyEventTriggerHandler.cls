public class ANG_agencyEventTriggerHandler {

	public List<AMS_Agency_Updates__c> triggerNew = (List<AMS_Agency_Updates__c>) Trigger.new;
	public List<AMS_Agency_Updates__c> triggerOld = (List<AMS_Agency_Updates__c>) Trigger.old;

	public Map<Id, AMS_Agency_Updates__c> newMap = (Map<Id,AMS_Agency_Updates__c>) Trigger.newMap;
	public Map<Id, AMS_Agency_Updates__c> oldMap = (Map<Id,AMS_Agency_Updates__c>) Trigger.oldMap;



	public void onBeforeInsert(){}
	public void onAfterInsert(){
		senRequestToMulesoft();
	}

	public void onBeforeUpdate(){}
	public void onAfterUpdate(){}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}



	private void senRequestToMulesoft(){
		if(!ANG_ConversionHelper.isMigrationTool)
			ANG_IEP_CalloutHelper.invokeCustomImpl(triggerNew);
	}

	


}