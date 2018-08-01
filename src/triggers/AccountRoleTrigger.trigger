trigger AccountRoleTrigger on Account_Role__c (before insert, after insert, before update, after update, after delete) {

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
	
}