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
            dummyEmailMsg.setReplyTo('dummy@maildummy.org');
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
            Contact contact = [Select Id, Name, Email from Contact where Id = :trackedEmail.ToContact__c];

            // Add track Id at the bottom of the body
            //Case cse = [Select Id, Case_Thread_ID__c from Case where id = :trackedEmail.Case__c ];
            String body = trackedEmail.Html_Body__c;// + '<br/><br/>' + cse.Case_Thread_ID__c;
            
            Signaturit_Events_WS__c url = EVENTS_URL.values().get(0);
            
            string boundary = 'WebKitFormBoundary' + String.valueOf(DateTime.now().getTime());

            String header = '--' + boundary
                        + '\r\nContent-Disposition: form-data; name="events_url"'
                        + '\r\n\r\n' + url.events_url__c;
                        
			if(url.oauth_url__c != null && url.oauth_url__c != ''){
				header += '\r\n--' + boundary
							+'Content-Disposition: form-data; name="oauth_url"'
	                        +'\r\n\r\n'+ url.oauth_url__c;
			}
			
			header += '\r\n--' + boundary
                        +'Content-Disposition: form-data; name="recipients[to][0][fullname]"'
                        +'\r\n\r\n'+ contact.Name
                        +'\r\n--'+boundary
                        +'\r\nContent-Disposition: form-data; name="recipients[to][0][email]"'
                        +'\r\n\r\n' + contact.Email;
            
            if(trackedEmail.AdditionalTo__c != null && trackedEmail.AdditionalTo__c != ''){
                List<String> additionalTo = trackedEmail.AdditionalTo__c.split(';');
                for(Integer i = 0; i < additionalTo.size(); i++){
                    header += '\r\n--' + boundary
                              + '\r\nContent-Disposition: form-data; name="recipients[to][' + (i+1) + '][email]"'
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

			Integer i = 0;
			for(Attachment a : [select Id from Attachment where parentId =: trackedEmail.Id order by BodyLength desc]){
				Attachment attachment = [select Name, Body from Attachment where Id =: a.Id];

				header += '\r\n--' + boundary + '\r\n';
				header += 'Content-Disposition: attachment; name="attachments[' + i + ']"; filename="' + attachment.Name + '";\nContent-Type: text/plain';
				header += '\r\n--' + boundary;
				header += '\r\nContent-Disposition: form-data;';
				header += '\r\n\r\n' + EncodingUtil.base64Encode(attachment.Body);
            
				attachment.Body = null;
				attachment = null;
                
				i++;
			}
            
            header += '\r\n--' + boundary
                    + '\r\nContent-Disposition: form-data; name="subject"'
                    +'\r\n\r\n' + trackedEmail.Subject__c
                    +'\r\n--'+boundary
                    +'\r\nContent-Disposition: form-data; name="body"'
                    +'\r\n\r\n' + body
                    +'\r\n--'+boundary+'--';

            System.debug('HEADER--' + header + '--HEADER');

            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header));
            Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded);

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
                return (MailInfoResponse)parser.readValueAs(MailInfoResponse.class);
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
            return (MailInfoResponse)parser.readValueAs(MailInfoResponse.class);
        } catch (Exception e) {
            System.debug('ERROR in SignaturitRest.getMailInfo(' + trackedEmail + ') : ' + e);
            return null;
        }
    }

    /**
        get the events for a particular email from signaturit and insert them in Salesforce
    **/
    public static void updateEventList( Tracked_Email__c trackedEmail) {
        MailInfoResponse response = SignaturitRest.getMailInfo(trackedEmail);

        // get events from all certificates, it is grouped by recipient to remove duplicities
        map<String,CertificateInfoResponse> mapEvents = new map<String,CertificateInfoResponse>();
        for ( CertificateInfoResponse certificate: response.certificates) {
            mapEvents.put(certificate.email, certificate);
        }

        // creates a list of Tracked_Email_Event__c ready to insert in the Tracked_Email__c record
        EventDataInfoResponse lastEvent = null;
        list<Tracked_Email_Event__c> listNewEvents = new list<Tracked_Email_Event__c>();
        for (String mail: mapEvents.keyset() ) {
            for (EventDataInfoResponse ev: mapEvents.get(mail).events ) {
                String name = mapEvents.get(mail).name;
                listNewEvents.add( new Tracked_Email_Event__c(
                    Recipient_Name__c = name != null && name.length() > 80 ? name.left(80) : name,
                    Recipient_Address__c = mail,
                    Timestamp__c = ev.getDate(),
                    Status__c = ev.type,
                    Parent__c  = trackedEmail.id
                ));
                if (lastEvent==null || lastEvent.getDate() <= ev.getDate()) {
                    lastEvent = ev;
                }
            }
        }

        System.debug('updateEventList listNewEvents: ' + listNewEvents);

        if ( !listNewEvents.isEmpty() ) {
            Savepoint sp = Database.setSavepoint();
            try {
                list<Tracked_Email_Event__c> listEvents = [Select Id from Tracked_Email_Event__c where Parent__c = :trackedEmail.Id ];
                if ( !listEvents.isEmpty() ) {
                    delete listEvents;
                }
                insert listNewEvents;
                trackedEmail.Status__c = lastEvent.type;
                update trackedEmail;
                System.debug('SignaturitRest.updateEventList ' + trackedEmail.Id + ': INSERTED ' + listEvents.size() + ' EVENTS');

            } catch (Exception e) {
                System.debug('ERROR SignaturitRest.updateEventList ' + trackedEmail.Id + ': ' + e.getMessage());
                Database.rollback(sp);
            }
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
        
        // these values are set if response status != 200
        public String status_code;
        public String message;
        
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