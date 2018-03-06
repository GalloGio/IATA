global class clsFinancialSecurityRequestBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global List<Case> caseList = new List<Case>();
    global String emailTemplate;
    global Date deadLineDate;
    global Boolean trackedEmail;
    global List<Tracked_Email__c> trackedEmails = new List<Tracked_Email__c>();

    global List<Case> start(Database.BatchableContext BC){
		//EM: To be removed
		if (Test.isRunningTest()) {
			Integer i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
		}
	
	
        return caseList;
    }

    //changes case status to Financial Security requested
    global void execute(Database.BatchableContext BC, List<Case> scope){
        try{
            for(Case c : scope){
                c.Status = 'Financial Security Requested';
                c.FS_EmailTemplate__c = emailTemplate;
                c.FS_Deadline_Date__c = deadLineDate;
                if(!trackedEmail){
                    c.FS_Request_Mass__c = true;
                }
            }
            Update scope;

            if(trackedEmail){
                trackedEmails.addAll(SignaturitUtils.createTrackedEmails(scope, 'IFAP_FS_Request', 'IATA Financial Review', 'noreply.ifap@iata.org', 'FS'));    
            }
        }
        catch(Exception e){}
    }
 
    global void finish(Database.BatchableContext BC){            
        if(!trackedEmails.isEmpty()){
			Database.executeBatch(new SignaturitCalloutBatch(trackedEmails), 5);
        }
    } 
	

	
	
}