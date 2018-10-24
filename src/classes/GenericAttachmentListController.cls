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

	//new CNS
	public String communityName{
	  get{
		return ApexPages.currentPage().getParameters().get('CommunityName');
	  }set;}

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
    
    public string sObjectType	{get; set;}	//stores the API name of the object we are looking the attachments for
	
	// assgnTo variable
	private static Boolean isForPortalStatic = false; // used only for Remote actions
	public Boolean isForPortal {
		get;
		set {
			if (this.isForPortal == null ) {
				this.isForPortal = value;
				isForPortalStatic = value;
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
				//Assign the name of the object
				sObjectType = getObjectAPIName(this.id);
				//if is null, is assumed we are working with case
				if(sObjectType=='') sObjectType = 'Case';
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
        if(sObjectType=='Case')
	        relatedCase = [Select CaseNumber, Id, parent.OSCAR__c, parent.RecordType__c, parent.RecordTypeId from Case where id = :this.id];

        if (this.isForPortal) {
            this.showFileIdentifier = false;
            if(sObjectType=='Case')
           		cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :this.id];
        } else {
        	if(sObjectType=='Case'){
	            // check if case is in recordtypes SAAM (ProcessEuropeSCE) or Oscar Communication
	            cse = [Select Recordtype.DeveloperName, Status, Reason1__c FROM Case where id = :this.id];
	            set<String> setRecordTypes = new set<String>{'ProcessEuropeSCE','OSCAR_Communication'};
	            this.showFileIdentifier = setRecordTypes.contains(cse.Recordtype.DeveloperName);
        	}
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
		if(sObjectType!='Case') return false;
		
        if((cse.Status != 'Draft' && cse.Status != 'Open - EDMC') || ((cse.Reason1__c == 'New SA / CHV – New Code' || cse.Reason1__c == 'CLO - Closure') && cse.Status == 'Draft')) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean getParentIsOscar() {
    	if(sObjectType!='Case') return false;
    	
        if((relatedCase.parent.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId())) {
            return true;
        } else {
            return false;
        }
    }
    
    public PageReference goToAttachmentPage() {
        return new Pagereference('/ISSP_AddAttachment?caseId=' + id + '&CommunityName=' + CommunityName + '&retURL=%2F' + id);
    }

    /**
        get a list of files with valid links to download them from Amazon
        this funcion needs a isportal variable to know what files can retrieve
    **/
    @RemoteAction
    global static list<FileDef> getAllExpiringLink(String objectId) {
        list<WrapperAttach> listAttach = new list<WrapperAttach>();
        if (isforPortalStatic) {
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

        global class FileDef {
        String name;
        String url;
        String data;
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
    
}