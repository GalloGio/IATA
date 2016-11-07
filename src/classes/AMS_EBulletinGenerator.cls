global class AMS_EBulletinGenerator implements Schedulable {

	@ReadOnly
	global void execute(SchedulableContext sc) {
		AMS_EBulletinBatch b = new AMS_EBulletinBatch();
		database.executebatch(b);
	}

}