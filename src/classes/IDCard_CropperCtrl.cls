global class IDCard_CropperCtrl {

	public String controllerSessionId{public get; public set;}
	public String controllerFileId{public get; public set;}
	public String controllerFileName{ get{
			return controllerFileId.endsWith('.jpg') ? controllerFileId : controllerSessionId + '/' + controllerFileId + '.jpg';
		} public set;}

	UploadMultipleFileToAmazonButtonCtrl.UploadFile uploadAuthorization {private get; private set;}

	public String uploadAuthorizationPath {private set;}
	public String uploadAuthorizationSignature {private set;}
	public String uploadAuthorizationXAmzDate {private set;}

	public String awsImageViewLink {get{
			if (controllerFileId != null && controllerFileId.endsWith('.jpg')) {
				// for existing files, to view them
				return AmazonRest.genPublicExpiringAWSLink(UPLOAD_FOLDER + '/' + controllerFileName, AmazonCredentials.getCredentials(CREDENTIAL_NAME), 300 );
			} else {
				return null;
			}
		} set;}

	private static final String CREDENTIAL_NAME = 'IdCard';
	private static final String UPLOAD_FOLDER = 'a0W'; // anseltest

	public IDCard_CropperCtrl() {
		// String awsImageViewLink = AmazonRest.genPublicExpiringAWSLink(UPLOAD_FOLDER + '/' + controllerFileName, AmazonCredentials.getCredentials(CREDENTIAL_NAME), 300 );
	}

	private void buildUploadAuthorization(){
		String filenameupload = '/' + controllerFileId + (controllerFileId.endsWith('.jpg') ? '' : '.jpg'); // for changingin uploaded pictures, the name already contains the jpg extension
		String uploadPath = UPLOAD_FOLDER + (controllerFileId.startsWith(controllerSessionId) || controllerFileId.endsWith('.jpg') ? '' : '/' + controllerSessionId); // for changingin uploaded pictures, the name already contains the sess Id as containing folder
		uploadAuthorization = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(null /* Originaly ID but not actually used */, filenameupload, 'image/jpeg', 0 /* file size, but only used for validation, otherwise useless */, uploadPath, CREDENTIAL_NAME );
	}

	public String getUploadAuthorizationPath(){
		if( uploadAuthorization == null ){
			buildUploadAuthorization();
		}
		return uploadAuthorization.endpoint+ uploadAuthorization.bucketName + '/' + uploadAuthorization.fullFileNameEncoded;
		//return uploadAuthorization.fullFileNameEncoded;
	}

	public String getUploadAuthorizationSignature(){
		if( uploadAuthorization == null ){
			buildUploadAuthorization();
		}
		return uploadAuthorization.authorization;
	}

	public String getUploadAuthorizationXAmzDate(){
		if( uploadAuthorization == null ){
			buildUploadAuthorization();
		}
		return uploadAuthorization.timestamp;
	}
}
