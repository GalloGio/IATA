global class ANG_ConversionBatch implements Database.Batchable<sObject> {

	global List<ANG_ConversionHelper.HierarchyStructure> structures;
	
	String query;

	global Integer run;
	
	global ANG_ConversionBatch(List<ANG_ConversionHelper.HierarchyStructure> structuresToMigrate) {
		
		System.debug('Starting ANG_ConversionBatch');

		structures= structuresToMigrate;

		Integer queryResults = structures.size();

		this.query = 'SELECT Id from Account LIMIT ' + queryResults;
		
		this.run = 0;
		
		System.debug('Structures to be migrated:'+queryResults);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		if(Test.isRunningTest()){
			ANG_ConversionHelper.migrateStructures(new List<ANG_ConversionHelper.HierarchyStructure>(structures));
   		}
		else
			ANG_ConversionHelper.migrateStructures(new List<ANG_ConversionHelper.HierarchyStructure>{structures.get(this.run)});

   		this.run++;

	}
	
	//Finish Method
	global void finish(Database.BatchableContext BC){
		 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		//Below code will fetch the job Id
		AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
		System.debug('$$$ Jobid is'+BC.getJobId());

		String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
		String userEmail = activeUser.Email;

		//below code will send an email to User about the status
		mail.setToAddresses( new String[] {userEmail} );
		mail.setSenderDisplayName('Apex Newgen Conversion Batch Processing Module');
		mail.setSubject('Batch Processing '+a.Status);
		mail.setPlainTextBody('The Batch Apex job processed  '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are'+a.JobItemsProcessed);

		 if(Test.isRunningTest()){
		 	return;
		 }

		Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
  	}
	
}