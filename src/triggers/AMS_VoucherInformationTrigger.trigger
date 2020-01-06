trigger AMS_VoucherInformationTrigger on AMS_Voucher_Information__c ( after insert, after update, after undelete,before insert, before update) {

	if(!AMS_TriggerExecutionManager.checkExecution(AMS_Voucher_Information__c.getSObjectType(), 'AMS_VoucherInformationTrigger')) { return; }

	if (Trigger.isAfter && Trigger.isUpdate) {
		AMS_VoucherInformationTriggerHandler.handleAfterUpdate(Trigger.new);
	}

	if (Trigger.isAfter && Trigger.isInsert) {
		AMS_VoucherInformationTriggerHandler.handleAfterInsert(Trigger.new);
	}

	if (Trigger.isAfter && Trigger.isUndelete) {
		AMS_VoucherInformationTriggerHandler.handleAfterUndelete(Trigger.new);
	}

	if (Trigger.isBefore && Trigger.isUpdate) {
		AMS_VoucherInformationTriggerHandler.handleBeforeUpdate(Trigger.new);
	}

	if (Trigger.isBefore && Trigger.isInsert) {
		AMS_VoucherInformationTriggerHandler.handleBeforeInsert(Trigger.new);
	}

}
