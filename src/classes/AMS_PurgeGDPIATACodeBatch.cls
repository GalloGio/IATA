global class AMS_PurgeGDPIATACodeBatch implements Database.Batchable<sObject>,  Database.Stateful {
	
	global Map<Id, String> errorMap {get; set;}
    
    global Map<Id, SObject> IdToSObjectMap {get; set;}

	String query;
	
	global Set<String> iATACodesToPurge;

	global AMS_PurgeGDPIATACodeBatch(Set<String> iATACodesToPurge) {
		
		errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();

		this.iATACodesToPurge = iATACodesToPurge;

		this.query = 'Select Id, IATA_Code__c from GDP_Products_Account_View__c where IATA_Code__c in :iATACodesToPurge and Purge_Flag__c = false and IATA_Code__c != null';
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<GDP_Products_Account_View__c> scope) {

   		System.debug('AMS_PurgeGDPIATACodeBatch Scope is ' + scope);
	
		List<GDP_Products_Account_View__c> gdpToUpdate = new List<GDP_Products_Account_View__c>();

		for(GDP_Products_Account_View__c gdp: scope){

			gdp.IATA_Code__c = AMS_PurgeAccountBatch.transformIATACodeintoPurged(gdp.IATA_Code__c);
			gdp.Purge_Flag__c = true;
			gdpToUpdate.add(gdp);

		}

		if(!gdpToUpdate.isEmpty())		
			updateGdp(gdpToUpdate);
	}
	
	global void finish(Database.BatchableContext BC) {
		handleErrors(BC);
	}

	public void updateGdp(List<GDP_Products_Account_View__c> gdpToUpdate){

		List<Database.SaveResult> dsrs = Database.Update(gdpToUpdate, false);
		
		Integer index = 0;
	        
		for(Database.SaveResult dsr : dsrs){
		    if(!dsr.isSuccess()){
		        String errMsg = dsr.getErrors()[0].getMessage();
		        errorMap.put(gdpToUpdate[index].Id, errMsg);
		        IdToSObjectMap.put(gdpToUpdate[index].Id, gdpToUpdate[index]);
		    }

		index++;

		}
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
             + 'has finished. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors. Please find the error list attached to the Email.';
 
            // Creating the CSV file
            String finalstr = 'Id, Name, Error \n';
            String subject = 'GDP_Products_Account_View__c - Apex Batch Error List';
            String attName = 'GDP_Products_Account_View__c Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                GDP_Products_Account_View__c acct = (GDP_Products_Account_View__c) IdToSObjectMap.get(id);
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
 
 			if(!Test.isRunningTest()){
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            }
           }

	}
	
}