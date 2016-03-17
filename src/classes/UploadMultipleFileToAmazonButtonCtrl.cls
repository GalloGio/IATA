global class UploadMultipleFileToAmazonButtonCtrl {
	
	public static final Long MAX_FILE_SIZE = 20971520; // 20 MB

	public Id parentId {get; set;}
	public String folder {get; set;}

	public UploadMultipleFileToAmazonButtonCtrl() {
		//IE9 hack
		String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT');
		if(browserType != null && browserType.contains('MSIE')){
			Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
		}
	}

	@RemoteAction
	global static UploadFile createUploadFile(String id, String filenameupload, String contentType, Long filesize, String folder, String credentialName) {
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
		upf.isSuccess = true;
		return upF ;
	}

	@RemoteAction
	global static boolean createAmazonFileObject( String amazonKey, Long filesize, String parentId ) {
		try {
			list<String> parts = amazonKey.split('/');
			String filename = parts.isEmpty()? '': parts.get( parts.size() - 1 );

			AmazonFile__c amazonFile = new AmazonFile__c(
				Name = filename,
				Full_Name_Unique__c = amazonKey,
				Size_MB__c = filesize* 0.000001 //convert to MB
			);
			if (parentId.startsWith('500')) {
				amazonFile.Case__c = parentId;
			}
			upsert amazonFile;
			return true;
		} catch ( Exception e) {
			System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
			return false;
		}
	}


	/**
		Class to manage the upload of a file to Amazon
		It manages the key and signature to do a callout
	**/
	global class UploadFile {
		
		private AmazonCredentials credential;
		public String endpoint {get; set;}
		public String bucketName {get; set;}
		public String fullFileName {get; set;}
		public String fullFileNameEncoded {get; set;}
		public String authorization {get;set;}
		public String timestamp {get;set;}
		public String contentType {get; set;}
		public boolean isSuccess{get;set;}
		public String errorMessage {get;set;}

		public UploadFile( String id, String filenameupload, String contentType, String folder, AmazonCredentials credential ) {
			this.endpoint = credential.EndpointBaseURL;
			this.bucketName = credential.Bucket;
			this.fullFileName = folder + filenameupload;
			this.fullFileNameEncoded = AmazonRest.EncodePath(this.fullFileName);
			this.contentType = contentType;
			this.credential = credential;
			this.isSuccess = true;
			this.errorMessage = '';
			calculePolicy();
		}

		public void calculePolicy() {
			this.timestamp = DateTime.now().formatGMT('E, d MMM yyyy HH:mm:ss Z');
			String policyString = 'PUT\n\n'
				+ this.contentType + ';charset=UTF-8\n\n'
				+ 'x-amz-date:' + this.timestamp + '\n'
				+ '/'+this.bucketName+'/'+this.fullFileNameEncoded;
			String signedPolicy = AmazonRest.make_sig(policyString, this.credential);
			
			this.authorization = 'AWS ' + this.credential.AWSAccessKeyId + ':' + signedPolicy;
		}

	}

}