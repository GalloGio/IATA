global class ANG_ConversionBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	global List<ANG_ConversionHelper.HierarchyStructure> structures;
	
	String query;

	global Integer run;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;
	
	global Set<Id> accountsMigrated;

	global ANG_ConversionBatch(List<ANG_ConversionHelper.HierarchyStructure> structuresToMigrate) {
		
		accountsMigrated = new Set<Id>();
		
		structures= structuresToMigrate;

		Integer queryResults = structures.size();

		this.query = 'SELECT Id from Account LIMIT ' + queryResults;
		
		this.run = -1;
		
		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		System.SavePoint sp;
   		Set<Account> accountsMigratedRun = new Set<Account>();

   		try{

   			this.run++;
   			
   			sp = Database.setSavePoint();

			if(Test.isRunningTest()){
				accountsMigratedRun = ANG_ConversionHelper.migrateStructures(new List<ANG_ConversionHelper.HierarchyStructure>(structures));
			}
			else{
				accountsMigratedRun = ANG_ConversionHelper.migrateStructures(new List<ANG_ConversionHelper.HierarchyStructure>{structures.get(this.run)});
			}

			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(structures.get(this.run), run, BC.getJobId(), false, null);
			resultItems.add(item);

		}catch(Exception e){
			
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(structures.get(this.run), run, BC.getJobId(), true, e.getMessage());

			System.debug(item);resultItems.add(item);Database.rollback(sp);throw e;

		}

		if(!accountsMigratedRun.isEmpty()){
			For(Account acct: accountsMigratedRun)
				accountsMigrated.add(acct.Id);
		}


	}
	
	//Finish Method
	global void finish(Database.BatchableContext BC){

		ANG_ConversionHelper.isMigrationTool=true;

		if(!accountsMigrated.isEmpty()){

			ANG_ConversionBatchChangeCodeCreator conversionBatchChangeCodes = new ANG_ConversionBatchChangeCodeCreator(accountsMigrated);
			if(!Test.isRunningTest())
				Database.executeBatch(conversionBatchChangeCodes,1);	
    		else
				Database.executeBatch(conversionBatchChangeCodes,20);	    			
    	}
		 
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

		String toReturnBody = 'The Batch Apex job ('+BC.getJobId()+')processed  '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are'+a.JobItemsProcessed+'\n\n';
		
		toReturnBody+= ':: Errors Found ::'+'\n';

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems)
			if(item.isError)
				toReturnBody+=item+'\n';
		
		toReturnBody+= '\n\n';
		toReturnBody+= ':: Hierarchies Processed ::'+'\n';

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems)
			if(!item.isError)
				toReturnBody+=item+'\n';

		mail.setPlainTextBody(toReturnBody);

		 if(Test.isRunningTest()){
		 	return;
		 }

		Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
  	}


	
}