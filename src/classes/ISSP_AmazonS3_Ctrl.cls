global class ISSP_AmazonS3_Ctrl {
    public static final String SEPARATOR = '/';
    private static string FOLDER_STEM = '500/';
    private static string AMAZON_CREDENTIALS_NAME = 'GenericAttach';  //Name of Amazon Cred custom setting record that points to AWS Credentials
    public final boolean PORTALUSER= UserInfo.getUserType() <> 'PowerPartner'?  false : true;

    public String policy {get; set;}
    public String signedPolicy {get; set;}
    public String actionStatus {get; set;}
    public String accessid {get; set;}
    public String allowedExtensions {get; set;}  //Regular expression
    public String maxFileSize {get; set;}
    public String caseStatus;

    String storageFolder;
    String uniqueFileNames;

    public Id id {get; set;}

    public STATIC FINAL String DEFAULT_MAX_FILESIZE = '25';
    public STATIC FINAL String DEFAULT_ALLOWED_EXTS = 'pdf';

    public List<String> reqIdentifierList {get; set;}
    public list<AmazonFile> listFile {get; set;}
    public Map<String, list<AmazonFile>> fileMap {get; set;}
    public Map<String, list<AmazonFileAMS>> amazonFileMap {get; set;}
    public Map<String, boolean> reviewStatusMap {get; set;}
    private Map<String,String> mapUniqueFileList;

    public String currentFileName {get; set;}
    public String uploadedFileName {get; set;}
    public Long uploadedFileSize {get; set;}
    public String uploadedFileIdentifier {get; set;}
    public string message {get; private set;}
    public boolean archived {get; private set;}

    private Case cse;
    private Account acc {get;set;}

    public string AMAZONURL{get; private set;}

    public static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME);

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public ISSP_AmazonS3_Ctrl(){
        AMAZONURL  =
                AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             +  AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;
        system.debug('aqui ApexPages.currentPage() ' + ApexPages.currentPage());
        if(ApexPages.currentPage().getParameters().containsKey('caseId')){
            id = ApexPages.currentPage().getParameters().get('caseId');
        }

        system.debug('ON 1 ID: ' + id);

        if(id== null)
         return;

        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];

        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;

        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');

        //this.refreshListDoc();
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
     }

     public ISSP_AmazonS3_Ctrl(ApexPages.StandardController stdController) {
        AMAZONURL  =
                AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             +  AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;
        this.cse = (Case)stdController.getRecord();
        this.Id = this.cse.Id;

        if(this.id== null)
            return;

        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];

        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;

        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');

        //this.refreshListDoc();
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
     }


    public ISSP_AmazonS3_Ctrl(ISSP_AMS_Accreditation amsCtrl) {
        this.Id = amsCtrl.newCase.Id;

        if(this.id== null)
        return;

        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];

        AMAZONURL  =
                AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             +  AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;

        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;

        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');

        //this.refreshListDoc();
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
    }

    public ISSP_AmazonS3_Ctrl(ISSP_ANG_PCI pciCtrl){
        system.debug('aqui ISSP_AmazonS3_Ctrl pci ' + pciCtrl.newCase.Id);
        this.Id = pciCtrl.newCase.Id;

        if(this.id== null)
        return;

        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];

        AMAZONURL  =
                AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             +  AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;

        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;

        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
    }

    public ISSP_AmazonS3_Ctrl(ISSP_ModelA_Onboarding modelACtrl){
        //system.debug('aqui ISSP_AmazonS3_Ctrl pci ' + modelACtrl.onBoardingOSCARCase.Id);
        this.Id = modelACtrl.onBoardingOSCARCase.Id;
        
        if (this.id == null) return;
        
        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];
        
        AMAZONURL = AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             + AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;
        
        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;
        
        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');        
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
    }

    public ISSP_AmazonS3_Ctrl(ISSP_AddAttachment amsCtrl) {
        this.Id = amsCtrl.tmpCase.Id;

        if(this.id== null)
        return;

        this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
                 account.IATA_ISO_Country__r.iso_code__c ,
                 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
                 Reason1__c, CaseArea__c, Owner.Name
                 from Case where id = : this.id];

        AMAZONURL  =
                AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL
             +  AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;

        allowedExtensions = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;
        maxFileSize = ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;

        this.actionStatus = '201';
        accessid =  CREDENTIALS.AWSAccessKeyId;
        calculePolicy('');
        //this.refreshListDoc();
        this.refreshAmazonFileMap();
        this.refreshReviewStatusMap();
    }

    public String getStorageFolder() {
        system.debug('aqui getStorageFolder ...');
        Id idVal;
        String FOLDER = FOLDER_STEM;

        idVal = cse.Id;
        return FOLDER + String.valueOf(idVal) + '/';
    }

    public String getCaseStatus() {
        return this.cse.Status;
    }

    public Boolean getCaseOwnerNewgenPCI() {
        return this.cse.Owner.Name.startsWith('NewGen PCI');
    }

    public Boolean getCaseOwnerModelA() {
        return this.cse.Owner.Name.startsWith('Model A Onboarding');
    }

    private static String make_sig(string canonicalBuffer) {
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(CREDENTIALS.Secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(CREDENTIALS.Secret));
        macUrl = EncodingUtil.base64Encode(mac);
        return macUrl;
    }

    public void calculePolicy(String contentType) {
            datetime expire = system.now().addDays(1);
            String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+
            expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';

            Integer amazonS3MaxFileSize = Integer.valueOf(ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c);

            String policyString =
                        '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
                        CREDENTIALS.Bucket +'" } ,'+
                        // '{"content-type":"application/pdf"},'+
                       //'{"content-type": "' + contentType + '" },'+
                       '{"acl":"private"},'+
                       '{"success_action_status": "' + actionStatus + '" },'+
                        '["starts-with", "$key", ""] ]}';
                        //'["content-length-range", 0, 10485760] ]}'; // 10 megabyte
                        //'["content-length-range", 0, "' + amazonS3MaxFileSize + '"] ]}';
            policy = EncodingUtil.base64Encode(Blob.valueOf(policyString));
            signedPolicy = make_sig(EncodingUtil.base64Encode(Blob.valueOf(policyString)));
        }

    /**
        Get the information of files linked to current case stored in S3 bucket
    **/
    /**
    public Pagereference refreshListDoc() {
        String FOLDER = getStorageFolder();
        String folderName = '';
        String reqIdentifier = '';

        map<String,AmazonFile__c> mapAmazonFiles = getMapAmazonFile();

        system.debug('id before: ' + id);
        system.debug('cse: ' + cse);

        system.debug('Storage FOLDER: ' + FOLDER);

        list<AmazonRest.S3File> dirtyList = AmazonRest.getListFiles(FOLDER,CREDENTIALS);
        this.listFile = new list<AmazonFile>();

        system.debug('listFile: ' + listFile);
        fileMap = new Map<String, list<AmazonFile>>();
        reqIdentifierList = new List<String>();
        for(AmazonRest.S3File s3File : dirtyList ){
            String name = s3File.getname();
            AmazonFile newAmazonFile;
            SYSTEM.debug('Amazon S3 Full Name:' + s3File.getFullName());
            AmazonFile__c amazonFile = mapAmazonFiles.get(s3File.getFullName());
            if(amazonFile != null) {  //AmazonFile already exists for this file in Amazon S3
                newAmazonFile = new AmazonFile( s3File, amazonFile);
                reqIdentifier = newAmazonFile.getFileIdentifier();

                listFile.add(newAmazonFile);
            } else if(uploadedFileName!=null) { //AmazonFile does not exist for this file on upload (STEP D) so need to create it
                amazonFile = new AmazonFile__c(
                Name = uploadedFileName,
                Full_Name_Unique__c = FOLDER + uploadedFileName,
                File_Identifier__c = uploadedFileIdentifier,
                Size_MB__c = uploadedFileSize* 0.000001, //convert to MB
                isPublic__c = true,
                Case__c = Id
                );

                try {
                    insert amazonFile;
                } catch(DmlException ex) {
                    ApexPages.addMessages(ex);
                }

                newAmazonFile = new AmazonFile( s3File, amazonFile);
                reqIdentifier =  uploadedFileIdentifier;
                listFile.add(newAmazonFile);
            }

            if (fileMap.containsKey(reqIdentifier)){
                fileMap.get(reqIdentifier).add(newAmazonFile);
            } else {
                fileMap.put(reqIdentifier, new List<AmazonFile>{newAmazonFile});
                reqIdentifierList.add(reqIdentifier);
            }

        }

        return null;
    }
**/

    private map<String,AmazonFile__c> getMapAmazonFile() {
        System.DEBUG('Get File Map Case Id: ' + this.cse.Id);

        list<AmazonFile__c> listAmazonFile = [
            Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c, Review_Status__c
            From AmazonFile__c
            Where Case__c = :this.cse.Id AND isPublic__c = true
        ];

        SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

        map<String,AmazonFile__c> mapAmazonFile = new map<String,AmazonFile__c>();
        for ( AmazonFile__c amazonFile: listAmazonFile) {
            mapAmazonFile.put(amazonFile.Full_Name_Unique__c, amazonFile);
        }
        return mapAmazonFile;
    }

    public map<String, List<AmazonFileAMS>> refreshAmazonFileMap() {

        list<AmazonFile__c> listAmazonFile = [
            Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c, Review_Status__c
            From AmazonFile__c
            Where Case__c = :this.cse.Id AND isPublic__c = true AND Review_Status__c != 'Rejected Closed'
        ];

        SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

        amazonFileMap = new Map<String, list<AmazonFileAMS>>();
        AmazonFileAMS newAmazonFile;
        reqIdentifierList = new List<String>();

        for ( AmazonFile__c amazonFile: listAmazonFile) {

            newAmazonFile = new AmazonFileAMS(amazonFile);

            if (amazonFileMap.containsKey(amazonFile.File_Identifier__c)){
                amazonFileMap.get(amazonFile.File_Identifier__c).add(newAmazonFile);
            } else {
                amazonFileMap.put(amazonFile.File_Identifier__c, new List<AmazonFileAMS>{newAmazonFile});
                reqIdentifierList.add(amazonFile.File_Identifier__c);
            }
        }

        SYSTEM.DEBUG('REQ IDENTIFIER SIZE' + reqIdentifierList.size());
        return amazonFileMap;
    }

    public map<String, Boolean> refreshReviewStatusMap() {

        reviewStatusMap = new Map<String, Boolean>();

        for ( String identifier: amazonFileMap.keySet()) {
            Boolean isLocked = true;
            for(AmazonFileAMS amazonFile:amazonFileMap.get(identifier)){
                if(amazonFile.getStatus()=='Rejected'){
                    isLocked = false;
                    break;
                }
            }
            reviewStatusMap.put(identifier,isLocked);
        }

        reviewStatusMap.put('PORTAL_CASE_DIRECT',false);

        SYSTEM.DEBUG('Review Status Map Size' + reviewStatusMap.size());
        return reviewStatusMap;
    }


    public void deleteThisFile(){
        system.debug('currentFileName: ' + currentFileName);
        AmazonRest.deleteFile(currentFileName,CREDENTIALS );

        List <AmazonFile__c> fileToDelete = [SELECT Id FROM AmazonFile__c WHERE Full_Name_Unique__c = :currentFileName];
        if (!fileToDelete.isEmpty()){
            delete fileToDelete;
        }

        //refreshListDoc();
    }

    public void refreshAfterDelete(){
        AmazonRest.deleteFile(currentFileName,CREDENTIALS );
        refreshAmazonFileMap();
        refreshReviewStatusMap();
        //refreshListDoc();
    }

    @remoteAction
    global static string getExpiringLinkIfap(string fileName ) {
        return  genPublicExpiringAWSLinkIFAP( CREDENTIALS.Bucket + SEPARATOR ,fileName);
    }

    private static string genPublicExpiringAWSLinkIFAP(string path, string filename){

        string  stringToSplit = '/'+filename;
        list<string> splittedName = stringToSplit.split('/');
        splittedName.remove(0);
        string encoded;
        for(string dirNm:splittedName)
            encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
        encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');

        Decimal timeInMili = Math.floor(System.now().getTime()/1000)+300;
        string check = string.valueof(timeInMili);
        if(check.indexOf('E') <> -1)    {
            check =check.substring(0,check.indexOf('E')).replace('.', '');
            check +='9';
        }
        long timeOut= Long.ValueOf(check);

        string stringToSign = 'GET\n\n\n' + timeOut+ '\n/' + path+ encoded ;//+ filename;
        string signature = make_sig(stringToSign);
        string queryString = '?AWSAccessKeyId=' + CREDENTIALS.AWSAccessKeyId + '&Expires=' + timeOut+ '&Signature=' + signature;


        PageReference page = new PageReference(CREDENTIALS.EndpointBaseURL + path+encoded );
        map<String,String> params = page.getParameters();
        params.put('AWSAccessKeyId', CREDENTIALS.AWSAccessKeyId);
        params.put('Expires', String.ValueOf(timeOut));
        params.put('Signature', signature);

        String result = page.getUrl();
       //  throw new transformationexception(''+result);
        system.debug('stringToSign  '+  stringToSign + '  queryString  ' + queryString + '   result '  + result );

        return   result ;
     }

    public boolean canUploadAndDelete {
        get {
            Case thiscse = [Select id, Status from Case where id = :cse.id];
            /*return (thiscse.Status.equals('Agent Notified (Mail)') ||
                    thiscse.Status.equals('Agent Notified (Email)') ||
                    thiscse.Status.equals('Financial Statements Uploaded') ||
                    thiscse.Status.equals('Sanity Check Failure'));*/
            return true;
            }
        set;
         }

    public String getUniqueFileNames() {
         String ufn;

        //Get File identifiers for AmzonFile records assoc. with case
        list<AmazonFile__c> listAmazonFile = [
            Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c, Review_Status__c
            From AmazonFile__c
            Where Case__c = :cse.Id
        ];

        SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

        for ( AmazonFile__c amazonFile: listAmazonFile) {
            String name = amazonFile.Name;
            SYSTEM.DEBUG('REMOTE File Name:' + name);
                if(ufn==null) {
                    ufn = name;
                } else {
                    ufn = ufn + ',' + name;
                }
        }

        return ufn;
    }


     public void createAmazonFileObject() {
        String FOLDER = getStorageFolder();
        String folderName = '';
        String fullName;

        System.DEBUG('Storage FOLDER: ' + FOLDER);

        try {

            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = uploadedFileName,
                Full_Name_Unique__c = FOLDER + uploadedFileName,
                File_Identifier__c = uploadedFileIdentifier,
                File_Identifier_picklist__c = uploadedFileIdentifier,
                Review_Status__c = 'Pending',
                RecordTypeId = Schema.SObjectType.AmazonFile__c.RecordTypeInfosByName.get('AMS File').RecordTypeId,
                Size_MB__c = uploadedFileSize* 0.000001, //convert to MB
                isPublic__c = true,
                Case__c = Id
            );
            insert amazonFile;

            if(cse.Status!='Draft') {
                cse.New_interaction__c = 'New Attachment';
                cse.New_Attachment_From_Portal_User__c = true;
                update cse;
            }

            refreshAmazonFileMap();
            refreshReviewStatusMap();
        } catch ( Exception e) {
            System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
        }
    }

    public class AmazonFileAMS {

        //private AmazonRest.S3File s3File;
        public AmazonFile__c amazonFile;

        public AmazonFileAMS(AmazonFile__c aFile ) {
            this.amazonFile = afile;
        }

        public String getName() {
            return this.amazonFile.Name;
        }

        public String getFullName() {
            return this.amazonFile.Full_Name_Unique__c;
        }

        public String getStatus() {
            return this.amazonFile.Review_Status__c;
        }
    }

}