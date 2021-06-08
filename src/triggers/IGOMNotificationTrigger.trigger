trigger IGOMNotificationTrigger on IGOM_Contact_Role_Procedure_Compliance__c (after insert)
{
	IGOMNotificationHandler notificationHandler = new IGOMNotificationHandler();
	if (Trigger.isAfter && Trigger.isInsert) {
		notificationHandler.afterInsert(Trigger.new);
	}
	notificationHandler.andFinally();
}