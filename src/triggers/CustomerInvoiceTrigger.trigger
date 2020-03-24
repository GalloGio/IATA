trigger CustomerInvoiceTrigger on Customer_Invoice__c (before insert) {

	if(Trigger.isBefore) {
		if (Trigger.isInsert) {
			CustomerInvoiceTriggerHandler.handleBeforeInsert(Trigger.new);
		}
	}
}
