@RestResource(urlMapping='/signaturit/event/*')
global class SignaturitRestEvents {

    public static String testJson;

    public class SignaturitEventException extends Exception {}

    public static String SENT = 'sent';

    public static Map<String, Integer> RECIPIENT_STATUSES = new Map<String,Integer>{
        SENT => 0,
        'email_processed' => 1,
        'email_deferred' => 2,
        'email_delivered' => 3,
        'email_bounced' => 4,
        'email_opened' => 5
    };

    public static Map<String, Integer> EMAIL_STATUSES = new Map<String,Integer>{
        SENT => 0,
        'email_bounced' => 1,
        'email_deferred' => 2,
        'email_processed' => 3,
        'email_delivered' => 4,
        'email_opened' => 5
    };

    @HttpPost
    global static void receiveEvent() {
        Map<String,String> params = RestContext.request.params;

        try{
            Tracked_Email_Certificate__c trackedEmailCertificate = [Select Tracked_Email__r.Id
                                            From Tracked_Email_Certificate__c
                                            Where Name =: params.get('certificate[id]') limit 1];

            Tracked_Email__c trackedEmail = [Select Id, Name, Subject__c, Status__c, FromAddress__c, Email__c, CcAddress__c, BccAddress__c, Case__r.Id, Case__r.CaseNumber, Case__r.Case_Thread_ID__c, Signaturit_Id__c
                                            From Tracked_Email__c
                                            Where Id =: trackedEmailCertificate.Tracked_Email__r.Id];

            Tracked_Email_Event__c event = new Tracked_Email_Event__c(
                Parent__c = trackedEmail.Id,
                Recipient_Address__c = params.get('certificate[email]'),
                Recipient_Name__c = params.get('certificate[name]'),
                Attachment__c = params.get('certificate[file][name]'),
                Timestamp__c = Datetime.now(),
                Status__c = params.get('type'),
                Event_Unique_Field__c = trackedEmail.Id + '-' + params.get('certificate[email]') + '-' + params.get('type')
            );
            insert event;

            // Update Tracked Email status if necessary
            // Consider the event only if the recipient is a [to]
            Set<String> mainRecipients = new Set<String>(trackedEmail.Email__c.split(';'));
            if(mainRecipients.contains(event.Recipient_Address__c)){
                
                // If event is bounced_email, send an email to the sender (email will be attached to the related case due to the thread id in the email subject)
                if(event.Status__c == 'email_bounced'){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					message.setToAddresses(new List<String>{trackedEmail.FromAddress__c});
                    message.setSubject('Bounced Tracked Email');
                    
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
                    if ( owea.size() > 0 ) {
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                    }

                    String body = '<html><head><style>table {border-spacing:0;} th,td{border: 1px solid black;text-align: left;padding: 5px;}</style></head>'
                                    + '<body>The following tracked email could not be delivered to one of its recipients:<br/><br/><table><tr style="font-weight:bold"><th>Tracked Email</th><th>Case Number</th><th>Subject</th><th>Recipients</th><th>Error</th></tr>'
                                    + '<tr><td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Id + '">' + trackedEmail.Name + '</a></td>'
                                    + '<td><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + trackedEmail.Case__r.Id + '">' + trackedEmail.Case__r.CaseNumber + '</a></td>'
                                    + '<td>' + trackedEmail.Subject__c + '</td>'
                                    + '<td>' + event.Recipient_Address__c + '</td>'
                                    + '<td>Bounced</td>'
                                    + '</tr></table><br/><br/>' + trackedEmail.Case__r.Case_Thread_ID__c + '</body></html>';
                        
                    message.setHtmlBody(body);
                
                    Messaging.sendEmail(new List<Messaging.Email>{message});
                }
                
				SignaturitRest.updateEmailStatus(new List<Tracked_Email__c>{trackedEmail});
            }
        }
        catch(Exception e){
            System.debug('SignaturitRestEvents.receiveEvent():' + e);
        }
    }
    
    @HttpGet
    global static String testService() {
        return 'testService OK';
    }

    public static DateTime parseDateString(String dateStr) {
        try {
            list<Integer> timeParts = new list<Integer>();
            for ( String part: dateStr.split('[T:+-]') ) {
                timeParts.add( Integer.ValueOf(part));
            }
            return DateTime.newInstanceGmt(timeParts[0], timeParts[1], timeParts[2], timeParts[3], timeParts[4], timeParts[5]);
        } catch( Exception e) {
            return DateTime.now();
        }
    }
}