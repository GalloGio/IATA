trigger Training_Contact_Role_Details on Training_Contact_Role_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if (!AMS_TriggerExecutionManager.checkExecution(Training_Contact_Role_Details__c.getSObjectType(), 'Training_Contact_Role_Details')) { return; }

	//Trigger the platform events
	if (Trigger.isInsert || Trigger.isUpdate) {
		if(trigger.isAfter){

			//Trigger the platform events if bypass custom permission is not assigned
			if(!FeatureManagement.checkPermission('Bypass_Platform_Events')){
				PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Training_Contact_Role_Detail__e', 'Training_Contact_Role_Details__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
			}
		}
	}
}