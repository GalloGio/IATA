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

}