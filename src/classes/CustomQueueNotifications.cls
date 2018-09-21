public with sharing class CustomQueueNotifications {
	// to prevent the trigger from running twice and sending the notification email twice
	private static boolean isNotificationAlreadySent = false;
    
    	
	/*
     * Sends email notifications when a case is assigned to a queue
     */
    public static void SendEmailNotifications (list<Case> TriggerNew, map<Id,Case> TriggerOldMap, Boolean isInsert, Boolean isUpdate) {
    	list<Case> lstCasesConcerned = new list<Case>();
    	list<Id> lstQueueIds = new list<Id>();
    	
    	// Continue only if the notifications have not already been sent
        if (isNotificationAlreadySent) {
            system.debug(LoggingLevel.error,'################### isNotificationAlreadySent : ' + isNotificationAlreadySent );
            return;
        }
    	
    	for (Case c : TriggerNew) {
    		if (String.valueOf(c.OwnerId).startsWith('00G') && (isInsert || c.OwnerId != TriggerOldMap.get(c.Id).OwnerId)) {
    			lstCasesConcerned.add(c);
    			lstQueueIds.add(c.OwnerId);
    		}
    	}
    	
    	// if there are cases newly assigned to queues, continue
    	if (!lstCasesConcerned.isEmpty()) {
    		// get info on concerned queues
    		map<Id, Group> mapQueuesPerId = new map<Id, Group>([SELECT Id, Name, DeveloperName FROM Group WHERE Id IN :lstQueueIds]);
    		
    		// 
    		//map<String, Queue_Notif_Emails__c> mapNotifSettingsPerSettingName = Queue_Notif_Emails__c.getAll();
    		// get notifications data from the custom setting and create a map of queue notif emails setting per queue name
    		map<String, Queue_Notif_Emails__c> mapNotifSettingsPerQueueName = new map<String, Queue_Notif_Emails__c>();
    		for (Queue_Notif_Emails__c qne : Queue_Notif_Emails__c.getAll().values()) {
    			mapNotifSettingsPerQueueName.put(qne.Queue_Name__c, qne);
    		}
    		
    		// prepare the list of email messages to be sent
    		list<Messaging.SingleEmailMessage> lstEmailsToBeSent = new list<Messaging.SingleEmailMessage>();
    		
    		for (Case c : lstCasesConcerned) {
    			// only continue for cases assigned to a queue that has custom notifications configured
    			
    			if (mapNotifSettingsPerQueueName.get(mapQueuesPerId.get(c.OwnerId).Name) != null) {
    					try {
	    					// prepare the body & subject
	    					String body = Label.Custom_Queue_Notifications_Email_Template;
	    					body = body.replace('{!QueueName}', mapQueuesPerId.get(c.OwnerId).Name);
	    					body = body.replace('{!Case.CaseNumber}', c.CaseNumber);
	    					body = body.replace('{!Case.Reason1__c}', c.Reason1__c != null ? c.Reason1__c : '');
	    					body = body.replace('{!Case.Subject}', c.Subject);
	    					body = body.replace('{!Case.Description}', c.Description != null ? c.Description : '');
	    					body = body.replace('{!Case.Link}', System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id);
	    					
	    					String subject = Label.Custom_Queue_Notifications_Email_Subject;
	    					subject = subject.replace('{!QueueName}', mapQueuesPerId.get(c.OwnerId).Name);
	    					subject = subject.replace('{!Case.CaseNumber}', c.CaseNumber);
	    					
	    					// create the email message 
	    					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			    			email.setToAddresses(mapNotifSettingsPerQueueName.get(mapQueuesPerId.get(c.OwnerId).Name).Email_Adresses__c.split(','));
			    			email.setPlainTextBody(body);
			    			email.setSubject(subject);
			    			lstEmailsToBeSent.add(email);
    					} catch (Exception e) {
    						system.debug(LoggingLevel.error, '################### Error while preparing the notification email : ' + e.getMessage() );
    					}
    			}
    		}
    		
    		// send the notifications 
    		if (!lstEmailsToBeSent.isEmpty()) {
    			Messaging.SendEmailResult [] r = Messaging.sendEmail(lstEmailsToBeSent,false);
    			system.debug(r);
    			
    			isNotificationAlreadySent = true;
    		}
    	}
    }
}