global class WrapperAttach implements Comparable {


	public static final String AMAZON_BASE_FOLDER = '';

	public static final String CREDENTIAL_NAME = 'GenericAttach';

	public static final AmazonCredentials CREDENTIAL = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

	public static final String CREDENTIAL_NAME_RECICLE_BIN = 'RecycleBin';

	public static final AmazonCredentials CREDENTIAL_RECICLE_BIN = AmazonCredentials.getCredentials(CREDENTIAL_NAME_RECICLE_BIN);

	@AuraEnabled
	public Boolean isSelected {get; set;}
	@AuraEnabled
	public Id id {get;set;}
	@AuraEnabled
	public String filetype {get;set;}
	@AuraEnabled
	public String name {get;set;}
	@AuraEnabled
	public String description {get;set;}
	@AuraEnabled
	public String internalComments {get;set;}
	@AuraEnabled
	public String contentType {get;set;}
	@AuraEnabled
	public Decimal size {get;set;}
	@AuraEnabled
	public DateTime lastModified {get;set;}
	@AuraEnabled
	public DateTime createdDate {get;set;}
	@AuraEnabled
	public Id createdBy {get;set;}
	@AuraEnabled
	public String fileIdentifier {get;set;}
	@AuraEnabled
	public String fileIdentifierPick {get;set;}
	@AuraEnabled
	public String reviewStatus {get;set;}
	@AuraEnabled
	public String source {get;set;}
	@AuraEnabled
	public String recordTypeId {get;set;}
	@AuraEnabled
	public String recordTypeDeveloperName {get;set;}
	//public Contact createdByContact {get;set;}
	@AuraEnabled
	public String createdByName {get;set;}
	@AuraEnabled
	public String viewURL {get;set;}
	@AuraEnabled
	public String fullName {get;set;}
	@AuraEnabled
	public Boolean isPublic {get;set;}

	@AuraEnabled
	public String efCategory { get; set; }
	@AuraEnabled
	public String efSubcategory { get; set; }
	@AuraEnabled
	public String efSAPNumber { get; set; }
	@AuraEnabled
	public Date efDocumentDate { get; set; }
	@AuraEnabled
	public Date efExpiryDate { get; set; }
	@AuraEnabled
	public Boolean efExpired { get; set; }
	@AuraEnabled
	public Boolean efSkipValidation { get; set; }
	@AuraEnabled
	public Boolean efPrivate { get; set; }

	@AuraEnabled
	public ISSPAttachmentPermission__c permission {get;set;}
	@AuraEnabled
	public Attachment fileAttachment {get;set;}
	@AuraEnabled
	public ContentVersion contentVersion {get;set;}
	public Archived_Attachment__c fileArchived {get;set;}
	@AuraEnabled
	public AmazonFile fileAmazon {get;set;}

	@AuraEnabled
	public String sfdcContext {get;set;} // attachment or contentDocument
	public Blob versionData {get;set;} // attachment or contentDocument

	/*** AMSU-139 ***/
	@AuraEnabled
	public String updatedBy {get;set;}
	@AuraEnabled
	public DateTime updatedDate {get;set;}

	public WrapperAttach(){}

	public WrapperAttach(Attachment file, ISSPAttachmentPermission__c permission) {
		this.isSelected = false;
		this.fileAttachment = file;
		this.permission = permission;
		this.id = file.Id;
		this.filetype = 'Salesforce';
		this.sfdcContext = 'attachment';
		this.name = file.name;
		this.description = file.description;
		this.contentType = file.contentType;
		this.size = file.BodyLength * 0.000001;
		this.lastModified = file.LastModifiedDate;
		this.createdDate = file.createdDate;
		this.createdBy = file.createdById;
		this.fileIdentifier = '';
		this.createdByName = file.createdBy.Name;
		this.viewURL = new PageReference('/servlet/servlet.FileDownload?file=' + file.Id).getUrl();
		setPermission();
	}

	public WrapperAttach(ContentDistribution cd) {
		this.isSelected = false;
		this.id = cd.ContentVersion.ContentDocumentId;
		this.filetype = 'Salesforce';
		this.sfdcContext = 'content';
		this.name = cd.name+'.'+cd.ContentVersion.FileExtension;
		this.description = cd.ContentVersion.Description;
		this.contentType = cd.ContentVersion.FileType;
		this.size = cd.ContentVersion.ContentSize * 0.000001;
		this.lastModified = cd.ContentVersion.LastModifiedDate;
		this.createdDate = cd.ContentVersion.createdDate;
		this.createdBy = cd.ContentVersion.createdById;
		this.fileIdentifier = '';
		this.createdByName = cd.ContentVersion.createdBy.Name;
		this.viewURL =cd.DistributionPublicUrl;
		this.isPublic=true;

	}
	public WrapperAttach(ContentVersion cv) {
		this.isSelected = false;
		this.id = cv.ContentDocumentId;
		this.contentVersion = cv;
		this.filetype = 'Salesforce';
		this.sfdcContext = 'content';
		this.name = cv.title+'.'+cv.FileExtension;
		this.description = cv.Description;
		this.contentType = cv.FileType;
		this.size = cv.ContentSize * 0.000001;
		this.lastModified = cv.LastModifiedDate;
		this.createdDate = cv.createdDate;
		this.createdBy = cv.createdById;
		this.fileIdentifier = '';
		this.createdByName = cv.createdBy.Name;
		this.viewURL =cv.id;
		this.isPublic=true;
	}

	public WrapperAttach(Archived_Attachment__c file) {
		this.isSelected = false;
		this.fileArchived = file;
		this.id = file.Id;
		this.filetype = 'Archived';
		this.name = file.name;
		this.description = file.description__c;
		this.internalComments = file.Internal_Comments__c;
		this.contentType = file.contentType__c;
		this.size = file.BodyLength__c * 0.000001;
		this.lastModified = file.LastModifiedDate;
		this.createdDate = file.Original_Creation_Date__c;
		this.createdBy = file.OriginalCreatedBy__c;
		this.fileIdentifier = '';
		this.createdByName = file.createdBy.Name;
		this.viewURL = new PageReference('/servlet/servlet.FileDownload?file=' + file.Id).getUrl();
		this.isPublic = false;
	}

	public WrapperAttach(AmazonFile file) {
		this.isSelected = false;
		this.fileAmazon = file;
		this.id = file.getId();
		this.filetype = 'Amazon';
		this.sfdcContext = 'amazon';
		this.name = file.getName();
		this.size = file.getSize();
		this.description = file.getDescription();
		this.internalComments = file.getInternalComments();
		this.lastModified = file.getLastModifiedDate();
		this.createdDate = file.getCreatedDate();
		this.createdBy = file.getCreatedById();
		this.fileIdentifier = file.getFileIdentifier();
		this.fileIdentifierPick = file.getFileIdentifierPick();
		this.reviewStatus = file.getReviewStatus();
		this.source = file.getSource();
		this.recordTypeId = file.getRecordTypeId();
		this.recordTypeDeveloperName = file.getRecordTypeDeveloperName();
		this.createdByName = file.getCreatedBy();
		this.viewURL = '';
		this.fullName = file.getFullName();
		this.isPublic = file.getIsPublic();
		this.efCategory = file.getEFCategory();
		this.efSubcategory = file.getEFSubcategory();
		this.efDocumentDate = file.getEFDocumentDate();
		this.efSAPNumber = file.getEFSAPNumber();
		this.efExpiryDate = file.getEFExpiryDate();
		this.efExpired = file.getEFExpired();
		this.efPrivate = file.getEFPrivate();
		this.efSkipValidation = file.getEFSkipValidation();
		this.updatedBy = file.getUpdatedBy();
		this.updatedDate = file.getUpdatedDate();
	}

	private void setPermission() {
		if (this.permission == null ) {
			this.permission = new ISSPAttachmentPermission__c(
				ShowToPortalUsers__c = true,
				Name = this.Id,
				AttachmentId__c = this.Id
			);
		}
		this.isPublic = this.permission.ShowToPortalUsers__c;
	}

	/**
		Get the link to a page to view current attachment
	**/
	public Pagereference viewFile() {
		if (filetype == 'Salesforce' || filetype == 'Archived' ) {
			PageReference pageref = new PageReference('/'+this.viewURL);
			pageref.setRedirect(true);
			return pageref;
		}
		// view amazon File is not handeled here, use AmazonRest.genPublicExpiringAWSLink()
		return null;
	}

	public Boolean getIsAmazon() {
		return this.filetype == 'Amazon';
	}
	public Boolean getIsArchived() {
		return this.filetype == 'Archived';
	}
	public Boolean getIsSalesforce() {
		return this.filetype == 'Salesforce';
	}
	public Boolean getIsContent() {
		return this.sfdcContext == 'content';
	}

	/**
		Change the permission (to see it in the portal) of current attachment
	**/
	public void changePermission() {
		if (filetype == 'Salesforce') {
			if(sfdcContext == 'content'){

			}
			if(sfdcContext=='attachment'){
				this.permission.ShowToPortalUsers__c = ! this.permission.ShowToPortalUsers__c;
				upsert this.permission;
			}
		} else if (filetype == 'Archived') {

		} else if (this.filetype == 'Amazon') {
			this.fileAmazon.changePermission();
		}
	}

	public void changePermission(Boolean value) {
		if (filetype == 'Salesforce') {
			if ( this.permission.ShowToPortalUsers__c != value ) {
				this.permission.ShowToPortalUsers__c = value;
				upsert this.permission;
			}
		} else if (filetype == 'Archived') {

		} else if (this.filetype == 'Amazon') {
			this.fileAmazon.changePermission(value);
		}
	}

	/**
		Copy current file to another object
	**/
	public AmazonFile transfer(Id sobjectId) {
		if (this.filetype == 'Amazon') {
			String destFileName = getAmazonFolder(sobjectId) + this.name;
			Boolean result = this.fileAmazon.copyFile( CREDENTIAL, CREDENTIAL, destFileName);
			if ( ! result ) {
				return null;
			}

			AmazonFile__c aFile = this.fileAmazon.amazonfile.clone(false, true);
			aFile.Full_Name_Unique__c = destFileName;
			aFile.Case__c = sobjectId;

			AmazonFile cloned = this.fileAmazon.clone();
			cloned.amazonFile = aFile;
			return cloned;
		}
		return null;
	}

	/**
		Move this file from Amazon Bucket to the recycleBin bucket
	**/
	public boolean moveToBucket() {
		if (this.filetype == 'Amazon') {
			String destinationFilename = this.FileAmazon.getFullName();
			Boolean result = this.FileAmazon.copyFile( CREDENTIAL, CREDENTIAL_RECICLE_BIN, destinationFilename);
			if (result) {
				result = this.FileAmazon.delFile();
			}
			return result;
		}
		return false;
	}

	/**
		AMSU-186
	**/
	public Boolean cloneToRecicleBin() {
		if (this.filetype == 'Amazon') {
			String destinationFilename = this.FileAmazon.getFullName();
			Boolean result = this.FileAmazon.copyFile(CREDENTIAL, CREDENTIAL_RECICLE_BIN, destinationFilename);
			return result;
		}
		return false;
	}


	public void updateAttach() {
		if (this.filetype == 'Amazon') {
			this.fileAmazon.amazonFile.Description__c = this.description;
			this.fileAmazon.amazonFile.Internal_Comments__c = this.internalComments;
			this.fileAmazon.amazonFile.isPublic__c = isPublic;

			update this.fileAmazon.amazonFile;
		}
		if (filetype == 'Salesforce' ) {
			this.fileAttachment.Description = this.description;
			update this.fileAttachment;
			if ( this.permission.ShowToPortalUsers__c != isPublic ) {
				this.permission.ShowToPortalUsers__c = isPublic;
				upsert this.permission;
			}
		}
		if ( filetype == 'Archived' ) {
			this.fileArchived.Description__c = this.description;
			this.fileArchived.Internal_Comments__c = this.internalComments;
			update this.fileArchived;
		}
	}

	/**
		override compareTo method to allow sorts
	**/
	public Integer compareTo(Object compareTo) {
		WrapperAttach compareToWrapper = (WrapperAttach)compareTo;
		if ( this.createdDate <= compareToWrapper.createdDate ) return 1;
		return -1;
	}


	/** STATIC METHODS **/

	/**
		Get all attachments related to an object
	**/
	public static list<WrapperAttach> getListAttachments(Id sobjectId) {
		return getListAttachments(sobjectId, false,false);
	}

	public static list<WrapperAttach> getListAttachments(Id sobjectId,Boolean withBody) {
		return getListAttachments(sobjectId, withBody,false);
	}

	public static list<WrapperAttach> getListAttachments(Id sobjectId,Boolean withBody,Boolean isPortal) {
		list<WrapperAttach> listAttachments = getSalesforceAttachments(sobjectId, withBody);
		//listAttachments.addAll(getArchivedAttachments(sobjectId)); //silenced from the lightning migration

		list<WrapperAttach> contentList=getContentAttachments(sobjectId,isPortal,false,null);

		listAttachments.addAll(contentList);// gets content documents (introduced with lightning)

		listAttachments.addAll(getAmazonAttachments(sobjectId));

		return listAttachments;
	}

	/**
		Get all attachments related to an object but only visible for Portal
	**/
	public static list<WrapperAttach> getListAttachmentsForPortal(Id sobjectId) {
		 Boolean fullAttachmentAccess;
		 list<AttachmentListLimitedAccess__c> perms = [select SetupOwnerId , Name, Id from AttachmentListLimitedAccess__c where SetupOwnerId = :userinfo.getProfileId() or SetupOwnerId = :userinfo.getUserId()];
		 fullAttachmentAccess = perms.size()==0;

		list<WrapperAttach> listAttachments = new list<WrapperAttach>();
		for (WrapperAttach attach: getListAttachments(sobjectId,false,true) ) {
			 SYSTEM.DEBUG('Attach File type:' + attach.filetype);

			if (attach.isPublic || (attach.filetype=='Salesforce' && fullAttachmentAccess)) {
				listAttachments.add(attach);
			}
		}
		return listAttachments;
	}


	/**
		Get all standard salesforce attachments related to an object
		@param withBody query Body field in attachmets, only for these cases where the size is not a problem
	**/
	private static list<WrapperAttach> getSalesforceAttachments(Id sobjectId, Boolean withBody) {
		list<WrapperAttach> listAttach = new list<WrapperAttach>();
		try {
			list<Attachment> listAttachment = new list<Attachment>();

			if(withBody) {
				// query with body field
				listAttachment = [SELECT  Id,  Name, BodyLength, CreatedById, CreatedDate, ContentType, Description, IsPrivate, LastModifiedDate, LastModifiedById, OwnerId, ParentId, CreatedBy.Name, Body
				FROM Attachment
				WHERE ParentId = :sobjectId];

			}  else {
				// query without body field
				listAttachment = [SELECT  Id,  Name, BodyLength, CreatedById, CreatedDate, ContentType, Description, IsPrivate, LastModifiedDate, LastModifiedById, OwnerId, ParentId, CreatedBy.Name
				FROM Attachment
				WHERE ParentId = :sobjectId];
			}

			map<Id, ISSPAttachmentPermission__c> mapPermission = getMapPermission(listAttachment);

			for ( Attachment attach: listAttachment ) {
				listAttach.add( new WrapperAttach(attach, mapPermission.get(attach.Id)) );
			}
		} catch (Exception e) {
			System.debug('Error in getSalesforceAttachments('+ sobjectId + ') : ' + e.getMessage());
		}
		return listAttach;
	}

	/**
		Return a map with all permissions to the input objects
	**/
	private static map<Id, ISSPAttachmentPermission__c> getMapPermission(list<sObject> listParents) {
		list<String> listId = new list<String>();
		for (sObject obj: listParents) {
			listId.add(obj.id);
		}
		list<ISSPAttachmentPermission__c> listPermission = [
			SELECT Id, AttachmentId__c, ShowToPortalUsers__c
			FROM ISSPAttachmentPermission__c
			WHERE AttachmentId__c IN :listId];

		map<Id, ISSPAttachmentPermission__c> mapPermission = new map<Id, ISSPAttachmentPermission__c>();
		for (ISSPAttachmentPermission__c permission: listPermission) {
			mapPermission.put(permission.AttachmentId__c, permission);
		}
		return mapPermission;
	}

	/**
		Get all files in the bucket related to this object
	**/
	private static list<WrapperAttach> getAmazonAttachments(Id sobjectId) {
		list<WrapperAttach> listAttach = new list<WrapperAttach>();
		try {
			String folder = getAmazonFolder(sobjectId);
			list<AmazonRest.S3File> listS3Files = AmazonRest.getListFiles(folder, CREDENTIAL);
			list<AmazonFile> listAmazonfiles = AmazonFile.getFiles( sobjectId, listS3Files);

			for(AmazonFile file: listAmazonfiles){
				if(file.getFullName() != '500/' + sobjectId + '/Notice_of_Change_form.pdf') {
					listAttach.add(new WrapperAttach(file));
				}
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		return listAttach;
	}

	/**
		Get an attachmet in Amazon if it exists
	**/
	public static WrapperAttach getAmazonAttachment(Id sobjectId, String fullName) {
		try {
			AmazonFile aFile = AmazonFile.getFile( sobjectId, fullName, CREDENTIAL);
			return new WrapperAttach(aFile);

		} catch (Exception e) {
			System.debug('ERROR in getAmazonAttachment( ' + sobjectId + ', ' + fullName + ') : ' + e.getMessage());
			return null;
		}
	}

	 /**
		Return the folder where we store the attachments for an specific sobject
	**/
	public static String getAmazonFolder(Id sobjectId) {
		String suffix = String.ValueOf(sobjectId).substring(0,3);
		return AMAZON_BASE_FOLDER + suffix + '/' + String.valueOf(sobjectId) + '/';
	}



	/**
		Get all Content salesforce attachments related to an object
	**/
	public static list<WrapperAttach> getContentAttachments(Id sobjectId,boolean isPortal,boolean withBody,set<id> contentDocFilterSet) {
		list<WrapperAttach> attachList = new list<WrapperAttach>();
		//attached Files list
		set<id> contentDocSet= new set<id>();
		if(isPortal ||contentDocFilterSet==null)
			for(ContentDocumentLink  cd :[select ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId =:sobjectId]){
				contentDocSet.add(cd.ContentDocument.LatestPublishedVersionId);
			}
		if(isPortal){
			attachList= getContentInfo(contentDocSet);
		}else{

			string query='Select ContentDocumentId,Title, FileExtension,Description,FileType,ContentSize,CreatedById,CreatedBy.name,CreatedDate,LastModifiedDate ';
			if(withBody)query+=',versionData';


			string queryEnd=' From ContentVersion where IsLatest = true ';

			if(contentDocFilterSet!=null){
				queryEnd+=' AND contentDocumentId IN :contentDocFilterSet';
			}else {
				queryEnd+=' AND id IN :contentDocSet';

			}
			system.debug(query+queryEnd);

			list<contentVersion> cvList=Database.query(query+queryEnd);

			for(ContentVersion  cv :cvList){
				WrapperAttach att=new WrapperAttach(cv);
				attachList.add(att);
			}
		}
		return attachList;
	}

	public static list<ContentDocument> getContentDocInfo(set<Id> sobjectId) {
		return [select title,LatestPublishedVersionId  from ContentDocument where id in :sobjectId];
	}


	public static list<WrapperAttach> getContentInfo(set<id> contentIdSet) {
		list<WrapperAttach> attachList = new list<WrapperAttach>();
		for(ContentVersion cv:[select Id,ContentDocumentId,title,FileExtension,Description,FileType,ContentSize,
		LastModifiedDate,createdDate,createdById,createdBy.Name
				from ContentVersion where id in :contentIdSet]){
			attachList.add(new WrapperAttach(cv));
		}
		return attachList;
	}

	/**
		Return map with versionData used in transfer Attachments, contentDocumentid as key
	**/
	public static map<id,contentVersion> getContentVersionWithVersionData (set<id> contentDocSet) {

		map<id,contentVersion> cvBodyMap= new map<id,contentVersion>();
		if(!contentDocSet.isEmpty()){
			//get contentDocsWithBody
			for(ContentVersion cv:[Select id,contentDocumentId,versionData From ContentVersion where contentDocumentId in :contentDocSet AND IsLatest = true]){
				cvBodyMap.put(cv.contentDocumentId,cv);
			}
		}
		return cvBodyMap;
	}

}
