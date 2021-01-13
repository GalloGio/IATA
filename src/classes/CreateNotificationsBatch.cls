global class CreateNotificationsBatch implements Database.Batchable<Notification__c> {

	private List<Notification__c> notificationList;

	global CreateNotificationsBatch(List<Notification__c> notifications) {
		if (notifications == null) notifications = new List<sObject>();
		this.notificationList = notifications;
	}
	global Iterable<Notification__c> start(Database.BatchableContext context){
		return notificationList;
	}
	global void execute(Database.BatchableContext context, List<Notification__c> notifications){
		Database.insert(notifications,false);
	}
	global void finish(Database.BatchableContext context){
	}
}
