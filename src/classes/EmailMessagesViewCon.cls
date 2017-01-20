public class EmailMessagesViewCon {

     private void loadEmails(){
   try {
         
          map<String,Archived_Message__c> archMessPerIdMessOrig = new map<String,Archived_Message__c>();

        originalEmail = new Map<String,EmailMessage>();
        //load records related to case
        this.archivedMessages = [SELECT  Name,EmailMessage__c,  Case__c, CreatedById, CreatedDate, Id FROM Archived_Message__c where Case__c =:this.cse.Id ];

        if(archivedMessages <> null && archivedMessages.size() > 0)
        for(Archived_Message__c arch :archivedMessages)
            archMessPerIdMessOrig.put(arch.EmailMessage__c, arch);

        Map<String,Archived_Message__c> tmpArchivedMessages = new Map<String,Archived_Message__c>();
        for(Archived_Message__c a:archivedMessages )
            tmpArchivedMessages .put(a.EmailMessage__c,a);

        //load tracked emails
        this.trackedEmails = [SELECT ToContact__c, Html_Body__c, Subject__c, Status__c, CreatedById, CreatedDate, Id FROM Tracked_Email__c where Case__c =:this.cse.Id ];

        //load Email activity status to print it in view  using a map: em.Activity --> Stirng
        List<String> l = new List<String>();
        this.emails = new List<EmailMessage>();

        List<EmailMessage > tmpEmails = [SELECT ParentId, Status, Incoming, FromName, ActivityId,
                                         BccAddress, CcAddress, CreatedById, CreatedDate, 
                                         IsDeleted, Id, FromAddress, HtmlBody, HasAttachment, Headers,
                                          LastModifiedById, LastModifiedDate, MessageDate, Subject,
                                           SystemModstamp, TextBody, ToAddress 
                                           FROM EmailMessage 
                                         where ParentId = :cse.id order by CreatedDate desc ];

        emailsTasksStatus = new Map<String,String>();
        for(EmailMessage e:tmpEmails  ) {
           if(!tmpArchivedMessages.containsKey(e.Id)){
                emails.add(e);
              UnifiedList.add(new EmailWrapper(e,false,null));
              
           }
               
           else{
         // throw new transformationException('' + tmpArchivedMessages);
               originalEmail.put(e.Id,e);
               
               UnifiedList.add(new EmailWrapper(e,true,archMessPerIdMessOrig.get(e.id)));

               }

        }
         
        //throw new transformationException('' + UnifiedList);
      //  UnifiedList.sort();
       try
        {
            EmailsAvailable  = (archivedMessages.size() + trackedEmails.size() + emails.size())>0;
        }catch(Exception ex){
            EmailsAvailable = true;
        }
        if(this.emails==null)
            this.emails= new List<EmailMessage>();
            
            
            
          
        }catch(Exception e){
      ApexPages.Message   myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input.' + e.getmessage());
           ApexPages.addMessage(myMsg);
        }    
            
    }



public transient List<EmailWrapper> UnifiedList {get; set;}

public class EmailWrapper  implements Comparable {

    public boolean ArchivedEmail {get;set;}
    public EmailMessage message {get;set;}
    public Datetime emailCreation {get;set;}
    public Id ArchEmailMessageID {get;set;}


    public EmailWrapper(EmailMessage message, boolean archived,Archived_Message__c archMess) {

            this.ArchivedEmail = archived;
            this.message = message;
            this.emailCreation = message.CreatedDate;
            this.ArchEmailMessageID = archMess <> null ? archMess.id :null;
           //  throw new transformationException('' + archMess);
    }


    public Integer compareTo(Object compareTo){

        EmailWrapper compareToEmail = (EmailWrapper)compareTo;
        if (emailCreation == compareToEmail.emailCreation) return 0;
        if (emailCreation > compareToEmail.emailCreation) return 1;
        return -1;


    } 
  
}


    public transient List<EmailMessage> emails {get; set;}
    public transient List<Archived_Message__c> archivedMessages {get; set;}

    public Case cse {get; set;}
    public Boolean EmailsAvailable{get;set;}

    //jfo
    public transient List<Archived_Attachment__c> archivedAttachments {get; set;}
    public transient List<Attachment> sfdcAttachments {get; set;}
    public transient Map<String,String> emailsTasksStatus {get; set;}
    public transient Map<String,EmailMessage> originalEmail {get; set;}
    public transient List<Tracked_Email__c> trackedEmails {get; set;}
    public boolean hasAttachment  {get; set;}



    public EmailMessagesViewCon (ApexPages.StandardController controller) {
        UnifiedList = new List<EmailWrapper>(); 
        //EmailsAvailable = true;
        try{
            if(!Test.isRunningTest()) {
                controller.addFields(new List<String>{'id', 'Status', 'CaseNumber', 'BSPCountry__c', 'ContactId', 'RecordType.DeveloperName', 'Region__c', 'RecordTypeId', 'CaseArea__c' });
            }
            this.cse= (Case)controller.getRecord();
            loadEmails();
            loadAttachments();
       }
       catch(Exception e){
            String temp = ApexPages.currentPage().getParameters().get('fieldValue');
            this.cse = [Select id, Status,CaseNumber, BSPCountry__c, ContactId, RecordType.DeveloperName from Case where id = :temp];
            system.debug('ERROR Exception while creating controller '+e.getMessage());
       }
    }

    private void loadAttachments(){
        archivedAttachments  = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id  , BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c FROM Archived_Attachment__c where Case__c= :this.cse.Id ];
          //load attchament linked directly to this case
        sfdcAttachments =  [SELECT Id, ParentId, OwnerId, Name, CreatedById, LastModifiedDate, BodyLength FROM Attachment where ParentId = :this.cse.Id];
        if(archivedAttachments!=null)
            hasAttachment = (archivedAttachments.size() + sfdcAttachments.size())>0;
        else hasAttachment = false;
    }

    public String getACaseId(){
        return this.cse.Id;
    }

    private void loadEmails2(){
        originalEmail = new Map<String,EmailMessage>();
        //load records related to case
        this.archivedMessages = [SELECT  Name,EmailMessage__c,  Case__c, CreatedById, CreatedDate, Id FROM Archived_Message__c where Case__c =:this.cse.Id ];

        Map<String,Archived_Message__c> tmpArchivedMessages = new Map<String,Archived_Message__c>();
        for(Archived_Message__c a:archivedMessages )
            tmpArchivedMessages .put(a.EmailMessage__c,a);

        //load tracked emails
        this.trackedEmails = [SELECT ToContact__c, Html_Body__c, Subject__c, Status__c, CreatedById, CreatedDate, Id FROM Tracked_Email__c where Case__c =:this.cse.Id ];

        //load Email activity status to print it in view  using a map: em.Activity --> Stirng
        List<String> l = new List<String>();
        this.emails = new List<EmailMessage>();

        List<EmailMessage > tmpEmails = [SELECT ParentId, Status, Incoming, FromName, ActivityId,
                                         BccAddress, CcAddress, CreatedById, CreatedDate, 
                                         IsDeleted, Id, FromAddress, HtmlBody, HasAttachment, Headers,
                                          LastModifiedById, LastModifiedDate, MessageDate, Subject,
                                           SystemModstamp, TextBody, ToAddress 
                                           FROM EmailMessage 
                                         where ParentId = :cse.id order by CreatedDate desc ];

        emailsTasksStatus = new Map<String,String>();
        for(EmailMessage e:tmpEmails  ) {
           if(!tmpArchivedMessages .containsKey(e.Id))
               emails.add(e);
           else
               originalEmail.put(e.Id,e);

        }
        try {
            EmailsAvailable  = (archivedMessages.size() + trackedEmails.size() + emails.size())>0;
        }catch(Exception e){
            EmailsAvailable = true;
        }
        if(this.emails==null)
            this.emails= new List<EmailMessage>();
    }

    public Case getCse(){
        return this.cse;
    }


    public List<EmailMessage> getEmails(){

        if(this.emails==null)loadEmails();

        return emails;
    }

    public Boolean getShowSendTrackedEmailButton() {
        try {
            // if account is SAAM, Region has to be Europe and caseArea = Risk Management Process
            Id saamRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SAAM').getRecordTypeId();
            if (cse.RecordTypeId == saamRt) {
                return cse.Region__c == 'Europe' && cse.CaseArea__c == 'Risk Management Process';
            }
            // if account is IATA Financial Review, only Region has to be Europe
            Id financialReviewRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IATA Financial Review').getRecordTypeId();
            Id process = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Process').getRecordTypeId();
            if (cse.RecordTypeId == financialReviewRt || cse.RecordTypeId == process) {
                return cse.Region__c == 'Europe';
            }
        } catch (Exception e) {
            System.debug('Permission not granted to see Tracked email button ' + e.getMessage());
        }
        return false;
    }
}