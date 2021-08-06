public without sharing class IDCardApplicationImageViewerController {
	private static final String CREDENTIAL_NAME = 'IdCard';
	private static final String FOLDER = 'a0W';

	public ID_Card_Application__c idCardApp {get; set;}

	public String authorizationLink {get; set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public IDCardApplicationImageViewerController(ApexPages.StandardController stdController) {

		Id idcardappid = ApexPages.currentPage().getParameters().get('id');
		idCardApp = [SELECT Id, Photo__c FROM ID_Card_Application__c WHERE Id = :idcardappid];

		if (idCardApp.Photo__c != null) {
			AmazonCredentials credential = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

			Long timestamp = System.now().getTime()/1000 + 1000;
			String filename = '/' + credential.Bucket + '/' + FOLDER + '/' + idCardApp.Photo__c;
			String canonical = 'GET\n\n\n' + timestamp + '\n' + filename;
			Blob bsig = Crypto.generateMac('HmacSHA1', Blob.valueOf(canonical), Blob.valueOf(credential.Secret));
			String signature = EncodingUtil.base64Encode(bsig);
			authorizationLink = credential.EndpointBaseURL + filename.removeStart('/') + '?AWSAccessKeyId=' + credential.AWSAccessKeyId + '&Expires=' + timestamp + '&Signature=' + EncodingUtil.urlEncode(signature,'UTF-8');
		}
	}

}
