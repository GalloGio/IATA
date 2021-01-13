global class FinancialSecurityRenewalCaseBatch implements Database.Batchable<sObject> {

	global List<Financial_Security__c> start(Database.BatchableContext BC) {

		List<Financial_Security__c> fslist = [SELECT Id, Security_Status__c FROM Financial_Security__c WHERE
		                                      ((Days_to_Expiry_date__c <= 75 AND Account__r.CNS_Agency__c != true) 
		                                      OR (Days_to_Expiry_date__c <= 90 AND Account__r.CNS_Agency__c = true))
		                                      AND Security_Status__c = 'Active' AND Expiry_Date__c != null];
		return fslist;
	}

	global void execute(Database.BatchableContext BC, List<Financial_Security__c> scope) {

		for (Financial_Security__c fs : scope) {
			fs.Security_Status__c = 'Close to Expiry Date';
		}
		//update scope;
		RecordUpdater updater = new RecordUpdater(scope);
    	updater.schedule(System.now().addSeconds(2));
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
		if (toAddresses.size() > 0) {
			for (FSBatch_Alert__c fs : fsb)
				toAddresses.add(fs.Email__c);
		}

		//toAddresses.add(a.CreatedBy.Email);
		//String[] toAddresses = new String[] {a.CreatedBy.Email};

		mail.setToAddresses(toAddresses);
		mail.setSubject('FinancialSecurityRenewalCaseBatch ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}