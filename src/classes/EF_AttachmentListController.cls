global with sharing class EF_AttachmentListController {

    public static Boolean runningForEF {
        get{
            if (runningForEF == null) runningForEF = false;
            return runningForEF;
        }
        set;
    }
    public Boolean viewPrivateFiles {get; set;}

    public String uploader {get; set;}
    public String source {get; set;}
    public Boolean scroll {get; set;}

    public String sapNumberRequiredJSON {
        get{
            return AmazonFileTrgHelper.sapNumberRequiredJSON;
        }
        set;
    }
    public String expiryDateRequiredJSON {
        get{
            return AmazonFileTrgHelper.expiryDateRequiredJSON;
        }
        set;
    }
    public String expiredRequiredJSON {
        get{
            return AmazonFileTrgHelper.expiredRequiredJSON;
        }
        set;
    }

    public static final Long MAX_FILE_SIZE = 20971520; // 20 MB

    public String amazonURL  {
        get { return WrapperAttach.CREDENTIAL.EndpointBaseURL + WrapperAttach.CREDENTIAL.Bucket; }
    }
    public String credentialName  {
        get { return WrapperAttach.CREDENTIAL_NAME; }
    }
    public String amazonPath  {
        get { return WrapperAttach.getAmazonFolder(this.Id); }
    }

    public list<WrapperAttach> listAttachments {get; set;}
    public Id editAttachmentId {get; set;}
    public WrapperAttach editAttachment {get; set;}
    public Boolean isAdminUser {get; set;}

    public AmazonFile__c amazonFileToUpload {get{

            if (this.amazonFileToUpload == null) {
                // set the default EF_Private__c
                Boolean efPrivate = false;
                if (this.id != null) {
                    String sId = (String)this.id;
                    List<EF_Amazonfile_Private__c> lsObjectTypes = EF_Amazonfile_Private__c.getAll().Values();
                    for (EF_Amazonfile_Private__c cs : lsObjectTypes) {
                        // if the first 3 chars of the SObject Id match, use the Boolean value from the custom setting
                        if (sid.left(3) == cs.SObject_3_first_chars__c) {
                            efPrivate = cs.EF_Private__c;
                            break;
                        }
                    }
                }
                this.amazonFileToUpload = new AmazonFile__c(EF_Private__c = efPrivate);
            }

            return this.amazonFileToUpload;
        } set;
    }

    // assgnTo variable
    public Id id {
        get;
        set {
            if (this.Id == null ) {
                this.Id = value;
                init();
            }
        }
    }

    public EF_AttachmentListController() {

        runningForEF = true;
    }

    /**
        check all assignTo calls have been done and execute initial methods
    **/
    private void init() {
        List<GroupMember> lsGroupMembers = [SELECT Id FROM GroupMember WHERE Group.DeveloperName = 'EF_Private_Document_Access' AND UserOrGroupId = :UserInfo.getUserId()];
        this.viewPrivateFiles = false;
        if (!lsGroupMembers.isEmpty()) this.viewPrivateFiles = true;
        if (this.id == null ) return;

        //IE9 hack
        String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT');
        if (browserType != null && browserType.contains('MSIE')) {
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        }

        // check if current user is Admin
        Profile profile = [Select id, Name from Profile where Id = :UserInfo.getProfileId()];
        this.isAdminUser = profile.Name.startsWithIgnoreCase('System Administrator') || profile.Name.startsWithIgnoreCase('Developer');

        refreshList();
    }

    /**
        Refresh the list of file attachments
    **/
    public Pagereference refreshList() {

        try {
            EF_AttachmentListController.runningForEF = true;

            List<WrapperAttach> tmpListWrapper = WrapperAttach.getListAttachments(this.id);
            this.listAttachments = new List<WrapperAttach>();

            for (WrapperAttach wr : tmpListWrapper) {
                if (wr.fileAmazon == null || wr.fileAmazon.amazonFile.EF_Private__c == false || this.viewPrivateFiles == true ) {
                    this.listAttachments.add(wr);
                }
            }
            this.listAttachments.sort();

            amazonFileToUpload = null;
        } catch (Exception e ) {
            TransformationHelper.sendEmailSupport('FATAL: EF_AttachmentListController in function refreshList()  ' , 'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
        }
        return null;
    }

    /**
        Get alink to access to an amazon file, this link is time limited
    **/
    @RemoteAction
    global static string getExpiringLink(string fileName ) {

        EF_AttachmentListController.runningForEF = true;

        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
        return link;
    }

    /**
        Delete an attachment archived attachment or Amazon Attachment
    **/
    @RemoteAction
    global static boolean deleteAttachment(string strId, String fullName) {

        EF_AttachmentListController.runningForEF = true;

        String idType = String.ValueOf(Id.valueOf(strId).getSObjectType());
        Boolean result = false;
        if (idType.equals('Attachment')) {
            result = deleteSalesforceAttachment(strId);
        }
        if (idType.equals('Archived_Attachment__c')) {
            result = deleteArchivedAttachment(strId);
        }
        if (idType.equals('AmazonFile__c')) {
            result = deleteAmazonAttachment(strId, fullName);
        }
        //System.debug('EF_AttachmentListController.deleteAttachment: ' + strId + ' object not recognized');
        return result;
    }

    /**
        Delete a standard attachment in Salesforce
    **/
    private static boolean deleteSalesforceAttachment(String id) {
        try {
            delete [SELECT Id  FROM Attachment where Id = :id];
            return true;
        } catch (Exception e) {
            System.debug('EF_AttachmentListController.deleteSalesforceAttachment' + e.getMessage());
            return false;
        }
    }

    /**
        Delete an archived attachment object
    **/
    private static boolean deleteArchivedAttachment(String id) {
        try {
            delete [SELECT Id  FROM Archived_Attachment__c where Id = :id];
            return true;
        } catch (Exception e) {
            System.debug('EF_AttachmentListController.deleteArchivedAttachment' + e.getMessage());
            return false;
        }
    }

    /**
        Delete a file in Amazon Bucket, including AmazonFile object in Amazon
    **/
    private static boolean deleteAmazonAttachment(String strId, String fullName) {
        try {
            Id sObjectId = Id.ValueOf(strId);
            WrapperAttach attach = WrapperAttach.getAmazonAttachment( sObjectId, fullName);
            Boolean result = attach.moveToBucket();
            return result;

        } catch (Exception e) {
            System.debug('EF_AttachmentListController.deleteAmazonAttachment' + e.getMessage());
            return false;
        }
    }

    /**
        Change all Attachments to public
    **/
    public void makeAllPublic() {
        changePermissionToAll(true);
    }

    /**
        Change all Attachments to private
    **/
    public void makeAllPrivate() {
        changePermissionToAll(false);
    }

    /**
        Set the same permission to all attachments
    **/
    private void changePermissionToAll(Boolean value) {
        for ( WrapperAttach attachment : this.listAttachments ) {
            attachment.changePermission(value);
        }
    }

    /**
        redirect to the Trasnfer Attachments page
    **/
    public String getTransferAttachmentsUrl() {
        PageReference pageref = Page.TransferAttachmentToCase;
        pageref.getParameters().put('id', this.Id);
        pageref.setRedirect(true);
        return pageref.getUrl();
    }

    public void callEditAttachment() {

        for ( WrapperAttach attach : listAttachments ) {
            if (attach.id == this.editAttachmentId) {
                this.editAttachment = attach;
                System.debug(loggingLevel.Debug, '____ [cls EF_AttachmentListController - callEditAttachment] editAttachment.fileAmazon.amazonFile.Expired__c - ' + editAttachment.fileAmazon.amazonFile.Expired__c);
                return;
            }
        }
    }

    /**
        Close the edit attachment popup without changes
    **/
    public PageReference cancelPopupAttach() {
        this.editAttachment = null;
        this.editAttachmentId = null;
        return null;
    }

    /**
        Close the edit attachment popup saving changes
    **/
    public PageReference updateAttach() {
        try {
            this.editAttachment.updateAttach();
        } catch (Exception e) {
            System.debug('ERROR updating attachment ' + this.editAttachment);
        }
        return cancelPopupAttach();
    }

    public PageReference goToAttachmentPage() {
        return new Pagereference('/ISSP_AddAttachment?caseId=' + id + '&retURL=%2F' + id);
    }





    @RemoteAction
    global static UploadFile createUploadFile(String id, String filenameupload, String contentType, Long filesize, String folder, String credentialName) {

        EF_AttachmentListController.runningForEF = true;

        AmazonCredentials credential = AmazonCredentials.getCredentials(credentialName);

        // remove all repeated spaces
        String filteredFileName = filenameupload.replaceAll('[ ]+', ' ');

        UploadFile upF = new UploadFile(id, filteredFileName, contentType, folder, credential);

        // check if file exists
        if ( AmazonRest.checkFile( folder + filteredFileName , credential) ) {
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
    global static boolean createAmazonFileObject(String amazonKey, Long filesize, String parentId, String recordType,
            String efCategory, String efSubCategory, String efExpiryDate, Boolean efExpired, String efSapNumber,
            String additionalInformation, Boolean efPrivate) {

        EF_AttachmentListController.runningForEF = true;

        try {
            list<String> parts = amazonKey.split('/');
            String filename = parts.isEmpty() ? '' : parts.get( parts.size() - 1 );

            System.debug(loggingLevel.Debug, '____ [cls EF_AttachmentListController - createAmazonFileObject] efExpiryDate - ' + efExpiryDate);

            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = filename,
                sObject_Id__c = parentId,
                Full_Name_Unique__c = amazonKey,
                Category__c = efCategory,
                Subcategory__c = efSubCategory,
                Document_Date__c = System.today(),
                Expired__c = efExpired,
                Expiry_Date__c = (String.isEmpty(efExpiryDate) ? null : Date.parse(efExpiryDate)),
                SAP_Number__c = efSapNumber,
                Additional_Information__c = additionalInformation,
                EF_Private__c = efPrivate,
                Size_MB__c = filesize * 0.000001 //convert to MB
            );

            if (recordType != null) {
                RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get(recordType.replaceAll('_', ' '));
                if (rtInfo != null) {
                    amazonFile.RecordTypeId = rtInfo .getRecordTypeId();
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
        public String authorization {get; set;}
        public String timestamp {get; set;}
        public String contentType {get; set;}
        public boolean isSuccess {get; set;}
        public String errorMessage {get; set;}

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
            system.debug('@@@timestamp: ' + this.timestamp);
            //this.timestamp = DateTime.now().format();
            String policyString = 'PUT\n\n'
                                  + this.contentType + ';charset=UTF-8\n\n'
                                  + 'x-amz-date:' + this.timestamp + '\n'
                                  + '/' + this.bucketName + '/' + this.fullFileNameEncoded;
            String signedPolicy = AmazonRest.make_sig(policyString, credential);

            this.authorization = 'AWS ' + credential.AWSAccessKeyId + ':' + signedPolicy;
        }
    }

}