global class AMS_EBulletinDailySchedule implements Schedulable {

	@ReadOnly
	global void execute(SchedulableContext sc) {
				
		AMS_EBulletinBatch b = new AMS_EBulletinBatch('Daily');
		database.executebatch(b,50);

	}

}