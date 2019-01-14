global class OSCARstatusBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		OSCARstatusBatch batch = new OSCARstatusBatch();
        Database.executeBatch(batch, 1);
	}
}
