global class IFAPBounceEmailScheduler  implements Schedulable{


	public static String CRON_EXP =  '0 0 0-23 * * ?';

	global void execute(SchedulableContext SC)
	{
		runBatchtoUpdateCase();
	}

	 public static void runBatchtoUpdateCase(){

		List<Case> cases = [Select c.BounceEmailCounter__c, c.BounceEmailSubject__c,c.Status, c.Id From Case c Where c.BounceEmailSubject__c !=: null] ;

							System.debug('** runBatchtoUpdateCase '+ cases );

							clsBounceEmailBatch cBatch = new clsBounceEmailBatch();
							cBatch.caseList = cases;
							ID batchprocessid = Database.executeBatch(cBatch,10);

	 }

}
