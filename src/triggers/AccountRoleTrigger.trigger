trigger AccountRoleTrigger on Account_Role__c (before insert, after insert, before update, after update, after delete) {

	//AccountRoleHandler handler = new AccountRoleHandler();

	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		AccountRoleHandler.updatePaymentProviderStatus(trigger.new, trigger.oldMap);
	}

	if(trigger.isAfter && trigger.isUpdate) {
		AccountRoleHandler.manageAccountAsPaymentProvider(trigger.new, 'Add');
	}

	if(trigger.isAfter && trigger.isDelete) {
		AccountRoleHandler.manageAccountAsPaymentProvider(trigger.old, 'Remove');
	}

}