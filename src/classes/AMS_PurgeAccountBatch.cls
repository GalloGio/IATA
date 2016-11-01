global class AMS_PurgeAccountBatch implements Database.Batchable<sObject>,  Database.Stateful {
	
	global Map<Id, String> errorMap {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}

	String query;
	
	public Set<Id> accountsToPurge;

	global AMS_PurgeAccountBatch(Set<Id> accountsToPurge) {
	
		errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();

		this.accountsToPurge = accountsToPurge;	

		this.query = 'SELECT Id , IATACode__c , Purge_Flag__c from Account where Id in :accountsToPurge and IATACode__c != null and Purge_Flag__c = false';
	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		
		List<Account> accountsToUpdate = new List<Account>();

		for(Account act: scope){

			act.IATACode__c = transformIATACodeintoPurged(act.IATACode__c);
			act.Purge_Flag__c = false;
			//act.Name = act.Name + 'Ltd';

			//accountsToUpdate.add(act);
		}

		if(!accountsToUpdate.isEmpty())
			updateAccounts(accountsToUpdate);
	}
	
	global void finish(Database.BatchableContext BC) {
		
		 //Send an email to the User after your batch completes 
       if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :BC.getJobId()];
            String body = 'Your batch job '
             + 'Purge IATA Codes '
             + 'has finished. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors. Please find the error list attached to the Email.';
 
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
 
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            }


	}

	public static String transformIATACodeintoPurged(String iataCode){

		return iataCode;
	}

	public void updateAccounts(List<Account> accounts){

		List<Database.SaveResult> dsrs = Database.Update(accounts, false);
		
		Integer index = 0;
            
		for(Database.SaveResult dsr : dsrs){
		    if(!dsr.isSuccess()){
		        String errMsg = dsr.getErrors()[0].getMessage();
		        errorMap.put(accounts[index].Id, errMsg);
		        IdToSObjectMap.put(accounts[index].Id, accounts[index]);
		    }

		index++;

		}
	}
	
}