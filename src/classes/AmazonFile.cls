public class AmazonFile {

    private AmazonRest.S3File s3File;
    @AuraEnabled
    public AmazonFile__c amazonFile{get;set;}

    public AmazonFile(AmazonRest.S3File s3File, AmazonFile__c aFile ) {
        this.s3File = s3File;
        this.amazonFile = afile;
    }

    public Id getId() {
        return this.amazonFile == null? null: this.amazonFile.Id;
    }
    
    public double getSize() {
        return this.s3File.getSize();
    }
    
    public String getName() {
        return this.s3File.getName();
    }
    
    public String getDescription() {
        return amazonFile==null? '': this.amazonFile.Description__c;
    }
    
    public String getInternalComments() {
        return amazonFile==null? '': this.amazonFile.Internal_Comments__c;
    }

    //used to set the Name in AmazonFile Recods used in ICE Service WMO-358
    public static String ICE_proofOfPayment{
        get{
            return 'ICE POP';
        }
    }

    public String getFullName() {
        return this.s3File.getFullName();
    }

    public DateTime getLastModifiedDate() {
        return amazonFile==null? this.s3File.getLastModified(): this.amazonFile.CreatedDate;
    }

    public String getLastModified() {
        return getLastModifiedDate().format();
    }

    public DateTime getCreatedDate() {
        try {
            //EM: Need to take into account the user locale: compute offset from GMT
            DateTime now = DateTime.now();
            Long offset = (DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime())/(3600*1000);
            return amazonFile == null? null: this.amazonFile.CreatedDate;
        } catch (Exception e) {
            return null;
        }
    }

    public String getCreatedBy() {
        return amazonFile == null? null: this.amazonFile.CreatedBy.Name;
    }

    public String getCreatedById() {
        return amazonFile == null? null: this.amazonFile.CreatedById;
    }
    
    public Boolean getIsPublic() {
        return amazonFile == null? false: this.amazonFile.isPublic__c;
    }
    
    public String getFileIdentifier() {
        return amazonFile == null? null: this.amazonFile.File_Identifier__c;
    }
    
    public String getSource() {
        return amazonFile == null? null: this.amazonFile.Source__c;
    }
    
    public String getFileIdentifierPick() {
        return amazonFile == null? null: this.amazonFile.File_Identifier_picklist__c;
    }
    
    public String getReviewStatus() {
        return amazonFile == null? null: this.amazonFile.Review_Status__c;
    }
    
    public String getRecordTypeId() {
        return amazonFile == null? null: this.amazonFile.RecordTypeId;
    }
    
    public String getRecordTypeDeveloperName() {
        return amazonFile == null? null: this.amazonFile.RecordType.DeveloperName;
    }

    public String getEFCategory() {
        return amazonFile==null? '': this.amazonFile.Category__c;
    }

    public String getEFSubcategory() {
        return amazonFile==null? '': this.amazonFile.Subcategory__c;
    }

    public String getEFSAPNumber() {
        return amazonFile==null? '': this.amazonFile.SAP_Number__c;
    }

    public Date getEFDocumentDate() {
        return amazonFile==null? null: this.amazonFile.Document_Date__c;
    }

    public Date getEFExpiryDate() {
        return amazonFile==null? null: this.amazonFile.Expiry_Date__c;
    }

    public Boolean getEFExpired() {
        return amazonFile==null? null: this.amazonFile.Expired__c;
    }

    public Boolean getEFPrivate() {
        return amazonFile==null? null: this.amazonFile.EF_Private__c;
    }

    public Boolean getEFSkipValidation() {
        return amazonFile==null? null: this.amazonFile.Skip_Validation__c;
    }
    
    /*** AMSU-139 ***/
    public String getUpdatedBy() {
        return amazonFile==null? null: this.amazonFile.AMS_Updated_By__c;
    }

    public Datetime getUpdatedDate() {
        return amazonFile==null? null: this.amazonFile.AMS_Updated_Date__c;
    }
        
    // for compatibility with AmazonFinancial.page
    public PageReference deleteFile() {
        delFile();
        return null;
    }
    
    public Boolean delFile() {
        Boolean result = this.s3File.deleteFile();
        if ( result ) {
            deleteAmazonFile();
        }
        return result;
    }

    public void deleteAmazonFile() {
        try {
            if (amazonFile != null) {
                delete amazonFile;
            }
        } catch (Exception e) {
            System.debug('Error deleting amazon file ' + amazonFile);
        }
    }
    
    public void changePermission() {
        if (amazonFile != null) {
            amazonFile.isPublic__c = !amazonFile.isPublic__c;
            update amazonFile;
        }
    }
    
    public void changePermission(Boolean value) {
        if (amazonFile != null && amazonFile.isPublic__c != value ) {
            amazonFile.isPublic__c = value;
            update amazonFile;
        }
    }
    
    public Boolean copyFile( AmazonCredentials sourceCredentials, AmazonCredentials destCredentials, String destinationFilename) {
        String sourceFilename = this.amazonFile.Full_Name_Unique__c;
        Boolean result = AmazonRest.copyFile(sourceCredentials, sourceFilename, destCredentials, destinationFilename);
        return result;
    }
    

    /** STATIC METHODS **/

    /**
        Get a all AmazonFiles from an Object
    **/
    public static list<AmazonFile> getFiles(Id sobjectId, list<AmazonRest.S3File> listS3Files) {
        map<String,AmazonFile__c> mapAmazonFiles = getMapAmazonFiles(sobjectId);
        //list<AmazonFile__c> listNewAmazonFile = new list<AmazonFile__c>();
        list<AmazonFile> listResultFiles = new list<AmazonFile>();
        
        for (AmazonRest.S3File s3File: listS3Files) {
            AmazonFile__c amazonFile = mapAmazonFiles.get(s3File.getKey());
            if ( amazonFile == null ) {
                amazonFile = createAmazonFile(s3File);
                //listNewAmazonFile.add(amazonFile);
            }
            listResultFiles.add( new AmazonFile(s3File, amazonFile) );
        }
        //if(!listNewAmazonFile.isEmpty()) insert listNewAmazonFile;
        return listResultFiles;
    }
    
    /**
        Get a single file AmazonFile Object
    **/
    public static AmazonFile getFile(Id sobjectId, String fullName, AmazonCredentials credential) {
        try {
            // find the file in the Amazon Bucket
            list<AmazonRest.S3File> listS3Files = AmazonRest.getListFiles(fullName, WrapperAttach.CREDENTIAL);
            if ( listS3Files.size() != 1 ) {
                System.debug('Error finding a file in Amazon: ' + fullName + ' ' + credential + '\nresult: ' + listS3Files);
                return null;
            }
            AmazonRest.S3File s3File = listS3Files.get(0);
            
            //get the amazonFile Object
            AmazonFile__c aFile;
            list<AmazonFile__c> aFiles = [
                Select Id, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c, isPublic__c, Description__c, File_Identifier__c,
                File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, RecordType.DeveloperName, Internal_Comments__c, 
                Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c,SAP_Number__c, Skip_Validation__c,
                Additional_Information__c, EF_Private__c, AMS_Updated_By__c, AMS_Updated_Date__c
                From AmazonFile__c 
                Where id = :sobjectId
            ];
            
            if ( aFiles.isEmpty() ) {
                aFile = createAmazonFile(s3File);
            } else {
                aFile = aFiles.get(0);
            }
            
            AmazonFile amazonFile = new AmazonFile(s3File, aFile);
            return amazonFile;
            
        } catch ( Exception e) {
            System.debug('Error creating an AmazonFile object ' + fullName + ' ' + credential + '\nerror: ' + e.getMessage());
            return null;
        }
    }
    
    /**
        Creates an AmazonFile__c object with input S3File object
    **/
    private static AmazonFile__c createAmazonFile(AmazonRest.S3File s3File) {
        AmazonFile__c amazonFile = new AmazonFile__c();
        amazonFile.Full_Name_Unique__c = s3File.getKey();
        amazonFile.Name = s3File.getName();
        amazonFile.isPublic__c = false;
        return amazonFile;
    }

    /**
        Returns a map of all AmazonFile__c related to an object with Full_Name_Unique__c as key
    **/
    private static map<String,AmazonFile__c> getMapAmazonFiles(Id sobjectId) {
        //the sObjectId received in input is 15 digits
        //However, the sObject_Id__c field value might be 15 or 18.. when is 18, records are not found
        //this trick queries for both 15 and 18 digits value
        set<string> setIds = new set<string>();
        if(sobjectId!=null){
            string sIdString = sobjectId;
            setIds.add(sIdString);
            setIds.add(sIdString.left(15));
        }
        
        list<AmazonFile__c> listFiles = new list<AmazonFile__c>();
        // for cases
        if (String.ValueOf(sobjectId.getSObjectType()) == 'Case' && !EF_AttachmentListController.runningForEF) {
            listFiles = [
                Select Id, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c, isPublic__c, Description__c, File_Identifier__c,
                File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, RecordType.DeveloperName, Internal_Comments__c,
                Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c, SAP_Number__c, Skip_Validation__c,
                Additional_Information__c, EF_Private__c, AMS_Updated_By__c, AMS_Updated_Date__c
                From AmazonFile__c
                Where Case__c = :sobjectId
            ];
        }
        
        if (EF_AttachmentListController.runningForEF || String.ValueOf(sobjectId.getSObjectType()) != 'Case') {
            listFiles = [
                Select Id, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c, isPublic__c, Description__c, File_Identifier__c,
                File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, RecordType.DeveloperName, Internal_Comments__c, 
                Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c, SAP_Number__c, Skip_Validation__c,
                Additional_Information__c, EF_Private__c, AMS_Updated_By__c, AMS_Updated_Date__c
                From AmazonFile__c
                Where sObject_Id__c in :setIds
            ];
        }
        
        map<String,AmazonFile__c> mapFiles = new map<String,AmazonFile__c>();
        for (AmazonFile__c file: listFiles) {
            mapFiles.put(file.Full_Name_Unique__c, file);
        }
        return mapFiles;
    }

    /**
	Returns a list of all AmazonFile__c related to an Account Object and a specific Name
	WMO-358
    **/
    public static List<AmazonFile__c> getAccountRelatedAmazonFiles(Id sobjectId, String amazonFileName)
    {
        List<AmazonFile__c> accountlistFiles = new List<AmazonFile__c>();

        accountlistFiles=[Select Id, Name, Full_Name_Unique__c, Account__c, CreatedDate,
                          CreatedById, CreatedBy.Name, Case__c, isPublic__c, Description__c, File_Identifier__c,
                          File_Identifier_picklist__c, Review_Status__c, Source__c, RecordTypeId, RecordType.DeveloperName, Internal_Comments__c,
                          Document_Date__c, Category__c, Subcategory__c, Expiry_Date__c, Expired__c, SAP_Number__c, Skip_Validation__c,
                          Additional_Information__c, EF_Private__c, AMS_Updated_By__c, AMS_Updated_Date__c
                          From AmazonFile__c
                          Where Account__c = :sobjectId
                          And Name =: amazonFileName];

        return accountlistFiles;

    }
}