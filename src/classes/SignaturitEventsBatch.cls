global class SignaturitEventsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    global String query;
    global Integer newEvents;
    
    global SignaturitEventsBatch(){
        this.query = 'SELECT Id,BccAddress__c,Case__c,CcAddress__c,ConnectionReceivedId,EmailMessage__c,FromAddress__c,FromName__c,Name,Signaturit_Certificate_Ids__c,Signaturit_Id__c,Status__c,Subject__c,ToContact__c'
            + ' FROM Tracked_Email__c'
            + ' where (Status__c = \'sent\' OR Status__c = \'email_bounced\' OR Status__c = \'email_processed\') AND Signaturit_Id__c != null';

		newEvents = 0;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

		Map<Id, List<Tracked_Email_Event__c>> eventsMap = new Map<Id, List<Tracked_Email_Event__c>>();

		List<Tracked_Email_Event__c> events = new List<Tracked_Email_Event__c>();

        for(sobject s : scope) {
            Tracked_Email__c te = (Tracked_Email__c)s;
            try {
				List<Tracked_Email_Event__c> trackedEmailEvents = SignaturitRest.updateEventList(te);

            	eventsMap.put(te.Id, trackedEmailEvents);
            	events.addAll(trackedEmailEvents);
            	
            } catch (Exception e) {
                System.debug( 'ERROR SignaturitEventsBatch in ' + te.Id + '  ' + e.getMessage() );
            }
        }
        
        // insert all events
		Database.SaveResult[] lsr = Database.insert(events, false);

		// Process the save results for insert.
		for(Database.SaveResult sr : lsr){
			if(sr.isSuccess()){
				newEvents++;
			}
		}

		List<Tracked_Email__c> emails = [select Id, Email__c, Status__c, Signaturit_Id__c from Tracked_Email__c where Id in: eventsMap.keySet()];
		
		SignaturitRest.updateEmailStatus(emails);
    }

    global void finish(Database.BatchableContext BC){
		// Send an email to the Apex job's submitter.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {UserInfo.getUserEmail()};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Signaturit Event Refresh');
		mail.setPlainTextBody('Missing event(s) retrieved from Signaturit : ' + newEvents);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}