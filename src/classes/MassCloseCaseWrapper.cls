global class MassCloseCaseWrapper Implements Schedulable{

	 global list<Id> caseids;


	 global void execute(SchedulableContext sc){
				System.abortJob(sc.getTriggerId() );
				if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')] < 5){
						MassCloseCaseBatch batch = new MassCloseCaseBatch();

						batch.cases = [SELECT  Subject, casenumber, priority FROM Case WHERE Id IN :caseids];
						database.executebatch(batch);


				} else {
					 MassCloseCaseWrapper mccw = new MassCloseCaseWrapper();
					 mccw.caseids = caseids;
					 Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
					 String timeForScheduler = dt.format('s m H d M yyyy');
					 Id schedId = System.Schedule('MassCloseCaseWrapper-'+timeForScheduler,timeForScheduler,mccw);
				}
		}

}
