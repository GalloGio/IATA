public with sharing class SignaturitUtils {
    
    public static String pStyle = '<style>p{margin-top:0px; margin-bottom:0px;}</style>';
    public static String pStyleShort = 'p{margin-top:0px; margin-bottom:0px;}';
    
    public static List<Tracked_Email__c> createTrackedEmails(List<Case> scope, String templateName, String fromName, String fromAddress){
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
        }

        insert emails;
       
        // create attachments if there are any in the Visualforce Email Template
        List<Attachment> attachments = new List<Attachment>();

        for(Attachment a : templateAttachments){
            for(Tracked_email__c email : emails){
                Attachment attachment = new Attachment(
					OwnerId = UserInfo.getUserId(),
                	ParentId = email.Id,
                	IsPrivate = true,
                	Body = a.Body,
                	Name = a.Name);
                
                attachments.add(attachment);
            }
        }
    
        insert attachments;
        
        return emails;
    }
    
    public static void sendTrackedEmails(List<Tracked_Email__c> trackedEmails){
        List<Tracked_Email_Certificate__c> certificates = new List<Tracked_Email_Certificate__c>();
        
        for(Tracked_Email__c email : trackedEmails){
            SignaturitRest.MailInfoResponse response = SignaturitRest.sendMail(email);

            email.Signaturit_Id__c = response.id;
            
            certificates.addAll(getCertificatesFromResponse(email.Id, response));
        }
        update trackedEmails;
        
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