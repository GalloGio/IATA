global class AMS_OSCAR_Attachments {
    
    private Boolean canAttachFiles;
    private Case cse;

    public Boolean isAdminUser {get; set;}
    public Boolean isReadOnly {get; set;}
    public Boolean isEmbedded {get; set;}

    /*** AMSU-154 ***/
    public Id caseOwnerId {get;set;}

    public Id caseId{
        get{
            return cse.Id;
        }
    }
    

    public List<WrapperAttach> listAttachments {
        get{
            if(listAttachments == null) refreshList();
            return listAttachments;
        }
        set;
    }

    public List<String> emptyList{
        get{
            return new List<String>{ 'No records to display'};
        }
    }

    public String amazonURL  {
        get { return WrapperAttach.CREDENTIAL.EndpointBaseURL + WrapperAttach.CREDENTIAL.Bucket; }
    }
    public String credentialName  {
        get { return WrapperAttach.CREDENTIAL_NAME; }
    }
    public String amazonPath  {
        get { return WrapperAttach.getAmazonFolder(this.cse.Id); }
    }

    private List<ErrorMessageConstruct> errorMessages{
        get{
            if(errorMessages == null) errorMessages = new List<ErrorMessageConstruct>();
            return errorMessages;
        }
        set;
    }

    private void logMessage(ApexPages.Message message){
        errorMessages.add(new ErrorMessageConstruct(message));
    }

    private class ErrorMessageConstruct{
        ApexPages.Severity severity;
        String message;

        public ErrorMessageConstruct(ApexPages.Message message){
            this.severity = message.getSeverity();
            this.message = message.getSummary();
        }
    }

    public AMS_OSCAR_Attachments() {

        String sObjId = ApexPages.currentPage().getParameters().get('Id');
        // CB - 6 APR 2017 - AMS Enhancements AMSU-2 //AMSU-154 added ownerId
        cse = [Select Id, Status, ParentId, Parent.RecordType.Name, OwnerId from Case where OSCAR__c = :sObjId AND RecordType.Name = 'OSCAR Communication']; // AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) ];
        /*** AMSU-154 ***/
        AMS_OSCAR__c oscar = [SELECT Id, Process__c, AMS_Online_Accreditation__c, OwnerId FROM AMS_OSCAR__c WHERE Id = :sObjId];
        // for child cases in banck account details changes OSCARs show the attachments on the parent case (the HO case)
        if (cse.ParentId != null && cse.Parent.RecordType.Name == 'OSCAR Communication' && oscar.Process__c == AMS_Utils.BANKACCCHANGES && oscar.AMS_Online_Accreditation__c == null) {
            cse = [SELECT Id, Status FROM Case WHERE Id = :cse.ParentId];
        }

        // check if current user is Admin
        Profile profile = [Select id, Name from Profile where Id = :UserInfo.getProfileId()];
        this.isAdminUser = profile.Name.startsWithIgnoreCase('System Administrator') || profile.Name.startsWithIgnoreCase('Developer');

        isReadOnly = ApexPages.currentPage().getParameters().get('readOnly') == 'true' ? true : false;
        isEmbedded = ApexPages.currentPage().getParameters().get('isEmbedded') == 'true' ? true : false;

        /*** AMSU-154 ***/
        caseOwnerId = cse.OwnerId;
    }

    /*
        Refresh the list of file attachments
    */
    public void refreshList() {
        try {
            this.listAttachments = WrapperAttach.getListAttachments(this.cse.id);
            this.listAttachments.sort();
        } catch (Exception e ) {
            TransformationHelper.sendEmailSupport('FATAL: GenericAttachmentListController in function refreshList()  ' ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
            logMessage(new ApexPages.message(ApexPages.Severity.WARNING, e.getMessage()));
        }

        for(ErrorMessageConstruct message : errorMessages) ApexPages.addMessage(new ApexPages.message(message.severity, message.message));
        errorMessages.clear();
    }

    /*
        Get alink to access to an amazon file, this link is time limited
    */
    @RemoteAction
    global static string getExpiringLink(string fileName ) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
        return link;
    }

    webService static string getExpiringLinkWS(string fileName ) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
        return link;
    }

    /*
        Delete an attachment archived attachment or Amazon Attachment
    */
    @RemoteAction
    global static Boolean deleteAttachment(string strId, String fullName) {
        Schema.SObjectType attType = Id.valueOf(strId).getSObjectType();
        Boolean result = false;
        if (attType == Schema.Attachment.SObjectType) {
            result = deleteSalesforceAttachment(strId);
        }
        if (attType == Schema.Archived_Attachment__c.SObjectType) {
            result = deleteArchivedAttachment(strId);
        }
        if (attType == Schema.AmazonFile__c.SObjectType) {
            result = deleteAmazonAttachment(strId, fullName);
        }
        //System.debug('GenericAttachmentListController.deleteAttachment: ' + strId + ' object not recognized');
        return result;
    }
    
    /*
        Delete a standard attachment in Salesforce
    */
    private static Boolean deleteSalesforceAttachment(String id) {
        try {
            delete [SELECT Id  FROM Attachment where Id=:id];
            return true;
        } catch (Exception e) {
            System.debug('GenericAttachmentListController.deleteSalesforceAttachment' + e.getMessage());
            return false;
        }
    }
    
    /*
        Delete an archived attachment object
    */
    private static Boolean deleteArchivedAttachment(String id) {
        try {
            delete [SELECT Id  FROM Archived_Attachment__c where Id=:id];
            return true;
        } catch (Exception e) {
            System.debug('GenericAttachmentListController.deleteArchivedAttachment' + e.getMessage());
            return false;
        }
    }
    
    /*
        Delete a file in Amazon Bucket, including AmazonFile object in Amazon
    */
    private static Boolean deleteAmazonAttachment(String strId, String fullName) {
        try {
            Id sObjectId = Id.ValueOf(strId);
            WrapperAttach attach = WrapperAttach.getAmazonAttachment( sObjectId, fullName);
            Boolean result = attach.moveToBucket();
            return result;
            
        } catch (Exception e) {
            System.debug('GenericAttachmentListController.deleteAmazonAttachment' + e.getMessage());
            return false;
        }
    }
    
    /*
        Change all Attachments to public
    */
    public void makeAllPublic() {
        changePermissionToAll(true);
    }
    
    /*
        Change all Attachments to private
    */
    public void makeAllPrivate() {
        changePermissionToAll(false);
    }
    
    /*
        Set the same permission to all attachments
    */
    private void changePermissionToAll(Boolean value) {
        for ( WrapperAttach attachment: this.listAttachments ) {
            attachment.changePermission(value);
        }
    }
    
    /*
        redirect to the Trasnfer Attachments page
    */
    public String getTransferAttachmentsUrl() {
        PageReference pageref = Page.TransferAttachmentToCase;
        pageref.getParameters().put('id',this.cse.Id);
        pageref.setRedirect(true);
        return pageref.getUrl();
    }

    public void updateAllAttach(){
        try{
            for(WrapperAttach att : listAttachments){
                att.updateAttach();
            }
            logMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Attachments updated'));
        }catch(Exception e){
            logMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error updating attachments: '+ e.getMessage()));
        }
        
    }
    
    
    public Boolean getCanAttachFilesToCase() {
        if(cse.Status != 'Draft') {
            return true;
        } else {
            return false;
        }
    }
    
    public PageReference goToAttachmentPage() {
        return new Pagereference('/ISSP_AddAttachment?caseId=' + this.cse.id + '&retURL=%2F' + this.cse.id);
    }
    
    /**
        get a list of files with valid links to download them from Amazon
    **/
    @RemoteAction
    global static list<FileDef> getAllExpiringLink(String objectId) {
        list<FileDef> listFileDef = new list<FileDef>();
        for (WrapperAttach attach: WrapperAttach.getListAttachments(objectId, true)) {
            FileDef filedef = new FileDef();
            filedef.name = attach.name;
            if (attach.fileType == 'Amazon') {
                filedef.url = getExpiringLink(attach.fullName);
                filedef.data='';
                listFileDef.add(filedef);
            }
            if (attach.fileType == 'Salesforce') {
                filedef.url='';
                filedef.data= EncodingUtil.base64Encode(attach.fileAttachment.Body);
                listFileDef.add(filedef);
            }
        }
        return listFileDef;
    }
    
    /**
        get a list of files with valid links to download them from Amazon
    **/
    @RemoteAction
    global static list<FileDef> getSelectedExpiringLink(String objectId, String[] attachmentIds) {
        set<String> setAttachmentIds = new set<String>();
        setAttachmentIds.addAll(attachmentIds);
        
        list<FileDef> listFileDef = new list<FileDef>();
        for (WrapperAttach attach: WrapperAttach.getListAttachments(objectId, true)) {
            if(setAttachmentIds.contains(attach.Id)) {
                FileDef filedef = new FileDef();
                filedef.name = attach.name;
                if (attach.fileType == 'Amazon') {
                    filedef.url = getExpiringLink(attach.fullName);
                    filedef.data='';
                    listFileDef.add(filedef);
                }
                if (attach.fileType == 'Salesforce') {
                    filedef.url='';
                    filedef.data= EncodingUtil.base64Encode(attach.fileAttachment.Body);
                    listFileDef.add(filedef);
                }
            }
        }
        return listFileDef;
    }

    /*** AMSU-168 ***/
    public PageReference acceptFiles() {
        for(WrapperAttach attach : listAttachments) {            
            if(attach.isSelected) {
                attach.reviewStatus = 'Accepted';
                attach.isSelected = false;
            }
        }
        return null;
    }

    public PageReference rejectFiles() {
        for(WrapperAttach attach : listAttachments) {            
            if(attach.isSelected) {
                attach.reviewStatus = 'Rejected';
                attach.isSelected = false;
            }
        }
        return null;
    }

    global class FileDef {
        String name;
        String url;
        String data;
    }
}