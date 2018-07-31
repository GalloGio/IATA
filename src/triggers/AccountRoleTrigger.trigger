trigger AccountRoleTrigger on Account_Role__c (before insert, after insert, before update, after update, after delete) {

	//AccountRoleHandler handler = new AccountRoleHandler();

	if(trigger.isBefore){
    	if(trigger.isInsert){
    		AccountRoleHandler.updatePaymentProviderStatus(trigger.new, trigger.oldMap);
    		TIP_Utils.SyncAccountRoleOnProduct(trigger.new, null);
    	}
    	
    	if(trigger.isUpdate){
    		AccountRoleHandler.updatePaymentProviderStatus(trigger.new, trigger.oldMap);
    		TIP_Utils.SyncAccountRoleOnProduct(trigger.new, trigger.oldMap);
    	}
    }

	if(trigger.isAfter && trigger.isUpdate) {
		AccountRoleHandler.manageAccountAsPaymentProvider(trigger.new, true);
	}

	if(trigger.isAfter && trigger.isDelete) {
		AccountRoleHandler.manageAccountAsPaymentProvider(trigger.old, false);
	}
	
	

}