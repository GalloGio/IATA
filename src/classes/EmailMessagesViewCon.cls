public class EmailMessagesViewCon {

    private void loadEmails() {
        try {
            unifiedList = new List<EmailWrapper>();

            originalEmail = new Map<String, EmailMessage>();
            //load records related to case
            this.archivedMessages = [SELECT  Name, EmailMessage__c,  Case__c, CreatedById, CreatedDate, Id FROM Archived_Message__c where Case__c = :this.cse.Id ];

            Map<String, Archived_Message__c> tmpArchivedMessages = new Map<String, Archived_Message__c>();
            for (Archived_Message__c a : archivedMessages )
                tmpArchivedMessages .put(a.EmailMessage__c, a);

            //load tracked emails
            this.trackedEmails = [SELECT ToContact__c, Email__c, TextBody__c, Subject__c, Status__c, CreatedById, CreatedDate, Id, Has_Attachment__c FROM Tracked_Email__c where Case__c = :this.cse.Id ];

            for (Tracked_Email__c trackedEmail : trackedEmails) {
                unifiedList.add(new EmailWrapper(trackedEmail));
            }

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

            emailsTasksStatus = new Map<String, String>();
            for (EmailMessage e : tmpEmails  ) {
                if (!tmpArchivedMessages.containsKey(e.Id)) {
                    unifiedList.add(new EmailWrapper(e));
                    emails.add(e);
                }

                else {
                    unifiedList.add(new EmailWrapper(tmpArchivedMessages.get(e.Id), e));
                    originalEmail.put(e.Id, e);
                }

            }

            try {
                EmailsAvailable  = (archivedMessages.size() + trackedEmails.size() + emails.size()) > 0;
            } catch (Exception e) {
                EmailsAvailable = true;
            }

            unifiedList.sort();

            if (this.emails == null)
                this.emails = new List<EmailMessage>();




        } catch (Exception e) {
            ApexPages.Message   myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input.' + e.getmessage());
            ApexPages.addMessage(myMsg);
        }

    }

    public List<EmailWrapper> unifiedList {get; set;}

    public class EmailWrapper implements Comparable {
        public String emailType {get; set;}

        public String displayEmailActions {
            get{return emailType == 'email' ? '' : 'none';}
        }

        public String displayArchivedActions {
            get{return emailType == 'archived' ? '' : 'none';}
        }

        public String displayTrackedActions {
            get{return emailType == 'tracked' ? '' : 'none';}
        }

        public String displayEmailAddress {
            get{return emailType != 'tracked' ? '' : '';}
        }

        public Id emailId {get; set;}
        public String status {get; set;}
        public String image {get; set;}
        public String title {get; set;}
        public String displayHasAttachmentImage {get; set;}
        public String subject {get; set;}
        public String body {get; set;}
        public String emailAddress {get; set;}
        public Id contact {get; set;}
        public Datetime messageDate {get; set;}
        public Tracked_Email__c trackedEmail {get; set;}
        public Id archivedEmailId {get; set;}
        public Boolean isArchived {get{return emailType == 'archived';}}

        public EmailWrapper(Tracked_Email__c trackedEmail) {
            emailType = 'tracked';
            emailId = trackedEmail.Id;
            status = trackedEmail.Status__c + ' [Tracked]';
            image = '/img/emailOutbound.gif';
            title = 'Outbound';
            displayHasAttachmentImage = trackedEmail.Has_Attachment__c ? '' : 'none';
            subject = trackedEmail.Subject__c == null || trackedEmail.Subject__c == '' ? 'No Subject' : trackedEmail.Subject__c;
            body = trackedEmail.TextBody__c != null ? trackedEmail.TextBody__c.substring(0, Math.min(trackedEmail.TextBody__c.length() - 1, 77)) : '';
            contact = trackedEmail.ToContact__c;
            emailAddress = trackedEmail.Email__c;
            messageDate = trackedEmail.CreatedDate;
            this.trackedEmail = trackedEmail;
        }

        public EmailWrapper(EmailMessage email) {
            emailType = 'email';
            setup(email);
        }

        public EmailWrapper(Archived_Message__c archivedMessage, EmailMessage originalEmail) {
            emailType = 'archived';
            archivedEmailId = archivedMessage.Id;
            setup(originalEmail);
            //override some behaviors defined in setup method
            displayHasAttachmentImage = '';     //different behavior than for other email types, is it normal?
            if (status != '') {
                status += ' [Archived]';
            }
        }

        private void setup(EmailMessage email) {
            emailId = email.Id;
            if (email.Status == '0') {status = 'New';}
            else if (email.Status == '1') {status = 'Read';}
            else if (email.Status == '2') {status = 'Replied';}
            else if (email.Status == '3') {status = 'Sent';}
            else if (email.Status == '4') {status = 'Forwarded';}
            else {status = '';}

            image = email.Incoming ? '/img/emailInbound.gif' : '/img/emailOutbound.gif';
            title = email.Incoming ? 'Inbound' : 'Outbound';
            displayHasAttachmentImage = email.HasAttachment ? '' : 'none';      //different behavior than for other email types, is it normal?
            subject = email.Subject == null || email.Subject == '' ? 'No Subject' : email.Subject;
            if (email.TextBody != null) {
                if (email.TextBody.length() < 78) {
                    body = email.TextBody;
                } else {
                    body = email.TextBody.substring(0, 77);
                }
            }
            emailAddress = email.Incoming ? email.FromAddress : email.ToAddress;
            messageDate = email.MessageDate;
        }

        public Integer compareTo(Object compareTo) {
            EmailWrapper compareToEmail = (EmailWrapper) compareTo;
            if (messageDate > compareToEmail.messageDate) {return -1;}
            else if (messageDate == compareToEmail.messageDate) {return 0;}
            return 1;
        }

    }


    public transient List<EmailMessage> emails {get; set;}
    public transient List<Archived_Message__c> archivedMessages {get; set;}

    public Case cse {get; set;}
    public Boolean EmailsAvailable {get; set;}

    //jfo
    public transient List<Archived_Attachment__c> archivedAttachments {get; set;}
    public transient List<Attachment> sfdcAttachments {get; set;}
    public transient Map<String, String> emailsTasksStatus {get; set;}
    public transient Map<String, EmailMessage> originalEmail {get; set;}
    public transient List<Tracked_Email__c> trackedEmails {get; set;}
    public boolean hasAttachment  {get; set;}



    public EmailMessagesViewCon (ApexPages.StandardController controller) {
        try {
            if (!Test.isRunningTest()) {
                controller.addFields(new List<String> {'id', 'Status', 'CaseNumber', 'BSPCountry__c', 'ContactId', 'RecordType.DeveloperName', 'Region__c', 'RecordTypeId', 'CaseArea__c', 'E2CP__AdditionalCC__c', 'Case_Group__c', 'CNSCase__c'});
            }
            this.cse = (Case)controller.getRecord();
            loadEmails();
            loadAttachments();
        } catch (Exception e) {
            String temp = ApexPages.currentPage().getParameters().get('fieldValue');
            this.cse = [Select id, Status, CaseNumber, BSPCountry__c, ContactId, RecordType.DeveloperName from Case where id = :temp];
            system.debug('ERROR Exception while creating controller ' + e.getMessage());
        }
    }

    private void loadAttachments() {
        archivedAttachments  = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id  , BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c FROM Archived_Attachment__c where Case__c = :this.cse.Id ];
        //load attchament linked directly to this case
        sfdcAttachments =  [SELECT Id, ParentId, OwnerId, Name, CreatedById, LastModifiedDate, BodyLength FROM Attachment where ParentId = :this.cse.Id];
        if (archivedAttachments != null)
            hasAttachment = (archivedAttachments.size() + sfdcAttachments.size()) > 0;
        else hasAttachment = false;
    }

    public String getACaseId() {
        return this.cse.Id;
    }

    public Case getCse() {
        return this.cse;
    }


    public List<EmailMessage> getEmails() {

        if (this.emails == null)loadEmails();

        return emails;
    }

    public Boolean getShowSendTrackedEmailButton() {
        try {

            // In any case, Region has to be 'Europe' or 'Africa & Middle East'
            if (cse.Region__c == 'Europe' || cse.Region__c == 'Africa & Middle East' || cse.Region__c == 'Americas') {

                // if case record type is 'SAAM', caseArea has to be 'Risk Management Process', 'Accreditation Process', 'Accreditation Products'
                // or 'Cargo Process'  
                Id saamRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SAAM').getRecordTypeId();
                if (cse.RecordTypeId == saamRt) {

                    return (cse.CaseArea__c == 'Risk Management Process' || cse.CaseArea__c == 'Accreditation Process' 
                        || cse.CaseArea__c == 'Accreditation Products' || cse.CaseArea__c == 'Cargo Process' || cse.CaseArea__c == 'Collection');
                }

                // if case record type is 'IATA Financial Review', 'sMAP(sales Monitoring Alert Process)', 'SIDRA', 'SIDRA Lite' or 'Oscar communication', return true
                Id financialReviewRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IATA Financial Review').getRecordTypeId();
                Id sMapRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('sMAP(sales Monitoring Alert Process)').getRecordTypeId();
                Id sidraId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();
                Id sidraLiteId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA Lite').getRecordTypeId();
                Id oscarComm = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
                Id invCollectionCases = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invoicing Collection Cases').getRecordTypeId();

                return (cse.RecordTypeId == financialReviewRt || cse.RecordTypeId == sMapRt || cse.RecordTypeId == sidraId
                    || cse.RecordTypeId == sidraLiteId || cse.RecordTypeId == oscarComm || cse.RecordTypeId == invCollectionCases);
            }
            return false;
        } catch (Exception e) {
            System.debug('Permission not granted to see Tracked email button ' + e.getMessage());
        }
        return false;
    }
}