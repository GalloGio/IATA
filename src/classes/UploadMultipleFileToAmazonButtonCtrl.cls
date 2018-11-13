global class UploadMultipleFileToAmazonButtonCtrl {

    public String uploader {get;set;}
    public String source {get;set;}
    public AmazonFile__c amazonFile{get{

        if(this.amazonFile == null) {

            this.amazonFile = new AmazonFile__c();
        }

        return this.amazonFile;
    }set;}

    public static final Long MAX_FILE_SIZE = 20971520; // 20 MB

    public Id parentId {get; set;}
    public String folder {get; set;}

    /*** AMSU-154 ***/
    public Id ownerId {get;set;}

    public UploadMultipleFileToAmazonButtonCtrl() {
        //IE9 hack
        String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT');
        if(browserType != null && browserType.contains('MSIE')){
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        }
    }

    /*** AMSU-154 ***/
    /*** notify Owner ***/
    @RemoteAction
    global static String notifyOscarOwner(Id caseId, String fileIdentifier) {
        try {
            Case cse = [SELECT Id, OwnerId, Reason1__c, CaseArea__c, CaseNumber, Subject FROM Case WHERE Id = :caseId];
            User usr = [SELECT Id, Name FROM User WHERE Id = :cse.OwnerId];
            EmailTemplate template = [Select DeveloperName, Id, HtmlValue, Body, Subject From EmailTemplate where DeveloperName = :Label.AMS_AttchNotifyOwner];
            Id orgAddressId = [select Id from OrgWideEmailAddress where Address = :Label.noreplyEmail][0].Id;

            String htmlBody = template.HtmlValue;
            String subject = template.Subject;
            String caseLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cse.Id;

            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.saveAsActivity = false;
            emailToSend.setTargetObjectId(usr.Id);
            emailToSend.setOrgWideEmailAddressId(orgAddressId);

            if(!String.isBlank(htmlBody)) { 
                subject = subject.replace('{!Case.CaseNumber}', cse.CaseNumber);   
                emailToSend.setSubject(subject);          
                htmlBody = htmlBody.replace('<![CDATA[', '');
                htmlBody = htmlBody.replace('{!Case.OwnerFullName}', usr.Name);
                htmlBody = htmlBody.replace('{!$User.FirstName}', UserInfo.getFirstName());
                htmlBody = htmlBody.replace('{!$User.LastName}', UserInfo.getLastName());
                htmlBody = htmlBody.replace('{!Case.Link}', caseLink);
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', cse.CaseNumber);
                htmlBody = htmlBody.replace('{!Case.Subject}', String.isBlank(cse.Subject) ? '' : cse.Subject);
                htmlBody = htmlBody.replace('{!FileIdentifier}', String.isBlank(fileIdentifier) ? '' : fileIdentifier);  
                htmlBody = htmlBody.replace('{!Case.CaseArea__c}', String.isBlank(cse.CaseArea__c) ? '' : cse.CaseArea__c);
                htmlBody = htmlBody.replace('{!Case.Reason1__c}', String.isBlank(cse.Reason1__c) ? '' : cse.Reason1__c);
                htmlBody = htmlBody.replace(']]>', '');
                emailToSend.setHtmlBody(htmlBody);
            }

            Messaging.SendEmailResult[] EmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});

            return Label.AMS_NotificationSent;
        } catch(Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction
    global static UploadFile createUploadFile(String id, String filenameupload, String contentType, Long filesize, String folder, String credentialName) {
        AmazonCredentials credential = AmazonCredentials.getCredentials(credentialName);

        // remove all repeated spaces
        String filteredFileName = filenameupload.replaceAll('[ ]+', ' ');

        UploadFile upF = new UploadFile(id, filteredFileName, contentType, folder, credential);

        // check if file exists
        if( AmazonRest.checkFile( folder + filteredFileName , credential) ) {
            upf.isSuccess = false;
            upf.errorMessage =  Label.NoSameName;
            return upf;
        }

        //check file size
        if (filesize > MAX_FILE_SIZE) {
            upf.isSuccess = false;
            upf.errorMessage =  Label.Overall_maximum_size;
            return upf;
        }

        //Check file name length: no more than 80 characters
        if (filenameupload.length() > 80) {
            upf.isSuccess = false;
            upf.errorMessage =  Label.File_name_too_long;
            return upf;
        }

        if (filenameupload.indexOf('\'') != -1 || filenameupload.indexOf('&') != -1) {
            upf.isSuccess = false;
            upf.errorMessage =  Label.No_special_characters;
            //upf.errorMessage =  'Special characters \' and & are not allowed';
            return upf;
        }

        upf.isSuccess = true;
        return upF ;
    }

    @RemoteAction
    global static boolean createAmazonFileObject(String amazonKey, Long filesize, String parentId, String recordType, String fileIdentifierPick, String source) {
        try {
            list<String> parts = amazonKey.split('/');
            String filename = parts.isEmpty()? '': parts.get( parts.size() - 1 );

            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = filename,
                Full_Name_Unique__c = amazonKey,
                Source__c = source,
                File_Identifier_picklist__c = fileIdentifierPick,
                Size_MB__c = filesize* 0.000001 //convert to MB
            );

            if(recordType != null) {
                Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', recordType);
                if (rtId != null) {
                    amazonFile.RecordTypeId =rtId;
                }
            }

            if (parentId.startsWith('500')) {
                amazonFile.Case__c = parentId;
            }
            upsert amazonFile;

            return true;
        } catch ( Exception e) {
            System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
            return false;
        }
    }

    /**
        Class to manage the upload of a file to Amazon
        It manages the key and signature to do a callout
    **/
    global class UploadFile {

        public String endpoint {get; set;}
        public String bucketName {get; set;}
        public String fullFileName {get; set;}
        public String fullFileNameEncoded {get; set;}
        public String authorization {get;set;}
        public String timestamp {get;set;}
        public String contentType {get; set;}
        public boolean isSuccess{get;set;}
        public String errorMessage {get;set;}

        public UploadFile( String id, String filenameupload, String contentType, String folder, AmazonCredentials credential ) {
            this.endpoint = credential.EndpointBaseURL;
            this.bucketName = credential.Bucket;
            this.fullFileName = folder + filenameupload;
            this.fullFileNameEncoded = AmazonRest.EncodePath(this.fullFileName);
            this.contentType = contentType;
            this.isSuccess = true;
            this.errorMessage = '';
            calculePolicy(credential);
        }

        public void calculePolicy(AmazonCredentials credential) {
            //this.timestamp = DateTime.now().formatGMT('E, d MMM yyyy HH:mm:ss Z');
            this.timestamp = DateTime.now().format('E, d MMM yyyy HH:mm:ss Z');
            system.debug('@@@timestamp: ' +this.timestamp);
            //this.timestamp = DateTime.now().format();
            String policyString = 'PUT\n\n'
                + this.contentType + ';charset=UTF-8\n\n'
                + 'x-amz-date:' + this.timestamp + '\n'
                + '/'+this.bucketName+'/'+this.fullFileNameEncoded;
            String signedPolicy = AmazonRest.make_sig(policyString, credential);

            this.authorization = 'AWS ' + credential.AWSAccessKeyId + ':' + signedPolicy;
        }
    }
}