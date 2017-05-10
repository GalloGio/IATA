public with sharing class SignaturitRest {

    public static String ENDPOINT = Label.Signaturit_Endpoint;
    public static String TESTSTRING;

    public static MailResponse sendMail( Tracked_Email__c trackedEmail) {
        try {
            Contact contact = [Select Id, Name, Email from Contact where Id = :trackedEmail.ToContact__c];

            // Add track Id at the bottom of the body
            Case cse = [Select Id, Case_Thread_ID__c from Case where id = :trackedEmail.Case__c ];
            trackedEmail.Html_Body__c += '<br/><br/>' + cse.Case_Thread_ID__c;

            string boundary = 'WebKitFormBoundary' + String.valueOf(DateTime.now().getTime());
            String header = '--' + boundary
            +'\r\nContent-Disposition: form-data; name="recipients[0][fullname]"'
            +'\r\n\r\n'+ contact.Name
            +'\r\n--'+boundary
            +'\r\nContent-Disposition: form-data; name="recipients[0][email]"'
            +'\r\n\r\n' + contact.Email
            +'\r\n--'+boundary
            +'\r\nContent-Disposition: form-data; name="subject"'
            +'\r\n\r\n' + trackedEmail.Subject__c
            +'\r\n--'+boundary
            +'\r\nContent-Disposition: form-data; name="body"'
            +'\r\n\r\n' + trackedEmail.Html_Body__c
            +'\r\n--'+boundary+'--';

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
            if(!Test.isRunningTest()) res = http.send(req);

            String jsonStr = !Test.isRunningTest() ? res.getBody() : TESTSTRING ;
            System.debug(jsonstr);
            JSONParser parser = JSON.createParser(jsonStr);
            return (MailResponse)parser.readValueAs(MailResponse.class);
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
            jsonStr = jsonStr.replace('"date"','"date_x"');
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
        map<String,list<EventDataInfoResponse>> mapEvents = new map<String,list<EventDataInfoResponse>>();
        for ( CertificateInfoResponse certificate: response.certificates) {
            mapEvents.put(certificate.recipient_email, certificate.events);
        }

        // creates a list of Tracked_Email_Event__c ready to insert in the Tracked_Email__c record
        EventDataInfoResponse lastEvent = null;
        list<Tracked_Email_Event__c> listNewEvents = new list<Tracked_Email_Event__c>();
        for (String mail: mapEvents.keyset() ) {
            for (EventDataInfoResponse ev: mapEvents.get(mail) ) {
                listNewEvents.add( new Tracked_Email_Event__c(
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

    public class MailResponse {
        public String id;
        public String subject;
        public String body;
        public String created_at;
        public String source;
        public String type;
        public list<Certificate> certificates;

        public list<String> getCertificateIds() {
            list<String> listIds = new list<String>();
            for (Certificate cert: certificates) {
                listIds.add(cert.Id);
            }
            return listIds;
        }
    }

    public class Certificate {
        public String id;
        String created_at;
        public String recipient_email;
        public String recipient_name;
    }

    public class MailInfoResponse {
        public String id;
        public String created_at;
        public CertificateInfoResponse[] certificates;
    }

    public class CertificateInfoResponse {
		public String created_at;
		public EventDataInfoResponse [] events;
		public String id;
		public EventDataInfoResponse last_event;
		public String recipient_email;
		public String recipient_name;

	}

    public class EventDataInfoResponse {
        public String date_x;
        public String created_at;
        public String type;

        public DateTime getDate() {
            return SignaturitRestEvents.parseDateString(date_x);
        }
    }

}