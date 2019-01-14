global class FinancialSecurityExpiredBatchAP implements Database.Batchable<sObject> {

	global List<Financial_Security__c> start(Database.BatchableContext BC) {
				List<Financial_Security__c> fslist = [SELECT Id, Security_Status__c FROM Financial_Security__c 
											WHERE Unlimited_Security__c = False 
											AND Security_Status__c in ('Not Active yet','Active','Close to Expiry Date')
											AND Region__c in ('Asia & Pacific','China & North Asia')
		                                    AND Expiry_Date__c <= today];
		return fslist;
	}

	global void execute(Database.BatchableContext BC, List<Financial_Security__c> scope) {

		for (Financial_Security__c fs : scope) {
			fs.Security_Status__c = 'Expired';
		}
		//update scope;
		List<Database.SaveResult> sr = Database.update(scope, false);
	}

	global void finish(Database.BatchableContext BC) {

		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
		// Query the AsyncApexJob object to retrieve the current job's information.
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new String[] {a.CreatedBy.Email};
		List<FSBatch_Alert__c> fsb = [SELECT Email__c from FSBatch_Alert__c];		
		
		for (FSBatch_Alert__c fs : fsb){
				//toAddresses.add(fs.Email__c);
				}		

		mail.setToAddresses(toAddresses);
		mail.setSubject('FinancialSecurityExpiredBatchAP ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}