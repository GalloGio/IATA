trigger ICG_Contact_Role_Detail on ICG_Contact_Role_Detail__c (after insert,after update, after delete) {
	if (!AMS_TriggerExecutionManager.checkExecution(ICG_Contact_Role_Detail__c.getSObjectType(), 'ICGContactRoleDetailTrigger')) { return; }

	if (trigger.isAfter) {
		if(trigger.isInsert){
			CW_ICGContactRoleDetailHandler.handleAfterInsert(Trigger.new);
		}else if(trigger.isUpdate){
			CW_ICGContactRoleDetailHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
		}else if(trigger.isDelete){
			CW_ICGContactRoleDetailHandler.handleAfterDelete(Trigger.oldMap);
		}
	  
	}
}