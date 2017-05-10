@RestResource(urlMapping='/signaturit/event/*')
global with sharing class SignaturitRestEvents {

/*
https://iata--bi.cs87.my.salesforce.com/services/apexrest/signaturit/event
*/

    public static String testJson;

    public class SignaturitEventException extends Exception {}

    public static String SENT = 'sent';

    public static Map<String, Integer> STATUSES = new Map<String,Integer>{
        SENT => 0,
        'email_processed' => 1,
        'email_bounced' => 2,
        'email_delivered' => 3,
        'email_opened' => 4
    };

    @HttpPost
    global static void receiveEvent() {
        Map<String,String> params = RestContext.request.params;

        try{
            Tracked_Email_Certificate__c trackedEmailCertificate = [Select Tracked_Email__r.Id
                                            From Tracked_Email_Certificate__c
                                            Where Name =: params.get('certificate[id]') limit 1];

            Tracked_Email__c trackedEmail = [Select Id, Status__c, Email__c, AdditionalTo__c
                                            From Tracked_Email__c
                                            Where Id =: trackedEmailCertificate.Tracked_Email__r.Id];

            Tracked_Email_Event__c event = new Tracked_Email_Event__c(
                Parent__c = trackedEmail.Id,
                Recipient_Address__c = params.get('certificate[email]'),
                Recipient_Name__c = params.get('certificate[name]'),
                Attachment__c = params.get('certificate[file][name]'),
                Timestamp__c = parseDateString(params.get('certificate[created_at]')),
                Status__c = params.get('type')
            );
            insert event;

            String logText = 'Event : ' + event;

            // Update Tracked Email status if necessary
            // Consider the event only if the recipient is a [to]
            if(event.Recipient_Address__c == trackedEmail.Email__c
                || (trackedEmail.AdditionalTo__c != null && new Set<String>(trackedEmail.AdditionalTo__c.split(';')).contains(event.Recipient_Address__c))){
                
                // compare the status of the email and the event
                Integer currentStatus = STATUSES.get(trackedEmail.Status__c);
                Integer eventStatus = STATUSES.get(event.Status__c);

                if(eventStatus > currentStatus){
                    logText += '\r\nChanged tracked email status from ' + currentStatus + ' to ' + eventStatus; 
                    trackedEmail.Status__c = event.Status__c;
                    update trackedEmail;
                }
                else{
                    logText += '\r\nNOT updating tracked email status : old status';
                }            
            }
            else{
                logText += '\r\nNOT updating tracked email status : cc or bcc address';
            }

            ///Signaturit_Log__c log1 = new Signaturit_Log__c(Log_Text__c = logText);
            //insert log1;
        }
        catch(Exception e){
            //Signaturit_Log__c log1 = new Signaturit_Log__c(Log_Text__c = ''+e.getMessage());
            //insert log1;
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