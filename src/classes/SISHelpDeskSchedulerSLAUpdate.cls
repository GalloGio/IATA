global class SISHelpDeskSchedulerSLAUpdate implements Schedulable
{
	private static final String Kale_BusinessHours_Name = 'SIS HelpDesk Kale';
	private static final String SIS_BusinessHours_Name = 'SIS Help Desk';
	public static String CRON_EXP_1 =  '0 15 * * * ?';
	public static String CRON_EXP_2 =  '0 30 * * * ?';
	public static String CRON_EXP_3 =  '0 45 * * * ?';
	public static String CRON_EXP_4 =  '0 00 * * * ?';

	public static Integer INTERVAL_TIME = 5;

	global void execute(SchedulableContext SC)
	{
		updateCasesSLA();
	}

	public static void updateCasesSLA()
	{
		// Get SIS HelpDesk and KALE Business Hours
		List<BusinessHours> busiHours = [SELECT Id, Name FROM BusinessHours WHERE Name IN (:Kale_BusinessHours_Name, :SIS_BusinessHours_Name)];
		BusinessHours sisBusinessHours, kaleBusinessHours;
		for (BusinessHours b : busiHours)
		{
			if (b.Name == Kale_BusinessHours_Name)
				kaleBusinessHours = b;
			if (b.Name == SIS_BusinessHours_Name)
				sisBusinessHours = b;
		}
		System.debug('***************************** Business Hours = ' + sisBusinessHours + ' ' + kaleBusinessHours);

		// Get all SIS Cases
		List<Case> sisCasesToUpdate = [SELECT Id, Status, Priority, SIS_SLATracking_LastUpdated__c, createdDate, HasSISCaseBeenClosed__c,
									   SIS_SLATracking__c, Kale_Status__c, Kale_SLATracking_LastUpdated__c, Kale_SLATracking__c
									   FROM Case WHERE  CaseArea__c = 'SIS' AND RecordType.DeveloperName = 'Cases_SIS_Help_Desk'
									   AND Status NOT IN :SISHelpDesk_CaseSLATracking.SISStopStatus];

		// casesUpdated is the returned Updated Cases from "SISHelpDesk_CaseSLATracking.updateSLA"
		System.debug('***************************** List Case To Update = ' + sisCasesToUpdate);
		List<Case> casesUpdated = new List<Case>();
		if (kaleBusinessHours != null && sisBusinessHours != null)
			casesUpdated = SISHelpDesk_CaseSLATracking.updateSLA(sisCasesToUpdate, sisBusinessHours, kaleBusinessHours);
		System.debug('***************************** List Case Updated = ' + sisCasesToUpdate);
		if (casesUpdated.size() != 0)
		{
			SISHelpDesk_SLAUpdate_Batch caseUpdateBatch = new SISHelpDesk_SLAUpdate_Batch();
			if (Test.isRunningTest())
			{
				List<Case> casesUpdatedTest = new List<Case>();
				casesUpdatedTest.add(casesUpdated[0]);
				caseUpdateBatch.casesToBeUpdate  = casesUpdatedTest;
				ID batchProcessId = Database.executeBatch(caseUpdateBatch, 1);
			}
			else
			{
				caseUpdateBatch.casesToBeUpdate  = casesUpdated;
				ID batchProcessId = Database.executeBatch(caseUpdateBatch, 15);
			}
		}
	}
}
