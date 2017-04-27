/**
*
* This controller is used to viey a list of archived attachmednt either from a Case ( show Attachments related to the case himself) 
* or from a Archive Message
*
*/
global   class  ArchiveAttachmentListController {



    private String aCaseId ;
    private String  aMessageId;
    public  boolean  aStandardRedirect  {get; set;}
    public list<Archived_Attachment__c> archivedAttachments;
    public list<Attachment> sfdcAttachments {get; set;}
    public map<String,AWSKey__c> awsBucketUrl {get; set;}
    public boolean hasAttachment{get; set;} 
    public Boolean fullAttachmentAccess {get; set;}
    public List<attachWrapper> sfdcAttachmentList {get; set;} //TF - SP8-US196
    public list<WrapperAttach> listAmazon {get; set;}

    public Boolean hasOscar{
        get{
            if(hasOscar == null) hasOscar = false;
            return hasOscar;
        }
        private set;
    }

    public Case relatedCase {
        get; 
        set{
            relatedCase = value;
            hasOscar = String.isNotEmpty(relatedCase.OSCAR__c);
        }
    }
    
    public Id id {
        get;
        set {
            if (this.Id == null ) {
                this.Id = value;
                //loadAttachmentFromCaseId();
            }
        }
    }
    
    public ArchiveAttachmentListController() {
       awsBucketUrl = new Map<String,AWSKey__c >();
       list<AttachmentListLimitedAccess__c> perms = [select SetupOwnerId , Name, Id from AttachmentListLimitedAccess__c where SetupOwnerId = :userinfo.getProfileId() or SetupOwnerId = :userinfo.getUserId()];
       fullAttachmentAccess = perms.size()==0;
       //fullAttachmentAccess = !hasUserLimitedPermissions();
    }
    
    
    
    public List<Archived_Attachment__c> getArchivedAttachments(){
        if(this.archivedAttachments ==null){
            if(aCaseId ==null) loadAttachmentsFromEmailMessage();
            else loadAttachmentFromCaseId();
        }
        return this.archivedAttachments;
    }
    
    @TestVisible
    private void loadAttachmentFromCaseId(){
    // this.listAmazon.clear();
            this.relatedCase = [Select  CaseNumber, Id, OSCAR__c from Case where Id = :aCaseId];
             system.debug('loadAttachmentFromCaseId '+aCaseId );
            this.sfdcAttachments = [SELECT IsPrivate, Id, ParentId, OwnerId, Name, CreatedById, CreatedBy.Name, LastModifiedDate, BodyLength, 
                        LastModifiedById, CreatedDate, Description, ContentType
                         FROM Attachment where ParentId = :aCaseId and (not name  like  'TMP_FINANCIAL_2DELETE%' )  order by CreatedDate desc ];
            
            //TF - SP8-US196
            Set <Id> attachIds = new Set <Id>();
            Map <Id, Id> attachPermMap = new Map <Id, Id>();
            Map <Id, Id> attachMap = new Map <Id, Id>();
            sfdcAttachmentList = new List<attachWrapper>();
            if (!sfdcAttachments.isEmpty()){
                for (Attachment thisAttach : sfdcAttachments){
                    attachMap.put(thisAttach.Id, thisAttach.Id);
                    attachIds.add(thisAttach.Id);
                }
                List <ISSPAttachmentPermission__c> permList = [SELECT Id, AttachmentId__c, ShowToPortalUsers__c
                                                            FROM ISSPAttachmentPermission__c
                                                            WHERE AttachmentId__c IN :attachIds];
                if (!permList.isEmpty()){
                    for (ISSPAttachmentPermission__c thisPerm : permList){
                        if (!thisPerm.ShowToPortalUsers__c){
                            attachPermMap.put(thisPerm.AttachmentId__c, thisPerm.AttachmentId__c);
                        }
                    }
                }
                for (Attachment thisAttach : sfdcAttachments){
                    if (!attachPermMap.containsKey(thisAttach.Id)){
                        attachWrapper attachWrapperRecord = new attachWrapper();
                        attachWrapperRecord.recordAttachment = thisAttach;
                        attachWrapperRecord.isPrivate = false;
                        sfdcAttachmentList.add(attachWrapperRecord);
                    }
                    else if (fullAttachmentAccess){
                        attachWrapper attachWrapperRecord = new attachWrapper();
                        attachWrapperRecord.recordAttachment = thisAttach;
                        attachWrapperRecord.isPrivate = true;
                        sfdcAttachmentList.add(attachWrapperRecord);
                    }
                }
            }
        
                if(this.listAmazon == null || this.listAmazon.isEmpty()){
                        this.listAmazon = getAmazonAttachments(aCaseId);
                        system.debug('FirstList: ' + this.listAmazon);
                }
            
            
            //this.sfdcAttachments = getAttachmentByCase(aCaseId, !fullAttachmentAccess);
            this.archivedAttachments  = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id, BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c, Originally_created_by__c FROM Archived_Attachment__c where Case__c= :aCaseId and ArchivedMessage__c = null order by Original_Creation_Date__c desc];
            for(Archived_Attachment__c a:this.archivedAttachments){
               if(!awsBucketUrl.containskey(a.Bucket__c)){
                    AWSKey__c keysSet = [SELECT Name, Key__c, Secret__c, Id, AWS_ENDPOINT_URL__c, Bucket__c FROM AWSKey__c where Bucket__c = :a.Bucket__c limit 1];
                    awsBucketUrl.put(a.Bucket__c, keysSet);
                    system.debug('add to map new bucket '+a.Bucket__c);
               }
            }
            this.hasAttachment = (this.archivedAttachments.size() + this.sfdcAttachments.size() + this.listAmazon.size())>0;
    
    }
    
    @TestVisible
    private void loadAttachmentsFromEmailMessage(){
            this.awsBucketUrl = new Map<String,AWSKey__c >();
            system.debug('loadAttachmentsFromEmailMessage '+aMessageId  );
            this.archivedAttachments  = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id,BodyLength__c, Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c, Originally_created_by__c FROM Archived_Attachment__c where ArchivedMessage__c= :aMessageId order by Original_Creation_Date__c desc ];
            for(Archived_Attachment__c a:this.archivedAttachments){
                if(!awsBucketUrl.containskey(a.Bucket__c))
                    loadAWSCrendtial(a.Bucket__c);
                    system.debug('add to map new bucket '+a.Bucket__c);
            }
            this.relatedCase = [Select  CaseNumber, Id, OSCAR__c from Case where Id in (select Case__c from Archived_Message__c where Id = :aMessageId) limit 1];
            this.sfdcAttachments = new List<Attachment>();
            this.hasAttachment =  this.archivedAttachments.size()>0;
    
    }
    
    private void loadAWSCrendtial(String bucketName){
           AWSKey__c keysSet = [SELECT Name, Key__c, Secret__c, Id, AWS_ENDPOINT_URL__c, Bucket__c FROM AWSKey__c where Bucket__c = :bucketName limit 1];
           awsBucketUrl.put(bucketName, keysSet);
    }
   
    public void setACaseId(String s) {
       if(s!=null && !s.equals('')){
            this.aCaseId = s;
            this.aMessageId    = null;
            loadAttachmentFromCaseId();
       }
    }
    
    public String getAMessageId () {
        return aMessageId  ;
    }

    public void setAMessageId (String s) {
       if(s!=null && !s.equals('')){
            this.aMessageId   = s;
            this.aCaseId = null;
            loadAttachmentsFromEmailMessage();
       }
    }
 
    public String getACaseId() {
        return aCaseId ;
    }
    //AEF:
    public Pagereference refreshList() { 
      //  this.listAmazon.clear();
        loadAttachmentFromCaseId();
         //this.listAmazon = getAmazonAttachments(aCaseId);
        if(!this.listAmazon.isEmpty()){
            this.listAmazon.clear();
            this.listAmazon = getAmazonAttachments(aCaseId);
        }
         
        return null;
    }
    
    
    public static Boolean hasUserLimitedPermissions() {
        return
            [SELECT Id 
               FROM AttachmentListLimitedAccess__c 
              WHERE SetupOwnerId = :Userinfo.getProfileId()
                 OR SetupOwnerId = :Userinfo.getUserId()].size() > 0;
        
    }     
    
    public static list<Attachment> getAttachmentByCase(ID caseId, Boolean publicOnly) {
        
        return 
            [SELECT  Id,  Name, 
                     BodyLength, 
                     CreatedById, 
                     CreatedDate, 
                     ContentType, 
                     Description,
                     IsPrivate, 
                     LastModifiedDate, 
                     LastModifiedById,
                     OwnerId, 
                     ParentId,
                     CreatedBy.Name 
               FROM Attachment 
              WHERE ParentId = :caseId and  (not name  like  'TMP_FINANCIAL_2DELETE%' )
                AND (IsPrivate =: false OR IsPrivate =: (!publicOnly))  
           order by CreatedDate desc ];
    }
    
    //TF - SP8-US196
    public String attId {get;set;}
    public Boolean makePrivate {get;set;}
    public void actionAttachmentPermission (){
        List <ISSPAttachmentPermission__c> listPerm = [SELECT Id, ShowToPortalUsers__c
                                                    FROM ISSPAttachmentPermission__c
                                                    WHERE AttachmentId__c = :attId];
        if (!listPerm.isEmpty()){
            if (makePrivate){
                if (listPerm[0].ShowToPortalUsers__c){
                    listPerm[0].ShowToPortalUsers__c = false;
                    update listPerm[0];
                }
            }
            else{
                if (!listPerm[0].ShowToPortalUsers__c){
                    listPerm[0].ShowToPortalUsers__c = true;
                    update listPerm[0];
                }
            }
        }
        else{
            ISSPAttachmentPermission__c newPerm = new ISSPAttachmentPermission__c();
            newPerm.AttachmentId__c = attId;
            if (makePrivate){
                newPerm.ShowToPortalUsers__c = false;
            }
            else{
                newPerm.ShowToPortalUsers__c = true;
            }
            insert newPerm;
        } 
    }
    
     public static String getAmazonFolder(Id sobjectId) {
        String suffix = String.ValueOf(sobjectId).substring(0,3);
        return '' + suffix + '/' + String.valueOf(sobjectId) + '/';
    }
    
     private static list<WrapperAttach> getAmazonAttachments(Id sobjectId) {
        list<WrapperAttach> listAmazon = new list<WrapperAttach>();
        try {        
            String folder = getAmazonFolder(sobjectId);            
            list<AmazonRest.S3File> listS3Files = AmazonRest.getListFiles(folder, AmazonCredentials.getCredentials('GenericAttach'));
            list<AmazonFile> listAmazonfiles = AmazonFile.getFiles( sobjectId, listS3Files);
            for(AmazonFile file: listAmazonfiles){
                listAmazon.add(new WrapperAttach(file));
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return listAmazon;
    }
    
    public String getTransferAttachmentsUrl() {
        PageReference pageref = Page.TransferAttachmentToCase;
        pageref.getParameters().put('id',this.aCaseId);
        pageref.setRedirect(true);
        return pageref.getUrl();
    }
    
    //TF - SP8-US196
    public class attachWrapper {
        public Boolean isPrivate {get; set;}
        public Attachment recordAttachment {get; set;}
    }
    
    @RemoteAction
    global static string getExpiringLink(string fileName ) {
        Integer secondsValid = 300;
        String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
        return link;
    }
    
    @RemoteAction
    global static boolean deleteAttachmentAmazon(string strId, String fullName) {
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
}