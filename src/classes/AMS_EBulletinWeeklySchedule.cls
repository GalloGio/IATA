global class AMS_EBulletinWeeklySchedule implements Schedulable {

	@ReadOnly
	global void execute(SchedulableContext sc) {
		
		AMS_EBulletinBatch b = new AMS_EBulletinBatch('Weekly');
		database.executebatch(b,50);
	}

}