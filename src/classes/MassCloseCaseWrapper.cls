global class MassCloseCaseWrapper Implements Schedulable{

	 global list<Id> caseids;


	 global void execute(SchedulableContext sc){
				System.abortJob(sc.getTriggerId() );
				if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')] < 5 &&
					!Test.isRunningTest()){
						MassCloseCaseBatch batch = new MassCloseCaseBatch();
						batch.cases = [SELECT  Subject, casenumber, priority, RecordType.DeveloperName, Contact.Name, Account.Name, Status FROM Case WHERE Id IN :caseids];
						database.executebatch(batch);
				} else {
					//schedule this same schedulable class again in 30 mins
					MassCloseCaseWrapper mccw = new MassCloseCaseWrapper();
					mccw.caseids = caseids;
					DateTime dt = DateTime.now().addSeconds(1800);
					String timeForScheduler = String.valueOf(dt.second() +' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *');
					Id schedId = System.Schedule('MassCloseCaseWrapper-'+timeForScheduler,timeForScheduler,mccw);
				}
		}

}
