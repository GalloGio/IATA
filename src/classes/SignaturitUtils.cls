public with sharing class SignaturitUtils {
    
    public static String pStyle = '<style>p{margin-top:0px; margin-bottom:0px;}</style>';
    public static String pStyleShort = 'p{margin-top:0px; margin-bottom:0px;}';
    
    public static Integer attachmentsSizeLimit = 1024 * 1024 * 4;
    public static Integer attachmentsNumberLimit = 30;
    
    public static List<Tracked_Email__c> createTrackedEmails(List<Case> scope, String templateName, String fromName, String fromAddress, String reason){
        EmailTemplate template = [select Id from EmailTemplate where DeveloperName = :templateName limit 1];

        List<Attachment> templateAttachments = [select Body, Name from Attachment where ParentId =: template.Id];

        List<SignaturitRest.DummyEmail> dummyEmails = new List<SignaturitRest.DummyEmail>();
        for(Case cse : scope){
            dummyEmails.add(new SignaturitRest.DummyEmail(template, cse, cse.ContactId));
        }

        List<Tracked_Email__c> emails = SignaturitRest.sendDummyEmail(dummyEmails);
        for(Tracked_Email__c email : emails){
            email.FromName__c = fromName;
            email.FromAddress__c = fromAddress;
            email.Status__c = SignaturitRestEvents.SENT;
            email.Has_Attachment__c = templateAttachments.size() > 0;
            if(email.TextBody__c == null || email.TextBody__c == ''){
	            email.TextBody__c = email.TextBody__c = (email.Html_Body__c != null? email.Html_Body__c.replaceAll('</p>', '</p><br/>').stripHtmlTags() : '');
            }
            if(reason != null){
            	email.Reason__c = reason;
            }
        }

        insert emails;
       
        // create attachments if there are any in the Visualforce Email Template
        List<Attachment> attachments = new List<Attachment>();

        for(Attachment a : templateAttachments){
            for(Tracked_email__c email : emails){
                Attachment attachment = new Attachment(
					OwnerId = UserInfo.getUserId(),
                	ParentId = email.Id,
                	IsPrivate = false,
                	Body = a.Body,
                	Name = a.Name);
                
                attachments.add(attachment);
            }
        }
    
        insert attachments;
        
        // We can't return the emails list directly, because we need to have the contact name and email now (in the execute method of the batch)
        // to avoid a new query on Contact later in the finalize method of the batch
        List<Id> emailsId = new List<Id>();
        for(Tracked_Email__c email : emails){
            emailsId.add(email.Id);
        }

        return [select Id, Name, FromAddress__c, ToContact__r.Name, ToContact__r.Email, Case__c, Case__r.Status, Case__r.FA_Letter_Sent__c, Case__r.FS_Letter_Sent__c, Html_Body__c, TextBody__c, AdditionalTo__c, CcAddress__c, BccAddress__c, Subject__c, FromName__c, Reason__c, OwnerId,Status__c, Email__c, Case__r.Id, Case__r.CaseNumber, Case__r.Case_Thread_ID__c from Tracked_Email__c where Id in: emailsId];
    }
    
    public static void sendTrackedEmails(List<Tracked_Email__c> trackedEmails){
        List<Tracked_Email_Certificate__c> certificates = new List<Tracked_Email_Certificate__c>();
        List<Case> casesToUpdate = new List<Case>();
        Id ownerId = trackedEmails[0].OwnerId;
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        for(Tracked_Email__c trackedEmail : trackedEmails){
        	String failureMessage = '';
        	String recipients = '<b>to</b><br/>' + trackedEmail.Email__c;
        	if(trackedEmail.CcAddress__c != null && trackedEmail.CcAddress__c != ''){
        		recipients += '<br/><br/><b>cc</b><br/>' + trackedEmail.CcAddress__c;
        	}
        	if(trackedEmail.BccAddress__c != null && trackedEmail.BccAddress__c != ''){
        		recipients += '<br/><br/><b>bcc</b><br/>' + trackedEmail.BccAddress__c;
        	}
        	try{
	            // Send the email with signaturit       
    	        SignaturitRest.MailInfoResponse response = SignaturitRest.sendMail(trackedEmail);
            
            	// case 1 : no response
            	if (response == null) {
					trackedEmail.Status__c = 'Failed';
					failureMessage = '<tr><td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Id + '">' + trackedEmail.Name + '</a></td>'
		           					+ '<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Case__r.Id + '">' + trackedEmail.Case__r.CaseNumber + '</a></td>'
									+ '<td>' + trackedEmail.Subject__c + '</td>'
				                    + '<td>' + recipients + '</td>'
		           					+ '<td>No response from Signaturit server</td></tr>';
	            }
            	// case 2 : success
            	else if(response.Id != null){
	                trackedEmail.Signaturit_Id__c = response.id;
	    			trackedEmail.Status__c = SignaturitRestEvents.SENT;
	                
	                // Update the case if email reason is FA or FS request
	    			if(trackedEmail.Reason__c == 'FA'){
	    				casesToUpdate.add(new Case(Id = trackedEmail.Case__c, FA_Letter_Sent__c = true, Status = 'Agent Notified (Email)'));
	    			}
					else if(trackedEmail.Reason__c == 'FS'){
	    				casesToUpdate.add(new Case(Id = trackedEmail.Case__c, FS_Letter_Sent__c = true, Status = 'Financial Security Requested'));
	    			}
	
	                certificates.addAll(SignaturitUtils.getCertificatesFromResponse(trackedEmail.Id, response));
            	}
            	// case 3 : Signaturit error
	            else{
					trackedEmail.Status__c = 'Failed';
					failureMessage = '<tr><td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Id + '">' + trackedEmail.Name + '</a></td>' 
		           					+ '<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Case__r.Id + '">' + trackedEmail.Case__r.CaseNumber + '</a></td>'
									+ '<td>' + trackedEmail.Subject__c + '</td>'
				                    + '<td>' + recipients + '</td>'
		           					+ '<td>' + response.responseBody + '</td>';
	            }
        	}catch ( Exception e) {
				trackedEmail.Status__c = 'Failed';
				failureMessage = '<tr><td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Id + '">' + trackedEmail.Name + '</a></td>'
								+ '<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Case__r.Id + '">' + trackedEmail.Case__r.CaseNumber + '</a></td>'
								+ '<td>' + trackedEmail.Subject__c + '</td>'
			                    + '<td>' + recipients + '</td>'
								+ '<td>' + e.getMessage() + '</td></tr>';
	        }
	        
	        // send an email to the sender if any error occured
	        if(failureMessage != ''){
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setToAddresses(new List<String>{trackedEmail.FromAddress__c});
				message.setSubject('Tracked Email sending failure : ' + trackedEmail.Subject__c);

				OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
				if ( owea.size() > 0 ) {
					message.setOrgWideEmailAddressId(owea.get(0).Id);
				}

				String body = '<html><head><style>table {border-spacing:0;} th,td{border: 1px solid black;text-align: left;padding: 5px;}</style></head>'
								+ '<body>Unfortunately, the following error occurred when trying to send your tracked email:<br/><br/>'
								+ '<table><tr style="font-weight:bold"><th>Tracked Email</th><th>Case Number</th><th>Subject</th><th>Recipients</th><th>Error</th></tr>'
                    			+ failureMessage
								+ '</table><br/><br/>' + trackedEmail.Case__r.Case_Thread_ID__c + '</body></html>';
				
				message.setHtmlBody(body);
			
				messages.add(message);
	        }	        
        }

		if(!messages.isEmpty()){
			Messaging.sendEmail(messages);
		}
        
        update trackedEmails;
        update casesToUpdate;
        insert certificates;
    }
    
    public static List<Tracked_Email_Certificate__c> getCertificatesFromResponse(Id emailId, SignaturitRest.MailInfoResponse response){
        List<Tracked_Email_Certificate__c> certificates = new List<Tracked_Email_Certificate__c>();

        for(String certificateId : response.getCertificateIds()){
            certificates.add(new Tracked_Email_Certificate__c(Name = certificateId, Tracked_Email__c = emailId));
        }

        return certificates;
    }
}