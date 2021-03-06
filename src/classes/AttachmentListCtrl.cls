public with sharing class AttachmentListCtrl {

	public static final Long MAX_FILE_SIZE = 20971520; // 20 MB

	public static final List<String> LST_SAAM_AND_SIDRA_RTYPES_NAME = new List<String>{'ProcessEuropeSCE', 'SIDRA', 'SIDRA_BR', 'SIDRA_BR'};
	public static final List<String> LST_SAAM_AND_SIDRA_OSCAR_RTYPES_NAME = new List<String>{'ProcessEuropeSCE', 'SIDRA', 'SIDRA_BR', 'OSCAR_Communication'};



	@AuraEnabled
	public static List<CSP_Utils.PickListWrapper> FileIdentifierPickValues{
		get{
			if(FileIdentifierPickValues==null){
				FileIdentifierPickValues=CSP_Utils.getPickListValues('AmazonFile__c','File_Identifier_picklist__c');
			}
			return FileIdentifierPickValues;
		}
		set;
	}


	@AuraEnabled
	public static List<CSP_Utils.PickListWrapper> ReviewStatusPickValues{
		 get{
			if(ReviewStatusPickValues==null){
				FileIdentifierPickValues=CSP_Utils.getPickListValues('AmazonFile__c','Review_Status__c');
			}
			return FileIdentifierPickValues;
		}
		set;
	}

	@AuraEnabled
	public static List<CSP_Utils.PickListWrapper> getFileIdentifierPickValues(){
		return AttachmentListCtrl.FileIdentifierPickValues;
	}


	@AuraEnabled
	public static List<CSP_Utils.PickListWrapper> getReviewStatusPickValues(){
		return AttachmentListCtrl.ReviewStatusPickValues;
	}


	@AuraEnabled
	public static PropertiesWrapper getPanelProperties(String parentId, Boolean isPortal, String communityName) {

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
			propWrapper.relatedCase = [Select CaseNumber, Id, parentId,parent.OSCAR__c, parent.RecordType__c, parent.RecordTypeId,OSCAR__c from Case where id = :parentId];

		//showFileIdentifier
		propWrapper.showFileIdentifier = false; //default
		if (isPortal) {
			propWrapper.showFileIdentifier = false;
			if(propWrapper.sObjectType=='Case')
		   		propWrapper.cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :parentId];
		} else {
			if(propWrapper.sObjectType=='Case'){
				// check if case is in recordtypes SAAM (ProcessEuropeSCE) or Oscar Communication
				propWrapper.cse = [Select Recordtype.DeveloperName, parentId,Status, Reason1__c FROM Case where id = :parentId];
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
		propWrapper.isSAAMorSIDRA = checkIfSidraSaam(parentId) ;

		return propWrapper;
	}

	@AuraEnabled
	public static boolean checkIfSidraSaam(string caseId){
		return [SELECT Count() FROM Case WHERE Id = :caseId AND RecordType.DeveloperName IN :LST_SAAM_AND_SIDRA_RTYPES_NAME] > 0 ;

	}

	@AuraEnabled
	public static boolean checkIfSidraSaamOSCAR(string caseId){
		//returns true if case record type is sidra/saam/oscar
		//used to redirect to correct page to add attachments
		return [SELECT Count() FROM Case WHERE Id = :caseId AND RecordType.DeveloperName IN :LST_SAAM_AND_SIDRA_OSCAR_RTYPES_NAME] > 0 ;

	}

	@AuraEnabled(cacheable=false)
	public static List<WrapperAttach> getAllAttachmentsByParentIdAndPortalLightning(string parentId, boolean isPortal, boolean isSAAMorSIDRA,boolean withBody) {
		return getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA, withBody); 
	}

	@AuraEnabled(cacheable=true)
	public static List<ReturnWrapper> getAllAttachmentsPortal(string parentId, boolean isPortal, boolean isSAAMorSIDRA,boolean withBody) {
		list<WrapperAttach> wrapperAttachList= getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA, withBody);
		list<ReturnWrapper> returnList=new list<ReturnWrapper>();
		for(wrapperAttach wa:wrapperAttachList){
			returnList.add(new ReturnWrapper(wa));
		}
		return returnList;
	}

	@AuraEnabled(cacheable=true)
	public static List<WrapperAttach> getAllAttachmentsByParentIdAndPortal(string parentId, boolean isPortal, boolean isSAAMorSIDRA,boolean withBody) {
	//public static List<WrapperAttach> getAllAttachments(String parentId, Boolean isPortal) {
		System.debug('parentId: ' + parentId);
		System.debug('isPortal: ' + isPortal);
		System.debug('isSAAMorSIDRA: ' + isSAAMorSIDRA);

		List<WrapperAttach> listAttachments;
		try {
			if (isPortal) {
					listAttachments = WrapperAttach.getListAttachmentsForPortal(parentId);
			} else {
				if(isSAAMorSIDRA){
					listAttachments = WrapperAttach.getListAttachments(parentId);
				} else {
					Boolean fullAttachmentAccess = AttachmentListCtrl.checkIfUSerHaveFullAccess();
					listAttachments = new List<WrapperAttach>();
					if(fullAttachmentAccess){
						//Get attachments
						List<Attachment> lstAttachAux = [SELECT IsPrivate, Id, ParentId, OwnerId, Name, CreatedById, CreatedBy.Name, LastModifiedDate, BodyLength,
														LastModifiedById, CreatedDate, Description, ContentType,body
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

						//get archived attachments Silenced for lightning migration
						/*List<Archived_Attachment__c> lstArchivedAttach = [SELECT AWS_S3_URL__c, Name, ArchivedMessage__c, Bucket__c, Case__c, Id, BodyLength__c,
																		Original_Creation_Date__c, OriginalCreatedBy__c, ContentType__c, Originally_created_by__c
																		FROM Archived_Attachment__c
																		WHERE Case__c = :parentId AND ArchivedMessage__c = null ORDER BY Original_Creation_Date__c DESC];*/
					   /* if(lstArchivedAttach != null && !lstArchivedAttach.isEmpty()){
							for(Archived_Attachment__c attachAux : lstArchivedAttach){
								listAttachments.add(new WrapperAttach(attachAux));
							}
						}*/

						listAttachments.addAll(WrapperAttach.getContentAttachments(parentId,isPortal,false,null));
					}
				}
			}
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
	public static List<ReturnWrapper> getContentDetails(list<id> attachList){
	//generates link to be externally acessible
		set<id> attachSet= new set<id>(attachList);

		list<ContentDistribution> linkList= new list<ContentDistribution>();
		set<id> lastVersionIdSet= new set<id>();
		for(ContentDocument cd :WrapperAttach.getContentDocInfo(attachSet)){
			lastVersionIdSet.add(cd.LatestPublishedVersionId);
		}
		
		list<wrapperAttach> wrapperList= WrapperAttach.getContentInfo(lastVersionIdSet);
		list<ReturnWrapper> returnList=new list<ReturnWrapper>();
		for(wrapperAttach wra:wrapperList){
			returnList.add(new ReturnWrapper(wra));
		}
		//gets file details
		return returnList;
	}

	@AuraEnabled
	public static ReturnWrapper changeAttachVisibility(String parentId, String attachId, Boolean isPortal, Boolean isSAAMorSIDRA){
		ReturnWrapper returnWrapper = new ReturnWrapper();

		try{
			List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA,false);
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
			List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA,false);
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
			List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA,false);
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
			List<WrapperAttach> lstattachWrapper = getAllAttachmentsByParentIdAndPortal(parentId, isPortal, isSAAMorSIDRA,false);
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
		if (objectName.equals('ContentDocument')) {
			returnWrapper = deleteContentAttachment(attachId);
		}

		return returnWrapper;
	}

	@AuraEnabled
	public static string getExpiringLink(String fileName ) {
		Integer secondsValid = 300;
		String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
		return link;
	}

	 @AuraEnabled
	public static string getExpiringLinkWithRecId(String recId ) {
		Integer secondsValid = 300;
		String link='';
		if(String.isblank(recId)) return '';

		Id idRec =Id.valueOf(recId);
		Schema.SObjectType recObjTp = idRec.getSObjectType();


		if(recObjTp ==Schema.AmazonFile__C.getSObjectType() ){  // IF amazon file record
			AmazonFile__c amazonFile = [select Full_Name_Unique__c from AmazonFile__C where id=:idRec];

			link = AmazonRest.genPublicExpiringAWSLink( amazonFile.Full_Name_Unique__c, WrapperAttach.CREDENTIAL, secondsValid);
		}else if(recObjTp ==Schema.ContentDocument.getSObjectType()){ // If content document file
		   ContentDocument cd=[select title,LatestPublishedVersionId  from ContentDocument where id =:idRec];

		   //generates temporary link
		   ContentDistribution cdist= CSP_Utils.getContentDistribution(cd.title,cd.LatestPublishedVersionId);
		   link= cdist.DistributionPublicUrl;
		}
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

	private static ReturnWrapper deleteContentAttachment(String id) {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		try {
			delete [SELECT Id  FROM ContentDocument where Id=:id];
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
		public @testvisible String severity {get; set;}
		@AuraEnabled
		public String extraDetails {get; set;}

		
		@AuraEnabled 
		public string name{get; set;}
		@AuraEnabled 
		public Decimal size{get; set;}
		@AuraEnabled 
		public Datetime createdDate{get; set;}
		@AuraEnabled 
		public string sfdcContext{get; set;}
		@AuraEnabled 
		public string viewURL{get; set;}
		@AuraEnabled 
		public string id{get; set;}
		
		public ReturnWrapper(){
			this.severity = 'ERROR';
			this.extraDetails = '';
		}

		public ReturnWrapper(WrapperAttach wa){
			this.name= wa.name;
			this.size= wa.size;
			this.createdDate= wa.createdDate;
			this.sfdcContext= wa.sfdcContext;
			this.viewURL= wa.viewURL;
			this.id= wa.id;
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

	@AuraEnabled
	public static list<CaseWrapper> getParentCaseRelatedCases(string parentId,string caseId){
	   list<CaseWrapper> lstRelatedCases = new list<CaseWrapper>();

		for (Case c : [SELECT Id, ParentId, CaseNumber, Status, Subject, Account.Name, Owner.Name, RecordType.Name, CreatedDate
								FROM Case
								WHERE Id <> :caseId AND (
								Id = :parentId
								OR (ParentId <> null    AND ParentId = :parentId)
								OR ParentId = :caseId) ]) {
			CaseWrapper cw = new CaseWrapper();
			cw.CaseRecord = c;
			cw.isSelected = false;

			if ( c.Id == parentId)           cw.strRelationship = 'Parent';
			else if (c.ParentId == caseId)       cw.strRelationship = 'Child';
			else if (c.ParentId == parentId) cw.strRelationship = 'Sibling';

			lstRelatedCases.add(cw);
		}

		return lstRelatedCases;
	}


	@AuraEnabled
	public static ApexMessageHandling transferAttachments(string selIdAttachmentStr,string targetSingleCase,string targetCaseStr,string parentId,boolean isPortal,boolean isSAAMorSIDRA,string caseParentId) {


		// Save new attachments
		Integer success = 0;
		Integer errors = 0;

		// check if there is any attachment selected



		set<id> selAttachIdSet= new set<id>();
		for(string attId:(List<String>)System.JSON.deserialize(selIdAttachmentStr, List<String>.class)){
			selAttachIdSet.add(attId);
		}

		//gets body from salesforce files
		map<id,contentVersion> cvBodyMap= wrapperAttach.getContentVersionWithVersionData(selAttachIdSet);

		list<WrapperAttach> listAttachmentSelected= new list<WrapperAttach>();
		for(WrapperAttach wa: wrapperAttach.getListAttachments(parentId,true)){

			if(selAttachIdSet.contains(wa.id)){

				if(wa.sfdcContext == 'content') wa.contentVersion=cvBodyMap.get(wa.id);
				listAttachmentSelected.add(wa);
			}
		}

		if ( listAttachmentSelected.isEmpty() ) {
		   // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Select_one_Attachment));

			return new ApexMessageHandling(false,Label.Select_one_Attachment);
		}

		 if (targetCaseStr==null ) {
			return new ApexMessageHandling(false,Label.Select_one_Case);
		}

		set<id> targetCaseSet= new set<id>();
		for(string attId:(List<String>)System.JSON.deserialize(targetCaseStr, List<String>.class)){
			targetCaseSet.add(attId);
		}




		list<case> selectedTargeCaseList= new list<case>();

		list<case> singleCaseFetch=[SELECT Id, ParentId, CaseNumber, Status, Subject, Account.Name, Owner.Name, RecordType.Name, CreatedDate
								FROM Case where casenumber=:targetSingleCase];
		if (!singleCaseFetch.isEmpty() ) {
			selectedTargeCaseList.add(singleCaseFetch.get(0));
		}



		for(CaseWrapper cw:getParentCaseRelatedCases(caseParentId,parentId)){

			if(targetCaseSet.contains(cw.CaseRecord.id))
				selectedTargeCaseList.add(cw.CaseRecord);
		}

		// check if there is any target case selected
		if (selectedTargeCaseList.isEmpty() ) {
			return new ApexMessageHandling(false,Label.Select_one_Case);
		}

		for(case cw : selectedTargeCaseList  ){
			if(parentId == cw.id ){
				return new ApexMessageHandling(false,'You selected the same source case as destination, please reselect a proper case');
			}
		}


		// list of attachments to be created
		list<Attachment> lstNewAttachments = new list<Attachment>();
		//list<Archived_Attachment__c> lstNewArchived = new list<Archived_Attachment__c>();
		list<AmazonFile__c> lstNewAmazon = new list<AmazonFile__c>();

		list<ContentDocumentLink> lstDocumentLinks = new list<ContentDocumentLink>();

		// go through the list of related cases and create the new attachment(s) for every selected case
		for (case cw : selectedTargeCaseList) {
			for (WrapperAttach attach : listAttachmentSelected) {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,cw + '<br/>'+ attach));
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'is SF ' + attach.getIsSalesforce() ));

				// if is a regular attachment, clone it
				if (attach.getIsSalesforce() && !attach.getIsContent() ) {
					Attachment newAtt = attach.fileAttachment.clone();
					newAtt.Body = attach.fileAttachment.Body;
					newAtt.ParentId = cw.Id;
					newAtt.OwnerId = UserInfo.getUserId();//added by MGO INC254433
					lstNewAttachments.add(newAtt);
				}
				/*
				// if is an archived file, clone it
				if (attach.getIsArchived() ) {
					Archived_Attachment__c newAtt = attach.fileArchived.clone();
					newAtt.Case__c = cw.CaseRecord.Id;
					lstNewArchived.add(newAtt);
				}
				*/
				// if it is an amazon file, clone it and do the copy to amazon
				if (attach.getIsAmazon() ) {
					AmazonFile newAtt = attach.transfer(cw.Id);

					if ( newAtt == null ) errors++;
					else lstNewAmazon.add(newAtt.amazonFile);
				}
				if(attach.getIsContent()){
					// Temporary Conversion from ContentDocument to Attachment
					Attachment newAtt = new Attachment();
					newAtt.name = attach.name;
					newAtt.description = attach.description;
					newAtt.Body =attach.contentVersion.versionData;
					newAtt.ParentId = cw.Id;
					newAtt.OwnerId = UserInfo.getUserId();

					lstNewAttachments.add(newAtt);

				}
			}
		}

		if (!lstNewAttachments.isEmpty()) {
			Database.SaveResult[] srList = Database.insert(lstNewAttachments, false);
			for (Database.SaveResult sr : srList) {
				if (sr.isSuccess()) {
					success ++;
				} else {
					errors ++;
					System.debug('ERROR inserting attachment ' + String.ValueOf(sr.getErrors()));
				}
			}
		}
		if (!lstNewAmazon.isEmpty()) {
			Database.SaveResult[] srList = Database.insert(lstNewAmazon, false);
			for (Database.SaveResult sr : srList) {
				if (sr.isSuccess()) {
					success ++;
				} else {
					errors ++;
					System.debug('ERROR inserting attachment ' + String.ValueOf(sr.getErrors()));

				}
			}
		}

		list<object> formattingArguments = new list<object>{String.ValueOf(success),String.ValueOf(errors),String.ValueOf(parentId)};

		string message =string.format(Label.Response_message, formattingArguments);
		if(errors==0){
			return new ApexMessageHandling(true,'');
		}else{
			return new ApexMessageHandling(false,message);
		}
	}
	@AuraEnabled
	public static ApexMessageHandling createAttachment(String parentId, String body, String name,Long filesize, string contentType){



		Attachment newAtt = new Attachment();
					newAtt.Body = EncodingUtil.base64Decode(body);
					newAtt.ParentId = parentId;
					newAtt.ContentType = contentType;
					newAtt.Name = name;
					newAtt.OwnerId = UserInfo.getUserId();



		Database.SaveResult sr =Database.insert(newAtt);
		if (!sr.isSuccess()) {
			return new ApexMessageHandling(false,sr.getErrors()[0].getMessage());
		}

		return new ApexMessageHandling(true,'');
	}

	public class CaseWrapper {
		@AuraEnabled
		public Case CaseRecord {get; set;}
		public Boolean isSelected {get; set;}
		@AuraEnabled
		public String strRelationship {get; set;}
	}

	//ACAMBAS - WMO-611: Begin
	@AuraEnabled
	public static Boolean updateParentRecord(String recordId) {
		List<Customer_Invoice__c> invoiceList = [SELECT Id, Has_Attachments__c FROM Customer_Invoice__c WHERE Id = :recordId];

		if(!invoiceList.isEmpty() && invoiceList[0].Has_Attachments__c != true) {
			invoiceList[0].Has_Attachments__c = true;
			update invoiceList;
		}

		return true;
	}
	//ACAMBAS - WMO-611: End


}
