public with sharing class AttachmentListCtrl {
    
    public static final Long MAX_FILE_SIZE = 20971520; // 20 MB
    
    public static final List<String> LST_SAAM_AND_SIDRA_RTYPES_NAME = new List<String>{'ProcessEuropeSCE', 'SIDRA', 'SIDRA_BR', 'SIDRA_BR'};
    
    @AuraEnabled
    public static List<PickListWrapper> getFileIdentifierPickValues(){
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('AmazonFile__c').getDescribe();
        List<Schema.PicklistEntry> pickListValues = sobjectDescribe.fields.getMap().get('File_Identifier_picklist__c').getDescribe().getPickListValues();
        
        List<PickListWrapper> options = new List<PickListWrapper>();
        
        PickListWrapper emptySelection = new PickListWrapper();  
        /*emptySelection.label = '-- Select One --';
        emptySelection.value = null;
        emptySelection.checked = true;
        options.add(emptySelection);*/
        
        for (Schema.PicklistEntry a : pickListValues) {
            PickListWrapper selection = new PickListWrapper();  
            selection.label = a.getLabel();
            selection.value = a.getValue();
            selection.checked = false;
            options.add(selection);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<PickListWrapper> getReviewStatusPickValues(){
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('AmazonFile__c').getDescribe();
        List<Schema.PicklistEntry> pickListValues = sobjectDescribe.fields.getMap().get('Review_Status__c').getDescribe().getPickListValues();
        
        List<PickListWrapper> options = new List<PickListWrapper>();
        
        PickListWrapper emptySelection = new PickListWrapper();  
        /*emptySelection.label = '-- Select One --';
        emptySelection.value = null;
        emptySelection.checked = true;
        options.add(emptySelection);*/
        
        for (Schema.PicklistEntry a : pickListValues) {
            PickListWrapper selection = new PickListWrapper();  
            selection.label = a.getLabel();
            selection.value = a.getValue();
            selection.checked = false;
            options.add(selection);
        }
        return options;
    }

    @AuraEnabled
    public static PropertiesWrapper getPanelProperties(String parentId, Boolean isPortal, String communityName) {
        System.debug('parentId: ' + parentId);
        System.debug('isPortal: ' + isPortal);
        
        PropertiesWrapper propWrapper = new PropertiesWrapper();
        propWrapper.amazonURL = WrapperAttach.CREDENTIAL.EndpointBaseURL + WrapperAttach.CREDENTIAL.Bucket;
        propWrapper.credentialName = WrapperAttach.CREDENTIAL_NAME;
        propWrapper.amazonPath = WrapperAttach.getAmazonFolder(parentId);
        propWrapper.communityName = communityName;
        propWrapper.hasOscar = false;
        propWrapper.isPortal = isPortal;
        

        propWrapper.Id = parentId;
        //Assign the name of the object
        propWrapper.sObjectType = getObjectAPIName(parentId);
        //if is null, is assumed we are working with case
        if(propWrapper.sObjectType=='') propWrapper.sObjectType = 'Case';

        
        // check if current user is Admin
        Profile profile = [Select id, Name from Profile where Id = :UserInfo.getProfileId()];
        propWrapper.isAdminUser = profile.Name.startsWithIgnoreCase('System Administrator') || profile.Name.startsWithIgnoreCase('Developer');
        if(propWrapper.sObjectType=='Case')
	        propWrapper.relatedCase = [Select CaseNumber, Id, parent.OSCAR__c, parent.RecordType__c, parent.RecordTypeId,OSCAR__c from Case where id = :parentId];

        //showFileIdentifier
        propWrapper.showFileIdentifier = false; //default
        if (isPortal) {
            propWrapper.showFileIdentifier = false;
            if(propWrapper.sObjectType=='Case')
           		propWrapper.cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :parentId];
        } else {
        	if(propWrapper.sObjectType=='Case'){
	            // check if case is in recordtypes SAAM (ProcessEuropeSCE) or Oscar Communication
	            propWrapper.cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :parentId];
	            set<String> setRecordTypes = new set<String>{'ProcessEuropeSCE','OSCAR_Communication'};
	            propWrapper.showFileIdentifier = setRecordTypes.contains(propWrapper.cse.Recordtype.DeveloperName);
        	}
        }
        
        //canAttachFilesToCase
        propWrapper.canAttachFilesToCase = false; //Default
		if(propWrapper.sObjectType!='Case') propWrapper.canAttachFilesToCase = false;
		
        if((propWrapper.cse.Status != 'Draft' && propWrapper.cse.Status != 'Open - EDMC') || 
           ((propWrapper.cse.Reason1__c == 'New SA / CHV – New Code' || propWrapper.cse.Reason1__c == 'CLO - Closure') && propWrapper.cse.Status == 'Draft')) {
            propWrapper.canAttachFilesToCase = true;
        } else {
            propWrapper.canAttachFilesToCase = false;
        }
        
        //parentIsOSCAR
        propWrapper.parentIsOSCAR = false; //Default
        if(propWrapper.sObjectType!='Case') propWrapper.parentIsOSCAR = false;
    	
        if(propWrapper.relatedCase.parent.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')) {
            propWrapper.parentIsOSCAR = true;
        } else {
            propWrapper.parentIsOSCAR = false;
        }
        
        //check if is saam or sidra record type
		propWrapper.isSAAMorSIDRA = [SELECT Count() FROM Case WHERE Id = :parentId AND RecordType.DeveloperName IN :LST_SAAM_AND_SIDRA_RTYPES_NAME] > 0 ;
        System.debug('isSAAMorSIDRA: ' + propWrapper.isSAAMorSIDRA);
        
        return propWrapper;
    }

    @AuraEnabled
    public static List<WrapperAttach> getAllAttachmentsByParentIdAndPortal(String parentId, Boolean isPortal, Boolean isSAAMorSIDRA) {
    //public static List<WrapperAttach> getAllAttachments(String parentId, Boolean isPortal) {
        System.debug('parentId: ' + parentId);
        System.debug('isPortal: ' + isPortal);
        System.debug('isSAAMorSIDRA: ' + isSAAMorSIDRA);

        List<WrapperAttach> listAttachments;
        try {
            
            if(isSAAMorSIDRA){
                if (isPortal) {
                    listAttachments = WrapperAttach.getListAttachmentsForPortal(parentId);
                } else {
                    listAttachments = WrapperAttach.getListAttachments(parentId);
                }
            }else{
                Boolean fullAttachmentAccess = AttachmentListCtrl.checkIfUSerHaveFullAccess();
                listAttachments = new List<WrapperAttach>();
                if(fullAttachmentAccess){
                    //Get attachments 
                    List<Attachment> lstAttachAux = [SELECT IsPrivate, Id, ParentId, OwnerId, Name, CreatedById, CreatedBy.Name, LastModifiedDate, BodyLength, 
                                                     LastModifiedById, CreatedDate, Description, ContentType
                                                     FROM Attachment WHERE ParentId = :parentId AND (NOT Name LIKE 'TMP_FINANCIAL_2DELETE%') ORDER BY CreatedDate DESC ];
                    Set <Id> setAttachIds = new Set <Id>();
                    
                    if (lstAttachAux != null && !lstAttachAux.isEmpty()){
                        for (Attachment attachAux : lstAttachAux){
                            setAttachIds.add(attachAux.Id);
                        }
                        //Get public permissions for attachments
                        List <ISSPAttachmentPermission__c> permList = [SELECT Id, AttachmentId__c, ShowToPortalUsers__c
                                                                       FROM ISSPAttachmentPermission__c
                                                                       WHERE AttachmentId__c IN :setAttachIds];
                        Map<Id,ISSPAttachmentPermission__c> mapAttachIdAndPermission = new Map<Id,ISSPAttachmentPermission__c>();
                        if (permList != null && !permList.isEmpty()){
                            for (ISSPAttachmentPermission__c thisPerm : permList){
                                mapAttachIdAndPermission.put(thisPerm.AttachmentId__c, thisPerm);
                            }
                        }
                        
                        for(Attachment attachAux : lstAttachAux){
                            listAttachments.add(new WrapperAttach(attachAux, mapAttachIdAndPermission.get(attachAux.Id)));
                        }
                    }
                    //get amazon attachments
                    String folder = AttachmentListCtrl.getAmazonFolder(parentId);            
                    list<AmazonRest.S3File> listS3Files = AmazonRest.getListFiles(folder, AmazonCredentials.getCredentials('GenericAttach'));
                    list<AmazonFile> listAmazonfiles = AmazonFile.getFiles( parentId, listS3Files);
                    if(listAmazonfiles != null && !listAmazonfiles.isEmpty()){
                        for(AmazonFile file: listAmazonfiles){
                            listAttachments.add(new WrapperAttach(file));
                        }
                    }
                    
                    //get archived attachments
                    List<Archived_Attachment__c> lstArchivedAttach = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id, BodyLength__c, 
                                                                      Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c, Originally_created_by__c 
                                                                      FROM Archived_Attachment__c 
                                                                      WHERE Case__c = :parentId AND ArchivedMessage__c = null ORDER BY Original_Creation_Date__c DESC];
                    if(lstArchivedAttach != null && !lstArchivedAttach.isEmpty()){
                        for(Archived_Attachment__c attachAux : lstArchivedAttach){
                            listAttachments.add(new WrapperAttach(attachAux));
                        }
                    }
                        
                }else{
                    //reserved for portal users attachments list retrive. 
                    //It's possibly the same as the above but just for salesforce attach and archived attach
                }
                
            }
            
            
			//listAttachments.sort();
		} catch (Exception e ) {
			//TransformationHelper.sendEmailSupport('FATAL: GenericAttachmentListController in function refreshList()  ' ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
		}
		return listAttachments;
    }
    
    private static Boolean checkIfUSerHaveFullAccess(){
        List<AttachmentListLimitedAccess__c> perms = [SELECT SetupOwnerId , Name, Id FROM AttachmentListLimitedAccess__c 
                                                      WHERE SetupOwnerId = :userinfo.getProfileId() OR SetupOwnerId = :userinfo.getUserId()];
       	return perms.size() == 0;
    }
    
    private static String getAmazonFolder(Id sobjectId) {
        String suffix = String.ValueOf(sobjectId).substring(0,3);
        return '' + suffix + '/' + String.valueOf(sobjectId) + '/';
    }
    
    @AuraEnabled
    public static ReturnWrapper changeAttachVisibility(String parentId, String attachId, Boolean isPortal, Boolean isSAAMorSIDRA){
        ReturnWrapper returnWrapper = new ReturnWrapper();
        
        try{
            List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA);
            WrapperAttach wrapperAttachAux = null;
            for(Integer i = 0; i<lstattachWrapper.size(); i++){
                if(lstattachWrapper.get(i).id == attachId){
                    wrapperAttachAux = lstattachWrapper.get(i);
                    break;
                }
            }
            wrapperAttachAux.changePermission();
            
            returnWrapper.severity = 'SUCCESS';
        }catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
    }
    
    @AuraEnabled
    public static ReturnWrapper updateAttachment(String parentId, String attachId, Boolean isPortal, String description, String fileIdentifier, String reviewStatus, Boolean isSAAMorSIDRA){
        System.debug('parentId: ' + parentId);
        System.debug('attachId: ' + attachId);
        System.debug('isPortal: ' + isPortal);
        System.debug('description: ' + description);
        System.debug('fileIdentifier: ' + fileIdentifier);
        System.debug('reviewStatus: ' + reviewStatus);
        
        ReturnWrapper returnWrapper = new ReturnWrapper();
        
        try{
            List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA);
            WrapperAttach wrapperAttachAux = null;
            for(Integer i = 0; i<lstattachWrapper.size(); i++){
                if(lstattachWrapper.get(i).id == attachId){
                    wrapperAttachAux = lstattachWrapper.get(i);
                    break;
                }
            }
            wrapperAttachAux.Description = description;
            wrapperAttachAux.fileAmazon.amazonFile.File_Identifier_picklist__c = fileIdentifier;
            wrapperAttachAux.fileAmazon.amazonFile.Review_Status__c = reviewStatus;
            
            wrapperAttachAux.updateAttach();
            
            returnWrapper.severity = 'SUCCESS';
        }catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
    }
    
    @AuraEnabled
    public static String getTransferAttachmentsUrl(String parentId) {
		PageReference pageref = Page.TransferAttachmentToCase;
		pageref.getParameters().put('id',parentId);
		pageref.setRedirect(true);
		return pageref.getUrl();
	}
    
    @AuraEnabled
    public static ReturnWrapper makeAllAttachPrivate(String parentId, Boolean isPortal, Boolean isSAAMorSIDRA){
        ReturnWrapper returnWrapper = new ReturnWrapper();
        
        try{
            List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA);
            for(Integer i = 0; i<lstattachWrapper.size(); i++){
                lstattachWrapper.get(i).changePermission(false);
            }
            
            returnWrapper.severity = 'SUCCESS';
        }catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
    }
    
    @AuraEnabled
    public static ReturnWrapper makeAllAttachPublic(String parentId, Boolean isPortal, Boolean isSAAMorSIDRA){
        ReturnWrapper returnWrapper = new ReturnWrapper();
        
        try{
            List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA);
            for(Integer i = 0; i<lstattachWrapper.size(); i++){
                lstattachWrapper.get(i).changePermission(true);
            }
            
            returnWrapper.severity = 'SUCCESS';
        }catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
    }
    
    @AuraEnabled
	public static ReturnWrapper deleteAttachment(String attachId, String fullName) {
		String objectName = String.ValueOf(Id.valueOf(attachId).getSObjectType());
		ReturnWrapper returnWrapper = new ReturnWrapper();
		if (objectName.equals('Attachment')) {
			returnWrapper = deleteSalesforceAttachment(attachId);
		}
		if (objectName.equals('Archived_Attachment__c')) {
			returnWrapper = deleteArchivedAttachment(attachId);
		}
		if (objectName.equals('AmazonFile__c')) {
			returnWrapper = deleteAmazonAttachment(attachId, fullName);
		}

		return returnWrapper;
	}
    
    @AuraEnabled
	public static string getExpiringLink(String fileName ) {
		Integer secondsValid = 300;
		String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
		return link;
	}

	/**
		Delete a standard attachment in Salesforce
	**/
	private static ReturnWrapper deleteSalesforceAttachment(String id) {
        ReturnWrapper returnWrapper = new ReturnWrapper();
		try {
			delete [SELECT Id  FROM Attachment where Id=:id];
			returnWrapper.severity = 'SUCCESS';
		} catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
	}

	/**
		Delete an archived attachment object
	**/
	private static ReturnWrapper deleteArchivedAttachment(String id) {
        ReturnWrapper returnWrapper = new ReturnWrapper();
		try {
			delete [SELECT Id  FROM Archived_Attachment__c where Id=:id];
			returnWrapper.severity = 'SUCCESS';
		} catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
	}

	/**
		Delete a file in Amazon Bucket, including AmazonFile object in Amazon
	**/
	private static ReturnWrapper deleteAmazonAttachment(String strId, String fullName) {
        ReturnWrapper returnWrapper = new ReturnWrapper();
		try {
			Id sObjectId = Id.ValueOf(strId);
			WrapperAttach attach = WrapperAttach.getAmazonAttachment( sObjectId, fullName);
			Boolean result = attach.moveToBucket();
            if(result){
                returnWrapper.severity = 'SUCCESS';
            }
		} catch (Exception e ) {
            returnWrapper.extraDetails = e.getMessage() + '';
		}        
        return returnWrapper;
	}
    
    //Return the API Name of the object of the ID received in input
    public static string getObjectAPIName(id theObjId){
    	if(theObjId == null){
    		return '';
    	}else{
    		try{
	    		return theObjId.getSObjectType().getDescribe().getName();
    		}catch(exception e){
    			return '';
    		}
    	}
    }
    
    @AuraEnabled
    public static list<FileDef> getAllExpiringLink(String objectId, Boolean isPortal) {
        list<WrapperAttach> listAttach = new list<WrapperAttach>();
        if (isPortal) {
            listAttach = WrapperAttach.getListAttachmentsForPortal(objectId);
        } else {
            listAttach = WrapperAttach.getListAttachments(objectId);
        }
        list<FileDef> listFileDef = new list<FileDef>();
        for (WrapperAttach attach: listAttach) {
            FileDef filedef = new FileDef();
            filedef.name = attach.name;
            filedef.url = getExpiringLink(attach.fullName);
            filedef.data = '';
            listFileDef.add(filedef);
        }
        return listFileDef;
    }
    
    public class FileDef {
        @AuraEnabled
        String name {get; set;}
        @AuraEnabled
        String url {get; set;}
        @AuraEnabled
        String data {get; set;}
        
        public FileDef(){}
    }
    
    public class ReturnWrapper {
        @AuraEnabled
        String severity {get; set;}
        @AuraEnabled
        String extraDetails {get; set;}
        
        public ReturnWrapper(){
            this.severity = 'ERROR';
            this.extraDetails = '';
        }
    }
    
    public class PropertiesWrapper{
        
        @AuraEnabled
        String amazonURL {get; set;}
        @AuraEnabled
       	String uploader {get;set;} //discontinued
     	@AuraEnabled
        String source {get;set;} //discontinued
        @AuraEnabled
    	Boolean scroll {get;set;} //discontinued
	 	@AuraEnabled
		String credentialName {get;set;}
		@AuraEnabled
        String amazonPath {get; set;}
		//new CNS
		@AuraEnabled
        String communityName{get; set;} //discontinued
		
		@AuraEnabled
		Boolean isAdminUser {get; set;}
        @AuraEnabled
	 	Boolean showFileIdentifier {get; set;}
        @AuraEnabled
		Boolean canAttachFilesToCase {get; set;}
        @AuraEnabled
        Boolean parentIsOSCAR {get; set;}

        @AuraEnabled
        Boolean hasOscar {get; set;}
    
        @AuraEnabled
        String sObjectType{get; set;}	//stores the API name of the object we are looking the attachments for
	
        @AuraEnabled
        Boolean isPortal{get; set;} //discontinued
        
		@AuraEnabled
		Id id {get; set;} //discontinued
        @AuraEnabled
        Case relatedCase {get; set;}
        @AuraEnabled
        Case cse {get; set;}
        @AuraEnabled
        public Boolean showAttachFileButton {get; set;} //discontinued
        
        @AuraEnabled
        Boolean isSAAMorSIDRA{get; set;}
        
        public PropertiesWrapper(){}
    }
    
    public class PickListWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean checked;
        
        public PickListWrapper (){}
    }
    
    @AuraEnabled
    public static UploadFile createUploadFile(String id, String filenameupload, String contentType, Long filesize, String folder, String credentialName) {
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
    
    /**
        Class to manage the upload of a file to Amazon
        It manages the key and signature to do a callout
    **/
    public class UploadFile {
		@AuraEnabled
        public String endpoint {get; set;}
        @AuraEnabled
        public String bucketName {get; set;}
        @AuraEnabled
        public String fullFileName {get; set;}
        @AuraEnabled
        public String fullFileNameEncoded {get; set;}
        @AuraEnabled
        public String authorization {get;set;}
        @AuraEnabled
        public String timestamp {get;set;}
        @AuraEnabled
        public String contentType {get; set;}
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
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
    
    @AuraEnabled
    public static boolean createAmazonFileObject(String amazonKey, Long filesize, String parentId, String recordType, String fileIdentifierPick, String source) {
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
            }//Fix: use sObject_id__c field!
            else
                amazonFile.sObject_Id__c = parentId;
            
            upsert amazonFile;

            return true;
        } catch ( Exception e) {
            System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
            return false;
        }
    }


}