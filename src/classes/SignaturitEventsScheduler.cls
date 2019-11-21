global class SignaturitEventsScheduler implements Schedulable {

	global void execute(SchedulableContext sc) {

		SignaturitEventsBatch b = new SignaturitEventsBatch();
		database.executebatch(b,100);
	}
}