trigger AccountRoleTrigger on Account_Role__c (before insert, after insert, before update, after update, after delete) {

	if (!AMS_TriggerExecutionManager.checkExecution(Account_Role__c.getSObjectType(), 'AccountRoleTrigger')) { return; }
	
	AccountRoleHandler handler = new AccountRoleHandler();

	if(trigger.isBefore){
		if(trigger.isInsert){
			handler.onBeforeInsert();
			TIP_Utils.SyncAccountRoleOnProduct(trigger.new, null);
		}

		if(trigger.isUpdate){
			handler.onBeforeUpdate();
			TIP_Utils.SyncAccountRoleOnProduct(trigger.new, trigger.oldMap);
		}
	}

	if(trigger.isAfter && trigger.isUpdate) {
		handler.onAfterUpdate();
	}

	if(trigger.isAfter && trigger.isDelete) {
		handler.onAfterDelete();
	}

	//Trigger the platform events if bypass custom permission is not assigned
	if(!FeatureManagement.checkPermission('Bypass_Platform_Events')){
		if(trigger.isAfter){
			if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
				System.enqueueJob(new PlatformEvents_Helper((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountRole__e', 'Account_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete));
			} else {
				PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountRole__e', 'Account_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
			}
		}
	}
}
