public class SignaturitRecipientsStatusController{
    
    public Tracked_Email__c trackedEmail {get;set;}
    
    public Integer rowsDisplayed {get;set;}
    public Integer eventsSize {get{return events.size();}}
    
    public Boolean embedded {get;set;}
    
    public Set<String> recipientNames;
    public Map<String,String> typePerRecipient;
    public Map<String,ComparableEvent> statusPerRecipient;
    
    public String createdByName {get;set;}
    public String lastModifiedByName {get;set;}
    
    public List<ComparableEvent> events {
        get{
            List<ComparableEvent> l = statusPerRecipient.values();
            l.sort();
            return l;
        }
    }
        
    public SignaturitRecipientsStatusController(ApexPages.StandardController controller){
        // get tracked email
        trackedEmail = [select Id, Name, Status__c, Subject__c, Email__c, CcAddress__c, BccAddress__c, Case__r.Id, Case__r.CaseNumber, Signaturit_ID__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate from Tracked_Email__c where Id = :controller.getRecord().Id];

        createdByName =[select Name from User where ID =: trackedEmail.CreatedById].Name;
        lastModifiedByName =[select Name from User where ID =: trackedEmail.LastModifiedById].Name;
        
        // get all events
        List<Tracked_Email_Event__c> allEvents = [select Id, Name, Status__c, Recipient_Name__c, Recipient_Address__c, Parent__c, Parent__r.Id, Timestamp__c from Tracked_Email_Event__c where Parent__c =: trackedEmail.Id];

        // get recipients type (to, cc or bcc)
        recipientNames = new Set<String>();
        typePerRecipient = new Map<String,String>();

        fillTypes(trackedEmail.Email__c, 'to');
        fillTypes(trackedEmail.CcAddress__c, 'cc');
        fillTypes(trackedEmail.BccAddress__c, 'bcc');

        // retrieve latest status for each recipient
        statusPerRecipient = new Map<String,ComparableEvent>();

        for(Tracked_Email_Event__c event : allEvents){
            String recipient = event.Recipient_Address__c.toLowerCase();
            if(!statusPerRecipient.containsKey(recipient)){
                statusPerRecipient.put(recipient, new ComparableEvent(typePerRecipient.get(recipient), event));
            }
            else{
                String currentStatus = statusPerRecipient.get(recipient).event.Status__c;
                if(SignaturitRestEvents.RECIPIENT_STATUSES.get(currentStatus) < SignaturitRestEvents.RECIPIENT_STATUSES.get(event.Status__c)){
                    statusPerRecipient.get(recipient).event = event;
                }
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('rows') == 'all'){
            rowsDisplayed = events.size();
            embedded = false;
        }
        else{
            rowsDisplayed = 3;
            embedded = true;
        }
    }

    private void fillTypes(String recipients, String type){
        if(recipients != null){
            for(String rec : recipients.split(';')){
                String lowercaseRec = rec.toLowerCase();
                if(!recipientNames.contains(lowercaseRec)){
                    recipientNames.add(lowercaseRec);
                    typePerRecipient.put(lowercaseRec, type);
                }
            }
        }
    }

    public class ComparableEvent implements Comparable{
        public String recipientType {get;set;}
        public Tracked_Email_Event__c event {get;set;}
        
        public ComparableEvent(String recipientType, Tracked_Email_Event__c event){
            this.recipientType = recipientType;
            this.event = event;
        }
    
        public Integer compareTo(Object compareTo){
            ComparableEvent ce = (ComparableEvent) compareTo;
            
            // 1. Compare recipient type
            if(ce.recipientType != this.recipientType){
                if(this.recipientType == 'to' || (this.recipientType == 'cc' && ce.recipientType == 'bcc')){
                    return -1;
                }
                // All other cases
                return 1;
            }
            
            // 2. Compare Status
            if(ce.event.Status__c != this.event.Status__c){
            	return SignaturitRestEvents.EMAIL_STATUSES.get(ce.event.Status__c) - SignaturitRestEvents.EMAIL_STATUSES.get(this.event.Status__c);
            }
            
            // 3. Compare Name
            if(ce.event.Recipient_Name__c < this.event.Recipient_Name__c){
                return 1;
            }
            else if(ce.event.Recipient_Name__c > this.event.Recipient_Name__c){
                return -1;
            }
            return 0;
        }
    }
}