global class ISSP_AmazonS3_Ctrl {
	public static final String SEPARATOR = '/';
	private static string FOLDER_STEM = '500/';
	private static string AMAZON_CREDENTIALS_NAME = 'GenericAttach';  //Name of Amazon Cred custom setting record that points to AWS Credentials
	public final boolean PORTALUSER= UserInfo.getUserType() <> 'PowerPartner'?  false : true;

	public String policy {get; set;}
	public String signedPolicy {get; set;}
	public transient String actionStatus {get{return '201';} set;}
	public transient String accessid {get{return CREDENTIALS.AWSAccessKeyId;} set;}
	public transient String allowedExtensions {get{return ISSP_CS__c.getValues('ISSP AMS AMAZON S3 ALLOWED EXTS').Value__c;} set;}
	public transient String maxFileSize {get{return ISSP_CS__c.getValues('ISSP AMS AMAZON S3 MAX FILE SIZE').Value__c;} set;}
	public String caseStatus;

	String storageFolder;

	public Id id {get; set;}
	public Id formId {get; set;}

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
	public boolean canUploadAndDelete {get{return true;} set;}
	public AMS_Accreditation_Contact__c newAccreditationContact {get; set;}
	public Id topParentIdHierarchy {get; set;}
	public boolean isDGRForm {get; set;}

	private static List<String> AMAZON_FILES_QUERY_FIELDS = new List<String>{
		'Id',
		'Size_MB__c',
		'Name',
		'Full_Name_Unique__c',
		'CreatedDate',
		'CreatedById',
		'CreatedBy.Name',
		'Case__c',
		'File_Identifier__c',
		'Review_Status__c'
	};

	private static final String AMAZON_FILES_QUERY = String.format(
		'SELECT {0} FROM AmazonFile__c WHERE ',
		new List<String>{
			String.join(AMAZON_FILES_QUERY_FIELDS, ', ')
		}
	);

	public String currentIdentifier {
		get;
		set {
			//Current input value is blank nothing is performed
			if(String.isBlank(value)) return;
			if(currentIdentifier!=null) return;
			currentIdentifier = value;

			Id caseId = this.cse.Id;
			Id formId = this.formId;

			String query = AMAZON_FILES_QUERY;
			query += ' Case__c = :caseId';
			query += ' AND File_Identifier__c = :currentIdentifier';

			if (this.cse.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY && String.isNotBlank(formId)){
				query += ' AND Form__c = :formId';
			}

			List<AmazonFile__c> listAmazonFile = (List<AmazonFile__c>) Database.query(query);

			this.countFiles = listAmazonFile.size();
		}
	}
	public Integer countFiles {private set; get;}


	private Case cse;
	private Account acc {get;set;}

	public transient string AMAZONURL {get{
		return AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).EndpointBaseURL + AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME).Bucket;
	} private set;}

	public static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(AMAZON_CREDENTIALS_NAME);

	//CNS
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

	public ISSP_AmazonS3_Ctrl(){
		if(ApexPages.currentPage().getParameters().containsKey('caseId')){
			id = ApexPages.currentPage().getParameters().get('caseId');
		}

		if(ApexPages.currentPage().getParameters().containsKey('formId')){
			formId = ApexPages.currentPage().getParameters().get('formId');
		}

		if(id== null)
		 return;

		 newAccreditationContact = new AMS_Accreditation_Contact__c();

		this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
				 account.IATA_ISO_Country__r.iso_code__c ,
				 IFAP_Agent_Code__c, AccountId, Account.Top_Parent__c, Financial_Review_Type__c, IsComplaint__c,
				 Reason1__c, CaseArea__c, Owner.Name, OSCAR__c, OSCAR__r.recordType.DeveloperName
				 from Case where id = : this.id];
		this.topParentIdHierarchy = this.cse.Account.Top_Parent__c != null ? this.cse.Account.Top_Parent__c : this.cse.AccountId;
		this.isDGRForm = false;
		if(this.cse.OSCAR__c != null && this.cse.OSCAR__r.recordType.DeveloperName == 'CERTIFICATION'){
			this.isDGRForm = true;
		}
		calculePolicy('');
		this.refreshAmazonFileMap();
		this.refreshReviewStatusMap();
	 }

	 public ISSP_AmazonS3_Ctrl(ApexPages.StandardController stdController) {
		
		this.cse = (Case)stdController.getRecord();
		this.Id = this.cse.Id;

		if(this.id== null)
			return;

		this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
				 account.IATA_ISO_Country__r.iso_code__c ,
				 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
				 Reason1__c, CaseArea__c, Owner.Name
				 from Case where id = : this.id];

		calculePolicy('');
		this.refreshAmazonFileMap();
		this.refreshReviewStatusMap();
	 }


	public ISSP_AmazonS3_Ctrl(ISSP_AMS_Accreditation amsCtrl) {
		this.Id = amsCtrl.newCase.Id;
		this.formId = amsCtrl.newForm.Id;

		if(this.id== null)
		return;

		this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
				 account.IATA_ISO_Country__r.iso_code__c ,
				 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
				 Reason1__c, CaseArea__c, Owner.Name
				 from Case where id = : this.id];

		calculePolicy('');
		this.refreshAmazonFileMap();
		this.refreshReviewStatusMap();
	}

	public ISSP_AmazonS3_Ctrl(ISSP_ANG_PCI pciCtrl){
		this.Id = pciCtrl.newCase.Id;

		if(this.id== null)
		return;

		this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
				 account.IATA_ISO_Country__r.iso_code__c ,
				 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
				 Reason1__c, CaseArea__c, Owner.Name
				 from Case where id = : this.id];

		calculePolicy('');
		this.refreshAmazonFileMap();
		this.refreshReviewStatusMap();
	}

	public ISSP_AmazonS3_Ctrl(ISSP_ModelA_Onboarding modelACtrl){
		this.Id = modelACtrl.onBoardingOSCARCase.Id;

		if (this.id == null) return;

		this.cse = [Select id, Status,CaseNumber,ArchivedDate__c,account.type,
				 account.IATA_ISO_Country__r.iso_code__c ,
				 IFAP_Agent_Code__c,AccountId ,Financial_Review_Type__c,IsComplaint__c,
				 Reason1__c, CaseArea__c, Owner.Name
				 from Case where id = : this.id];

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

		calculePolicy('');
		this.refreshAmazonFileMap();
		this.refreshReviewStatusMap();
	}

	public String getStorageFolder() {
		String FOLDER = FOLDER_STEM;

		String idVal = String.valueOf(cse.Id);

		if(String.isNotBlank(this.formId)){
			idVal += String.valueOf(this.formId);
		}

		return FOLDER + idVal + '/';
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
				'{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+ CREDENTIALS.Bucket +'" } ,'+
				'{"acl":"private"},'+
				'{"success_action_status": "' + actionStatus + '" },'+
				'["starts-with", "$key", ""] ]}';
			policy = EncodingUtil.base64Encode(Blob.valueOf(policyString));
			signedPolicy = make_sig(EncodingUtil.base64Encode(Blob.valueOf(policyString)));
		}

	public map<String, List<AmazonFileAMS>> refreshAmazonFileMap() {
		Id caseId = this.cse.Id;
		Id formId = this.formId;

		String query = AMAZON_FILES_QUERY;
		query += ' Case__c = :caseId';
		query += ' AND isPublic__c = true';
		query += ' AND Review_Status__c != \'' + AMS_Utils.REJECTED_CLOSED + '\'';

		if (this.cse.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY && String.isNotBlank(formId)){
			query += ' AND Form__c = :formId';
		}

		List<AmazonFile__c> listAmazonFile = (List<AmazonFile__c>) Database.query(query);

		SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

		amazonFileMap = new Map<String, list<AmazonFileAMS>>();
		AmazonFileAMS newAmazonFile;
		reqIdentifierList = new List<String>();

		this.countFiles = 0;
		for ( AmazonFile__c amazonFile: listAmazonFile) {

			newAmazonFile = new AmazonFileAMS(amazonFile);

			if (amazonFileMap.containsKey(amazonFile.File_Identifier__c)){
				amazonFileMap.get(amazonFile.File_Identifier__c).add(newAmazonFile);
			} else {
				amazonFileMap.put(amazonFile.File_Identifier__c, new List<AmazonFileAMS>{newAmazonFile});
				reqIdentifierList.add(amazonFile.File_Identifier__c);
			}
			if (this.currentIdentifier==amazonFile.File_Identifier__c) {
				this.countFiles++;
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
	}

	public void refreshAfterDelete(){
		AmazonRest.deleteFile(currentFileName,CREDENTIALS );
		refreshAmazonFileMap();
		refreshReviewStatusMap();
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

		return page.getUrl();
	}

	public String getUniqueFileNames() {
		String ufn;
		Id caseId = this.cse.Id;
		Id formId = this.formId;
		String query = AMAZON_FILES_QUERY + ' Case__c = :caseId';

		if (this.cse.Reason1__c == AMS_Utils.CASE_REASON_HE_MULTICOUNTRY && String.isNotBlank(formId)){
			query += ' AND Form__c = :formId';
		}

		//Get File identifiers for AmzonFile records assoc. with case
		List<AmazonFile__c> listAmazonFile = (List<AmazonFile__c>) Database.query(query);

		SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

		for ( AmazonFile__c amazonFile: listAmazonFile) {
			String name = amazonFile.Name;
				if(ufn==null) {
					ufn = name;
				} else {
					ufn = ufn + ',' + name;
				}
		}
		return ufn;
	}

	/**
		Check is file Name is already in the related files
	**/
	@RemoteAction
	global static Boolean isFileNameUnique(Id caseId, String filename, String formId) {

		String query = AMAZON_FILES_QUERY;
		query += ' Case__c = :caseId';
		query += ' AND Name = :filename';

		if (String.isNotBlank(formId)) {
			query += ' AND Form__c = :formId';
		}

		List<AmazonFile__c> listAmazonFile = (List<AmazonFile__c>) Database.query(query);

		return listAmazonFile.isEmpty();
	}


	/**
		validation so a certificate cannot be created with the same Issued on, expiry date, first and last name 
		within a hierarchy to avoid agencies using a DGR certificate for multiple locations in their hierarchy withe Location classe C or R
	**/
	@RemoteAction
	global static string isFileInTheSameAccountHierarchy(Id parentID, String firstName, String lastName, String ExpiryDate, String certificateIssuedOn) {

		if(Date.parse(ExpiryDate) <= Date.Today().addDays(90)){
			return 'Date';
		}

		List<Account> accountListInHierarchy = [SELECT id, Location_Class__c 
												FROM Account 
												WHERE (Id =: parentID OR Top_Parent__c =: parentID) AND (Location_Class__c =: 'C' OR Location_Class__c =: 'R') ];

		List<AMS_Agency_Regulation__c> agencyRegulationList = [SELECT id, First_Name__c, Last_Name__c, Issued_on__c, Expiry_Date__c
																FROM AMS_Agency_Regulation__c 
																WHERE Account__c IN: accountListInHierarchy];
		
		for (AMS_Agency_Regulation__c ag : agencyRegulationList) {
			if(ag.First_Name__c.equalsIgnoreCase(firstName) && ag.Last_Name__c.equalsIgnoreCase(lastName) && ag.Issued_on__c == Date.parse(certificateIssuedOn)  && ag.Expiry_Date__c == Date.parse(ExpiryDate)){
				return 'fields';
			}
		}

		List<AMS_Accreditation_Contact__c> amsAccreditationContact = [SELECT First_Name__c, Last_Name__c, Certificate_Issued_on__c, Valid_until__c, AMS_Pax_Accreditation_Form__c , AMS_Pax_Accreditation_Form__r.SAAM_Case__r.AccountId
											FROM AMS_Accreditation_Contact__c
											WHERE AMS_Pax_Accreditation_Form__r.SAAM_Case__r.AccountId IN: accountListInHierarchy];

		for (AMS_Accreditation_Contact__c af : amsAccreditationContact) {
			if(af.First_Name__c.equalsIgnoreCase(firstName) && af.Last_Name__c.equalsIgnoreCase(lastName) && af.Certificate_Issued_on__c == Date.parse(certificateIssuedOn) && af.Valid_until__c == Date.parse(ExpiryDate)){
				return 'fields';
			}
		}

		return '';
	}

	/**
		Creates a new Amazon file record for the related Case
	**/
	@RemoteAction
	global static Boolean createAmazonFileObject(Id caseId, String filename, String formId, Long fielsize, String fileid, String firstName, String lastName, String certificateIssuedOn, String ExpiryDate, String issuedBy, boolean isDGRForm) {
		try {
			Case cse = [SELECT Id, Status FROM Case WHERE Id = :caseId];

			String baseFolder = FOLDER_STEM + String.valueOf(caseId) + String.valueOf(formId) + '/';

			AmazonFile__c amazonFile = new AmazonFile__c(
				Name = filename,
				Full_Name_Unique__c = baseFolder + filename,
				File_Identifier__c = fileid,
				File_Identifier_picklist__c = fileid,
				Review_Status__c = 'Pending',
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', 'AMS_File'),
				Size_MB__c = fielsize* 0.000001, //convert to MB
				isPublic__c = true,
				Case__c = cse.Id
			);

			if (!String.isBlank(formId)) {
				amazonFile.Form__c = formId;
			}

			insert amazonFile;

			if(cse.Status!='Draft') {
				cse.New_interaction__c = 'New Attachment';
				cse.New_Attachment_From_Portal_User__c = true;
				update cse;
			}

			if(isDGRForm){
				AMS_Pax_Accreditation_Form__c paf = [SELECT id FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId LIMIT 1];
	
				AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(
					Name = firstName + ' ' + lastName,
					First_Name__c = firstName,
					Last_Name__c = lastName,
					Certificate_issued_on__c = Date.parse(certificateIssuedOn),
					Valid_until__c = Date.parse(ExpiryDate),
					AMS_Pax_Accreditation_Form__c = paf.id,
					Type_Of_Certificate__c = AMS_Utils.CERT_DGR,
					Certificate_Issuer__c = issuedBy,
					recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff')
				);

				insert accContact;
			}

			return true;
		} catch ( Exception ex) {
			System.debug(loggingLevel.FINE, '____ [cls ISSP_AmazonS3_Ctrl - createAmazonFileObject] STACKTRACE - ' + + ex.getStackTraceString()  + '  '  + ex.getMessage());
			return false;
		}
	}

	 public void createAmazonFileObject() {
		String FOLDER = getStorageFolder();
		String folderName = '';
		String fullName;

		try {

			AmazonFile__c amazonFile = new AmazonFile__c(
				Name = uploadedFileName,
				Full_Name_Unique__c = FOLDER + uploadedFileName,
				File_Identifier__c = uploadedFileIdentifier,
				File_Identifier_picklist__c = uploadedFileIdentifier,
				Review_Status__c = 'Pending',
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', 'AMS_File'),
				Size_MB__c = uploadedFileSize* 0.000001, //convert to MB
				isPublic__c = true,
				Case__c = Id
			);

			if (!String.isBlank(formId)) {
				amazonFile.Form__c = formId;
			}

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