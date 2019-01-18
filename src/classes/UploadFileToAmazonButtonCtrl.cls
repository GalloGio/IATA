global with sharing class UploadFileToAmazonButtonCtrl {

	public static final Long MAX_FILE_SIZE = 20971520; // 20 MB
	public Id parentId {get; set;}

	public UploadFileToAmazonButtonCtrl() {
		//IE9 hack
		String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT');
		if(browserType != null && browserType.contains('MSIE')){
			Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
		}
	}

	/**
		return the credential object to upload a file to amazon in the browser
	**/
	@RemoteAction
	global static WrapperCredential createUploadFile(String id, String filenameupload, String contentType, Long filesize, String credentialName) {
		String folder = WrapperAttach.getAmazonFolder(id);
		AmazonCredentials credential = AmazonCredentials.getCredentials(credentialName);

		// remove all repeated spaces
		String filteredFileName = filenameupload.replaceAll('[ ]+', ' ');

		WrapperCredential wrapper = new WrapperCredential(id, filteredFileName, contentType, folder, credential);

		// check if file exists
		if( AmazonRest.checkFile( folder + filteredFileName , credential) ) {
			wrapper.isSuccess = false;
			wrapper.errorMessage =  Label.NoSameName;
			return wrapper;
		}

		//check file size
		if (filesize > MAX_FILE_SIZE) {
			wrapper.isSuccess = false;
			wrapper.errorMessage =  Label.Overall_maximum_size;
			return wrapper;
		}

		//Check file name length: no more than 80 characters
		if (filenameupload.length() > 80) {
			wrapper.isSuccess = false;
			wrapper.errorMessage =  Label.File_name_too_long;
			return wrapper;
		}

		// Check not allowed characters
		if (filenameupload.indexOf('\'') != -1 || filenameupload.indexOf('&') != -1) {
			wrapper.isSuccess = false;
			wrapper.errorMessage =  Label.No_special_characters;
			return wrapper;
		}

		wrapper.isSuccess = true;
		return wrapper ;
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

		public WrapperCredential( String id, String filenameupload, String contentType, String folder, AmazonCredentials credential ) {
			this.sobjectId = id;
			this.fullFileName = folder + filenameupload;
			this.fullFileNameEncoded = AmazonRest.EncodePath(this.fullFileName);
			this.amazonFilePath = credential.EndpointBaseURL+credential.Bucket+'/'+this.fullFileNameEncoded;
			this.contentType = contentType;
			this.isSuccess = true;
			this.errorMessage = '';
			this.authorization = calculePolicy(credential);
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
			if(String.isBlank(amazonfile.Name))
			{
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

			return amazonFile.Id;
		} catch ( Exception e) {
			Database.rollback( sp );
			System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
			return '';
		}
	}
}