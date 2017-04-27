global class AMS_PurgeAccountBatch implements Database.Batchable<sObject>,  Database.Stateful {
	
	global Map<Id, String> errorMap {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}

    global List<Account> accountsUpdated{get;set;}

	String query;
	
	public Set<Id> accountsToPurge;

	public Map<Id,String> oldIataCodes;

	global AMS_PurgeAccountBatch(Set<Id> accountsToPurge) {
	
		errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();

        accountsUpdated = new List<Account>();

		this.accountsToPurge = accountsToPurge;	

		oldIataCodes = new Map<Id,String>();

		this.query = 'SELECT Id , IATACode__c , Site, Purge_Flag__c from Account where Id in :accountsToPurge and IATACode__c != null and Purge_Flag__c = false';
	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		
		List<Account> accountsToUpdate = new List<Account>();

		for(Account act: scope){

			oldIataCodes.put(act.Id,act.IATACode__c);

			act.IATACode__c = transformIATACodeintoPurged(act.IATACode__c);
			act.Site = transformIATACodeintoPurged(act.site);
			act.Purge_Flag__c = true;
			//act.Name = act.Name + 'Ltd';

			accountsToUpdate.add(act);
		}

		if(!accountsToUpdate.isEmpty()){
			updateAccounts(accountsToUpdate);
			
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		handleErrors(BC);

		updateGDPProducts();


	}

	public void updateGDPProducts(){

		Set<String> iataCodesToPurge = new Set<String>();

		for(Account act: accountsUpdated)
			iataCodesToPurge.add(oldIataCodes.get(act.Id));

		AMS_PurgeGDPIATACodeBatch gDPBatch = new AMS_PurgeGDPIATACodeBatch(iataCodesToPurge);
		
		System.debug('Executing the batch with this scope:'+iataCodesToPurge);

		Database.executeBatch(gDPBatch,200);

	}


	public void handleErrors(Database.BatchableContext BC){

				 //Send an email to the User after your batch completes 
       if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :BC.getJobId()];
            String body = 'Your batch job '
             + 'Purge IATA Codes '
             + 'has finished for Accounts. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors. Please find the error list attached to the Email. You should expect the GDP purge email process shortly after if any error occurr.';
 
            // Creating the CSV file
            String finalstr = 'Id, Name, Error \n';
            String subject = 'Account - Apex Batch Error List';
            String attName = 'Account Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                Account acct = (Account) IdToSObjectMap.get(id);
                string recordString = '"'+id+'","'+acct.Name+'","'+err+'"\n';
                finalstr = finalstr +recordString;
            } 
 
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
 
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
 
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new String[] {a.CreatedBy.Email} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
 			if(!Test.isRunningTest()) {

 				Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
			}

            }

	}

	public static String transformIATACodeintoPurged(String iataCode){

		//Prefix will be PYYMM_

		if(iataCode == null)
			return iataCode;

		Datetime nowDate = Datetime.now();
		
		String formattedDate = nowDate.format('yyMM');

		return 'P' + formattedDate + '_' + iataCode ;
	}

	public void updateAccounts(List<Account> accounts){

		List<Database.SaveResult> dsrs = Database.Update(accounts, false);
		
		Integer index = 0;
            
		for(Database.SaveResult dsr : dsrs){
		    if(!dsr.isSuccess()){
		        String errMsg = dsr.getErrors()[0].getMessage();
		        errorMap.put(accounts[index].Id, errMsg);
		        IdToSObjectMap.put(accounts[index].Id, accounts[index]);
		    }else{
		    	accountsUpdated.add(accounts[index]);
		    }

		index++;

		}
	}
	
}