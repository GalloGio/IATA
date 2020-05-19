/**
 * Created by PC-RITS04 on 11/22/2018.
 */
global with sharing class ISSP_DragAndDrop {

	/*
	*******************************************************************************************************************
	***          Attributes and Custom Classes
	*******************************************************************************************************************
	*/

	private static final AmazonCredentials AMAZON_CREDENTIAL = WrapperAttach.CREDENTIAL;
	public String credentialName  { get { return WrapperAttach.CREDENTIAL_NAME; } }


	public static final Long MAX_FILE_SIZE = 20971520; // 20 MB
	private static final Integer TIMEOUT = 3000; // 3000 seconds


	// Attributes received by the component
	// Record Id
	public Id parentId {get; set;}
	public String amazonFName {get; set;}
	public String actualDate {get{ return String.valueOfGmt(Datetime.now());}}
	public String actualUser {get{ return UserInfo.getName();}}


	// Get all files already uploaded
	public List<WrapperAmazonFile> amazFileList{
		get{
			List<AmazonFile__c> listAttachments = AmazonFile.getRelatedAmazonFiles(parentId);

			// create list to return
			List<WrapperAmazonFile> amazFileList = new List<WrapperAmazonFile>();
			for(AmazonFile__c recordAux : listAttachments) {
				WrapperAmazonFile aux = new WrapperAmazonFile(recordAux);
				amazFileList.add(aux);
			}
			return amazFileList;
		}
	}

	/**
		class to store a list of files and link to the files
	**/
	public class WrapperAmazonFile{
		public AmazonFile__c afile {get; set;}
		public String fileName {get; set;}
		public String linkToFile {get; set;}
		public Decimal fileSize {get; set;}

		public WrapperAmazonFile(AmazonFile__c afile){
			this.afile=afile;
			this.fileName = afile.Full_Name_Unique__c;
			this.fileName = this.fileName.split('/')[2];
			this.linkToFile = getLinkToAmazonFile(afile.Full_Name_Unique__c);
			this.fileSize = afile.Size_MB__c.setScale(2);
		}
	}


	/**
		Class to manage the upload of a file to Amazon
		It manages the key and signature to do a callout
	**/
	global class WrapperCredential {

		public String sobjectId {get; set;}
		public String fullFileName {get; set;}
		public String fullFileNameEncoded {get; set;}
		public String amazonFilePath {get; set;}
		public String timestamp {get;set;}
		public String contentType {get; set;}
		public String authorization {get;set;}
		public Boolean isSuccess{get;set;}
		public String errorMessage {get;set;}

		public WrapperCredential( String id, String filenameupload, String contentType, String folder) {
			this.sobjectId = id;
			this.fullFileName = folder + filenameupload;
			this.fullFileNameEncoded = AmazonRest.EncodePath(this.fullFileName);
			this.amazonFilePath = AMAZON_CREDENTIAL.EndpointBaseURL+AMAZON_CREDENTIAL.Bucket+'/'+this.fullFileNameEncoded;
			this.contentType = contentType;
			this.isSuccess = true;
			this.errorMessage = '';
			this.authorization = calculePolicy(AMAZON_CREDENTIAL);
		}

		private String calculePolicy(AmazonCredentials credential) {
			this.timestamp = DateTime.now().format('E, d MMM yyyy HH:mm:ss Z');
			system.debug('@@@timestamp: ' +this.timestamp);
			String policyString = 'PUT\n\n'
					+ this.contentType + ';charset=UTF-8\n\n'
					+ 'x-amz-date:' + this.timestamp + '\n'
					+ '/'+credential.Bucket+'/'+this.fullFileNameEncoded;
			String signedPolicy = AmazonRest.make_sig(policyString, credential);

			return 'AWS ' + credential.AWSAccessKeyId + ':' + signedPolicy;
		}
	}

	/*
	*******************************************************************************************************************
	***          Construtor
	*******************************************************************************************************************
	*/
	public ISSP_DragAndDrop(){
	}



	/*
	*******************************************************************************************************************
	***          Methods
	*******************************************************************************************************************
	*/
	/**
	 * Gets the link to download a file in amazon
	 */
	public static String getLinkToAmazonFile (String uniqueFileName){
		return AmazonRest.genPublicExpiringAWSLink( uniqueFileName, AMAZON_CREDENTIAL, TIMEOUT);
	}

	/**
		return the credential object to upload a file to amazon in the browser
	**/
	@RemoteAction
	global static WrapperCredential createUploadFile(String id, String filenameupload, String contentType, Long filesize) {
		String folder = WrapperAttach.getAmazonFolder(id);

		// remove all repeated spaces
		String filteredFileName = filenameupload.replaceAll('[ ]+', ' ');

		WrapperCredential wrapper = new WrapperCredential(id, filteredFileName, contentType, folder);

		// check if file exists
		if( AmazonRest.checkFile( folder + filteredFileName , AMAZON_CREDENTIAL) ) {
			wrapper.isSuccess = false;
			wrapper.errorMessage = Label.NoSameName;
			return wrapper;
		}

		//check file size
		if (filesize > MAX_FILE_SIZE) {
			wrapper.isSuccess = false;
			wrapper.errorMessage = Label.Overall_maximum_size;
			return wrapper;
		}

		//Check file name length: no more than 80 characters
		if (filenameupload.length() > 80) {
			wrapper.isSuccess = false;
			wrapper.errorMessage = Label.File_name_too_long;
			return wrapper;
		}

		// Check not allowed characters
		if (filenameupload.indexOf('\'') != -1 || filenameupload.indexOf('&') != -1) {
			wrapper.isSuccess = false;
			wrapper.errorMessage = Label.No_special_characters;
			return wrapper;
		}

		wrapper.isSuccess = true;
		return wrapper ;
	}

	/**
		Create the AmazonFile__c record representing the file already uploaded in Amazon
	**/
	@RemoteAction
	global static String createAmazonFileObject(String amazonKey, Long filesize, String parentId, AmazonFile__c amazonFileModel) {
		Savepoint sp = Database.setSavepoint();
		try {
			list<String> parts = amazonKey.split('/');
			String filename = parts.isEmpty() ? '' : parts.get( parts.size() - 1 );
			AmazonFile__c amazonfile = amazonFileModel.clone();
			if(String.isBlank(amazonfile.Name)) {
				amazonfile.Name = filename;
			}
			amazonfile.Full_Name_Unique__c = amazonKey;
			amazonfile.Document_Date__c = System.today();
			amazonfile.Size_MB__c = filesize * 0.000001; //convert to MB
			if (parentId.startsWith('500')) {
				amazonFile.Case__c = parentId;
			} else if (parentId.startsWith('001')) {
				amazonFile.Account__c = parentId;
			} else {
				amazonFile.sObject_Id__c = parentId;
			}
			upsert amazonFile;

			string linkToObject = getLinkToAmazonFile(amazonfile.Full_Name_Unique__c);

			return linkToObject.replace('&', ' ');

			//return amazonFile.Id;
		} catch ( Exception e) {
			Database.rollback( sp );
			System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
			return '';
		}
	}


	/**
		Delete a file in amazon record
	**/
	@RemoteAction
	global static boolean deleteFile(String parentId, String filenamedelete) {
		String folder = WrapperAttach.getAmazonFolder(parentId);
		list<AmazonRest.S3File> listFileLoc = AmazonRest.getListFiles(folder, AMAZON_CREDENTIAL);
		list<AmazonFile__c> listAmazonFile = AmazonFile.getAmazonFileByUniqueName(folder+filenamedelete);

		for (AmazonRest.S3File file : listFileLoc ) {
			if (file.getName().equalsIgnoreCase(filenamedelete)) {
				file.deleteFile();
				if(listAmazonFile.size() == 1){
					delete listAmazonFile;
				}
				return true;
			}
		}
		return false;
	}

}