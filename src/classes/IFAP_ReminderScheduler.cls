global class IFAP_ReminderScheduler implements Schedulable {
	 global void execute(SchedulableContext SC) {
			IFAP_Reminder_Batch M = new IFAP_Reminder_Batch();
 database.executebatch(M,10);
	 }
}
