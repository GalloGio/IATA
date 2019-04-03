global with sharing class AmazonCertificateListController {

    public static final ID RT_CERTIFICATE_ID = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByDeveloperName().get('Certificate').getRecordTypeId();
    public static String CREDENTIAL_NAME = WrapperAttach.CREDENTIAL_NAME;

    public Account account {get;set;}
    public list<AmazonFile__c> listCertificates {get; set;}

    public AmazonFile__c amazonFileToUpload {
        get{
            if (this.amazonFileToUpload==null) {
                this.amazonFileToUpload = new AmazonFile__c(
                    RecordTypeId = RT_CERTIFICATE_ID,
                    Account__c = this.account.Id
                );
            }
            return this.amazonFileToUpload;
        }
        set;
    }

    /**
        CONTROLLER, expects to have a valid account Id
    **/
    public AmazonCertificateListController(ApexPages.StandardController stdController) {
        try {
            this.account = (Account)stdController.getRecord();
            refreshListCertificates();
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Account Id'));
        }
    }
    
    /**
        Find all certificates linked to the parent account from last 4 years
    **/
    public void refreshListCertificates() {
        this.listCertificates =
            [SELECT Id,Name,RecordTypeId,Full_Name_Unique__c,File_Identifier__c,
            File_Identifier_picklist__c,Source__c, Type__c, Expiry_Date__c,Expired__c,
            CreatedDate, CreatedById
            FROM AmazonFile__c
            WHERE Account__c = :this.account.Id
            AND RecordTypeId = :RT_CERTIFICATE_ID
            AND Expiry_Date__c > :DateTime.now().addYears(-4).dateGMT()
            ];
    }

    /**
        return the credential object to upload a file to amazon in the browser
    **/
    @RemoteAction
    global static WrapperCredential createUploadFile(String id, String filenameupload, String contentType, Long filesize) {
        String folder = WrapperAttach.getAmazonFolder(id);
        UploadMultipleFileToAmazonButtonCtrl.UploadFile uploadFile = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(id, filenameupload, contentType, filesize, folder, CREDENTIAL_NAME);
        
        WrapperCredential credential = new WrapperCredential();
        credential.amazonFilePath = uploadFile.endpoint+uploadFile.bucketName+'/'+uploadFile.fullFileNameEncoded;
        credential.authorization = uploadFile.authorization;
        credential.timestamp = uploadFile.timestamp;
        credential.fullFileName = uploadFile.fullFileName;
        credential.isSuccess = uploadFile.isSuccess;
        credential.errorMessage = uploadFile.errorMessage;
        return credential;
    }

    /**
        Create the AmazonFile__c record representing the file already uploaded in Amazon
    **/
    @RemoteAction
    global static boolean createAmazonFileObject(String amazonKey, Long filesize, String parentId, String expiryDate, String datatype) {
        Savepoint sp = Database.setSavepoint();
        try {
            Account parentAccount = [SELECT Id, Name FROM Account WHERE Id = :parentId];
            
            list<String> parts = amazonKey.split('/');
            String filename = parts.isEmpty() ? '' : parts.get( parts.size() - 1 );
            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = filename,
                RecordTypeId = RT_CERTIFICATE_ID,
                Account__c = parentAccount.Id,
                Full_Name_Unique__c = amazonKey,
                Document_Date__c = System.today(),
                Expiry_Date__c = (String.isEmpty(expiryDate) ? null : Date.parse(expiryDate)),
                Type__c = datatype,
                Size_MB__c = filesize * 0.000001 //convert to MB
            );
            upsert amazonFile;

            return true;
        } catch ( Exception e) {
            Database.rollback( sp );
            System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
            return false;
        }
    }

    /**
        Creates a remporary url to see and downlaod the amazon file
    **/
    public static String TEST_RESULT='';
    @RemoteAction
    global static String getS3Url(String id) {
        try {
            AmazonFile__c amazonFile = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE Id = :id];
            AmazonCredentials credentials = AmazonCredentials.getCredentials(CREDENTIAL_NAME);
            Integer secondsValid = 300;
            return Test.isRunningTest()? TEST_RESULT: AmazonRest.genPublicExpiringAWSLink(amazonFile.Full_Name_Unique__c, credentials, secondsValid);
        } catch (Exception e) {
            System.debug('ERROR in AmazonCertificateListController.getS3Url(' + id + '): ' + e.getMessage());
            return '';
        }
    }
    
    /**
        Wrapper with the info needed to upload a file to Amazon
    **/
    global class WrapperCredential {
        public String amazonFilePath {get;set;}
        public String authorization {get;set;}
        public String timestamp {get;set;}
        public String fullFileName {get;set;}
        public Boolean isSuccess {get;set;}
        public String errorMessage {get;set;}
    }
}