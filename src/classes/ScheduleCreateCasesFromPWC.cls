global class ScheduleCreateCasesFromPWC implements Schedulable  {

	// Dont change the BATCH SCOPE, valid value is 1
	private static final Integer BATCH_SCOPE = 1;
	private String batchName;

	public ScheduleCreateCasesFromPWC(String batchName) {
		this.batchName = batchName;
	}

	global void execute(SchedulableContext SC) {
		BatchCreateCasesFromPWC batch = new BatchCreateCasesFromPWC( this.batchName );
		Database.executeBatch(batch, BATCH_SCOPE);
	}


	// static method to do a single call to this schedule
	public static void launchSchedule( String name ) {
		// set time to now + 1 minute
		DateTime processTime = DateTime.now().addMinutes(1);

		String processName = 'CreateCasesFromPWC_' + processTime.format('yyyyMMdd_HHmmss');
		String scheduleTime = processTime.format('s m H d M ? yyyy');
		String jobID = system.schedule(processName, scheduleTime, new ScheduleCreateCasesFromPWC( name ));
	}

}
