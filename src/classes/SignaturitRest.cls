public with sharing class SignaturitRest {

    public static String ENDPOINT = Label.Signaturit_Endpoint;
    public static String TESTSTRING;

    public static map<String,Signaturit_Events_WS__c> EVENTS_URL = Signaturit_Events_WS__c.getAll();
    

    public class DummyEmail{
        private EmailTemplate template {get;set;}
        private Case cse {get;set;}
        private Id targetObjectId {get;set;}
        
        public DummyEmail(EmailTemplate template, Case cse, Id targetObjectId){
            this.template = template;
            this.cse = cse;
            this.targetObjectId = targetObjectId;
        }
        
        public Case getCase(){
            return cse;
        }
        
        public EmailTemplate getTemplate(){
            return template;
        }

        public Id getTargetObjectId(){
            return targetObjectId;
        }        
    }

    public static List<Tracked_Email__c> sendDummyEmail(List<DummyEmail> emails) {
        List<Tracked_Email__c> trackedEmails = new List<Tracked_Email__c>();
        
        for(DummyEmail email : emails){
            Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
    
            dummyEmailMsg.setTemplateId(email.getTemplate().Id);
            dummyEmailMsg.setSaveAsActivity(false);
            dummyEmailMsg.setToAddresses(new String[]{'dummy@maildummy.org'});
            //dummyEmailMsg.setReplyTo('dummy@maildummy.org');
            dummyEmailMsg.setTargetObjectId(email.targetObjectId);
            dummyEmailMsg.setWhatId(email.cse.Id);

            Savepoint sp = Database.setSavepoint();

            Messaging.sendEmail(new Messaging.SingleEmailMEssage[]{dummyEmailMsg});

            Database.rollback(sp);

            Tracked_Email__c trackedEmail = new Tracked_Email__c();

            trackedEmail.ToContact__c = email.getCase().ContactId;
            trackedEmail.Html_Body__c = dummyEmailMsg.htmlBody;
            trackedEmail.TextBody__c = dummyEmailMsg.PlainTextBody;
            trackedEmail.Subject__c = dummyEmailMsg.subject;
            trackedEmail.Case__c = email.getCase().Id;

            trackedEmails.add(trackedEmail);
        }
        return trackedEmails;
    }
    
    
    public static MailInfoResponse sendMail( Tracked_Email__c trackedEmail) {
        try {
            String boundary = 'WebKitFormBoundary' + String.valueOf(DateTime.now().getTime());

            Signaturit_Events_WS__c url = EVENTS_URL.values().get(0);
            
            String header = '--' + boundary
                        + '\r\nContent-Disposition: form-data; name="events_url"'
                        + '\r\n\r\n' + url.events_url__c;
                        
            if(url.oauth_url__c != null && url.oauth_url__c != ''){
                header += '\r\n--' + boundary
                            +'Content-Disposition: form-data; name="oauth_url"'
                            +'\r\n\r\n'+ url.oauth_url__c;
            }
            
            Integer j = 0;
            if(trackedEmail.ToContact__r.Name != null && trackedEmail.ToContact__r.Email != null){
                header += '\r\n--' + boundary
                            +'Content-Disposition: form-data; name="recipients[to][0][fullname]"'
                            +'\r\n\r\n'+ trackedEmail.ToContact__r.Name
                            +'\r\n--'+boundary
                            +'\r\nContent-Disposition: form-data; name="recipients[to][0][email]"'
                            +'\r\n\r\n' + trackedEmail.ToContact__r.Email;
                j++;
            }
            
            if(trackedEmail.AdditionalTo__c != null && trackedEmail.AdditionalTo__c != ''){
                List<String> additionalTo = trackedEmail.AdditionalTo__c.split(';');
                for(Integer i = 0; i < additionalTo.size(); i++){
                    header += '\r\n--' + boundary
                              + '\r\nContent-Disposition: form-data; name="recipients[to][' + (i+j) + '][email]"'
                              + '\r\n\r\n' + additionalTo.get(i);
                }
            }
            
            if(trackedEmail.CcAddress__c != null && trackedEmail.CcAddress__c != ''){
                List<String> cc = trackedEmail.CcAddress__c.split(';');
                for(Integer i = 0; i < cc.size(); i++){
                    header += '\r\n--' + boundary
                              + '\r\nContent-Disposition: form-data; name="recipients[cc][' + i + '][email]"'
                              + '\r\n\r\n' + cc.get(i);
                }
            }
            
            if(trackedEmail.BccAddress__c != null && trackedEmail.BccAddress__c != ''){
                List<String> bcc = trackedEmail.BccAddress__c.split(';');
                for(Integer i = 0; i < bcc.size(); i++){
                    header += '\r\n--' + boundary
                              + '\r\nContent-Disposition: form-data; name="recipients[bcc][' + i + '][email]"'
                              + '\r\n\r\n' + bcc.get(i);
                }
            }

			String s;

			if(trackedEmail.Html_Body__c.contains(SignaturitUtils.pStyleShort)){
				s = trackedEmail.Html_Body__c.replace(SignaturitUtils.pStyleShort, SignaturitUtils.pStyle);
			}
			else{
				s = trackedEmail.Html_Body__c.replace('<p>', '<p style="margin-top:0px;margin-bottom:0px;">');
			}

            header += '\r\n--' + boundary
                    + '\r\nContent-Disposition: form-data; name="subject"'
                    +'\r\n\r\n' + trackedEmail.Subject__c
                    +'\r\n--'+boundary
                    +'\r\nContent-Disposition: form-data; name="body"'
                    +'\r\n\r\n' + s;

            Integer i = 0;
            for(Attachment attachment : [select Id, Name, Body from Attachment where parentId =: trackedEmail.Id order by BodyLength desc]){
                String name = attachment.Name;
                Blob mybody = attachment.Body;

                attachment.Body = null;
                attachment = null;

                header += '\r\n--' + boundary + '\r\n'
                            + 'Content-Disposition: attachment; name="attachments[' + i++ + ']"; filename="' + Name + '";\nContent-Type: text/plain'
                            + '\r\n--' + boundary
                            + '\r\nContent-Disposition: form-data;'
                            + '\r\n\r\n' + EncodingUtil.base64Encode(mybody);
            }

            header +=  + '\r\n--'+boundary+'--';

            Blob b = Blob.valueOf(header);
            header = null;

            String headerEncoded = EncodingUtil.base64Encode(b);

            Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded);
            headerEncoded = null;

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization','Bearer ' + getToken(trackedEmail) );
            req.setHeader('Content-Type','multipart/form-data; boundary="'+boundary+'"');
            req.setEndpoint( ENDPOINT + 'emails.json');
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);

            HttpResponse res;
            Http http = new Http();
            
            if(!Test.isRunningTest()){
                res = http.send(req);
                JSONParser parser = JSON.createParser(res.getBody());

                System.debug('RESPONSE : ' + res.getBody());
                MailInfoResponse signaturitResponse = (MailInfoResponse)parser.readValueAs(MailInfoResponse.class);
                signaturitResponse.responseBody = res.getBody();
                return signaturitResponse;
            }
            else{
                if(trackedEmail.Subject__c.startsWith('test error sending')){
                    return null;
                }
                
                MailInfoResponse testResponse = new MailInfoResponse();
                testResponse.id = '0';
                CertificateInfoResponse certif = new CertificateInfoResponse();
                certif.id = '2';
                testResponse.certificates = new CertificateInfoResponse[]{certif};
                
                return testResponse;        
            }            
        } catch (Exception e) {
            System.debug('ERROR in SignaturitRest.sendMail(' + trackedEmail + ') : ' + e);
            return null;
        }
    }

    /**
        Get the info related to an email from Signaturit server, it includes the list of events
    **/
    public static MailInfoResponse getMailInfo( Tracked_Email__c trackedEmail) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Authorization','Bearer ' + getToken(trackedEmail) );
            req.setEndpoint( ENDPOINT + 'emails/' + trackedEmail.Signaturit_Id__c + '.json');
            req.setTimeout(120000);

            HttpResponse res;
            Http http = new Http();
            if(!Test.isRunningTest()) res = http.send(req);

            String jsonStr = !Test.isRunningTest() ? res.getBody() : TESTSTRING ;
            System.debug(jsonstr);
            JSONParser parser = JSON.createParser(jsonStr);
            MailInfoResponse signaturitResponse = (MailInfoResponse)parser.readValueAs(MailInfoResponse.class);
            signaturitResponse.responseBody = jsonstr;
            return signaturitResponse;            
        } catch (Exception e) {
            System.debug('ERROR in SignaturitRest.getMailInfo(' + trackedEmail + ') : ' + e);
            return null;
        }
    }

	public static void updateEmailStatus(List<Tracked_Email__c> trackedEmails){
		try{
	        for(Tracked_Email__c trackedEmail : trackedEmails){
	        	if(trackedEmail.Signaturit_Id__c != null && trackedEmail.Signaturit_Id__c != ''){
			    Set<String> mainRecipients = new Set<String>(trackedEmail.Email__c.split(';'));
				
	            // Retrieve all registered events for main recipients
	            List<Tracked_Email_Event__c> mainEvents = [select Recipient_Address__c, Status__c from Tracked_Email_Event__c where Parent__c =: trackedEmail.ID and Recipient_Address__c in : mainRecipients];
	            
	            // this map will contain the current status for each main recipient
	            Map<String,String> statusPerRecipient = new Map<String,String>();
	            
	            for(Tracked_Email_Event__c mainEvent : mainEvents){
	            	String recipient = mainEvent.Recipient_Address__c;
	            	if(!statusPerRecipient.containsKey(recipient)){
	            		statusPerRecipient.put(recipient, mainEvent.Status__c);
	            	}
	            	else{
	            		if(SignaturitRestEvents.RECIPIENT_STATUSES.get(mainEvent.Status__c) > SignaturitRestEvents.RECIPIENT_STATUSES.get(statusPerRecipient.get(recipient))){
	                		statusPerRecipient.put(recipient, mainEvent.Status__c);
	            		}
	            	}
	            }
	
	            String newStatus = SignaturitRestEvents.SENT;
	            for(String status : statusPerRecipient.values()){
					if(SignaturitRestEvents.EMAIL_STATUSES.get(status) > SignaturitRestEvents.EMAIL_STATUSES.get(newStatus)){
						newStatus = status;
					}
	            }
	
	            if(newStatus != trackedEmail.Status__c){
	                trackedEmail.Status__c = newStatus;
	            }
			}
			}
			
			update trackedEmails;
        	
        }catch(Exception e){
            System.debug('SignaturitRestEvents.receiveEvent():' + e);
        }		
	}

    /**
        get the events for a particular email from signaturit and insert them in Salesforce
    **/
    public static List<Tracked_Email_Event__c> updateEventList(Tracked_Email__c trackedEmail) {

		try{

	        MailInfoResponse response = SignaturitRest.getMailInfo(trackedEmail);
	
			List<Tracked_Email_Event__c> eventsToInsert = new List<Tracked_Email_Event__c>();
	
	        for ( CertificateInfoResponse certificate: response.certificates) {
	        	for(EventDataInfoResponse event : certificate.events){
					Tracked_Email_Event__c eventToInsert = new Tracked_Email_Event__c(
			            Parent__c = trackedEmail.Id,
			            Recipient_Address__c = certificate.email,
			            Recipient_Name__c = certificate.name,
	//		            Attachment__c = params.get('certificate[file][name]'),
			            Timestamp__c = Datetime.now(),
			            Status__c = event.type,
			            Event_Unique_Field__c = trackedEmail.Id + '-' + certificate.email + '-' + event.type
			        );
	
					eventsToInsert.add(eventToInsert);        	
	        	}
	        }
	
			return eventsToInsert;
		}
		catch(Exception e){
			return new List<Tracked_Email_Event__c>(); 
		}
    }

    public static String getToken(Tracked_Email__c trackedEmail) {
        try {
            Sender_Tracked_Emails__c te =  Sender_Tracked_Emails__c.getValues(trackedEmail.FromName__c);
            return te.Token__c;
        } catch (Exception e) {
            System.debug('SIGNATURIT SEND MAIL ERROR. Could not get the user token to send an email, user = ' + trackedEmail.FromName__c);
            return '';
        }
    }

    public class MailInfoResponse {
        public String id;
        public String created_at;
        public CertificateInfoResponse[] certificates;
        
        public String responseBody;
        
        public list<String> getCertificateIds() {
            list<String> listIds = new list<String>();
            for (CertificateInfoResponse cert: certificates) {
                listIds.add(cert.Id);
            }
            return listIds;
        }
    }

    public class CertificateInfoResponse {
        public String id;
        public String created_at;
        public EventDataInfoResponse [] events;
        public String email;
        public String name;
        public String status;

        public EventDataInfoResponse last_event;
    }

    public class EventDataInfoResponse {
        //public String date_x;
        public String created_at;
        public String type;

        public DateTime getDate() {
            return SignaturitRestEvents.parseDateString(created_at);
        }
    }
}