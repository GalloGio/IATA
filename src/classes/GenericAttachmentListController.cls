global with sharing class GenericAttachmentListController {
	
    public String uploader {get;set;}
    public String source {get;set;}
    public Boolean scroll {get;set;}
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
	public Boolean showFileIdentifier {get; set;}
	Boolean canAttachFiles;
    private Case cse;

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
            hasOscar = String.isNotEmpty(relatedCase.parent.OSCAR__c);
        }
    }
	
	// assgnTo variable
	public Boolean isForPortal {
		get;
		set {
			if (this.isForPortal == null ) {
				this.isForPortal = value;
				init();
			}
		}
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
	
	/**
		check all assignTo calls have been done and execute initial methods
	**/
	private void init() {
		if (this.isForPortal == null ) return;
		if (this.id == null ) return;
		
		// check if current user is Admin
        Profile profile = [Select id, Name from Profile where Id = :UserInfo.getProfileId()];
        this.isAdminUser = profile.Name.startsWithIgnoreCase('System Administrator') || profile.Name.startsWithIgnoreCase('Developer');
        relatedCase = [Select CaseNumber, Id, parent.OSCAR__c, parent.RecordType__c from Case where id = :this.id];

        if (this.isForPortal) {
            this.showFileIdentifier = false;
            cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :this.id];
        } else {
            // check if case is in recordtypes SAAM (ProcessEuropeSCE) or Oscar Communication
            cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :this.id];
            set<String> setRecordTypes = new set<String>{'ProcessEuropeSCE','OSCAR_Communication'};
            this.showFileIdentifier = setRecordTypes.contains(cse.Recordtype.DeveloperName);
        }
		
		refreshList();
	}

	/**
		Refresh the list of file attachments
	**/
	public Pagereference refreshList() {
		try {
			if (this.isForPortal) {
				this.listAttachments = WrapperAttach.getListAttachmentsForPortal(this.id);
			} else {
				this.listAttachments = WrapperAttach.getListAttachments(this.id);
			}
			this.listAttachments.sort();
		} catch (Exception e ) {
			TransformationHelper.sendEmailSupport('FATAL: GenericAttachmentListController in function refreshList()  ' ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
		}
		return null;
	}

	/**
		Get alink to access to an amazon file, this link is time limited
	**/
	@RemoteAction
	global static string getExpiringLink(string fileName ) {
		Integer secondsValid = 300;
		String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
		return link;
	}

	/**
		Delete an attachment archived attachment or Amazon Attachment
	**/
	@RemoteAction
	global static boolean deleteAttachment(string strId, String fullName) {
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
		//System.debug('GenericAttachmentListController.deleteAttachment: ' + strId + ' object not recognized');
		return result;
	}
	
	/**
		Delete a standard attachment in Salesforce
	**/
	private static boolean deleteSalesforceAttachment(String id) {
		try {
			delete [SELECT Id  FROM Attachment where Id=:id];
			return true;
		} catch (Exception e) {
			System.debug('GenericAttachmentListController.deleteSalesforceAttachment' + e.getMessage());
			return false;
		}
	}
	
	/**
		Delete an archived attachment object
	**/
	private static boolean deleteArchivedAttachment(String id) {
		try {
			delete [SELECT Id  FROM Archived_Attachment__c where Id=:id];
			return true;
		} catch (Exception e) {
			System.debug('GenericAttachmentListController.deleteArchivedAttachment' + e.getMessage());
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
			System.debug('GenericAttachmentListController.deleteAmazonAttachment' + e.getMessage());
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
		for ( WrapperAttach attachment: this.listAttachments ) {
			attachment.changePermission(value);
		}
	}
	
	/**
		redirect to the Trasnfer Attachments page
	**/
	public String getTransferAttachmentsUrl() {
		PageReference pageref = Page.TransferAttachmentToCase;
		pageref.getParameters().put('id',this.Id);
		pageref.setRedirect(true);
		return pageref.getUrl();
	}
	
		public PageReference callEditAttachment() {
		for ( WrapperAttach attach: listAttachments ) {
			if (attach.id == this.editAttachmentId) {
				this.editAttachment = attach;
				return  null;
			}
		}
		return null;
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
	
	
	public Boolean getCanAttachFilesToCase() {
        if((cse.Status != 'Draft' && cse.Status != 'Open - EDMC') || ((cse.Reason1__c == 'New SA / CHV – New Code' || cse.Reason1__c == 'CLO - Closure') && cse.Status == 'Draft')) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean getParentIsOscar() {
        if((relatedCase.parent.RecordType__c == 'OSCAR Communication')) {
            return true;
        } else {
            return false;
        }
    }
    
    public PageReference goToAttachmentPage() {
        return new Pagereference('/ISSP_AddAttachment?caseId=' + id + '&retURL=%2F' + id);
    }

    /**
        download files from Amazon
    **/
    @RemoteAction
    global static list<FileDef> getFilesFromAmazon(String objectId) {

        list<FileDef> listFileDef = new list<FileDef>();
        for (WrapperAttach attach: WrapperAttach.getListAttachments(objectId)) {
            FileDef filedef = new FileDef();
            filedef.name = attach.name;
            filedef.url = getExpiringLink(attach.fullName);
            filedef.data = '';
            listFileDef.add(filedef);
        }
        system.debug('aqui listFileDef ' + listFileDef);
        return listFileDef;
    }

        global class FileDef {
        String name;
        String url;
        String data;
    }
}